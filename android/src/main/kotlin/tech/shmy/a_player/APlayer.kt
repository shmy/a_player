package tech.shmy.a_player

import android.app.Activity
import android.app.PictureInPictureParams
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Rect
import android.graphics.SurfaceTexture
import android.os.Build
import android.provider.Settings
import android.util.Rational
import android.view.Surface
import android.widget.Toast
import com.aliyun.player.AliPlayer
import com.aliyun.player.AliPlayerFactory
import com.aliyun.player.IPlayer
import com.aliyun.player.bean.InfoCode
import com.aliyun.player.nativeclass.PlayerConfig
import com.aliyun.player.source.UrlSource
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry


class APlayer(
    private val context: Context,
    private val activity: Activity,
    private val textureEntry: TextureRegistry.SurfaceTextureEntry,
    private val binaryMessenger: BinaryMessenger
) : EventChannel.StreamHandler {
    private var player: AliPlayer? = null
    private val surfaceTexture: SurfaceTexture = textureEntry.surfaceTexture()
    private val surface: Surface = Surface(surfaceTexture)
    private val queuingEventSink: QueuingEventSink = QueuingEventSink()
    private var eventChannel: EventChannel? = null
    private var methodChannel: MethodChannel? = null
    private var videoEvent: VideoEvent = VideoEvent()

    init {
        bindFlutter()
    }

    private fun bindFlutter(): Unit {
        val textureId: Long = textureEntry.id()
        val eventChannel = EventChannel(binaryMessenger, "$PLAYER_EVENT_CHANNEL_NAME$textureId")
        val methodChannel = MethodChannel(binaryMessenger, "$PLAYER_METHOD_CHANNEL_NAME$textureId")
        eventChannel.setStreamHandler(this)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    play()
                    result.success(null)
                }
                "pause" -> {
                    pause()
                    result.success(null)
                }
                "stop" -> {
                    stop()
                    result.success(null)
                }
                "prepare" -> {
                    prepare(call.arguments as Boolean)
                    result.success(null)
                }
                "setDataSource" -> {
                    setDataSource(call.arguments as Map<String, Any>)
                    result.success(null)
                }
                "seekTo" -> {
                    seekTo((call.arguments as Int).toLong())
                    result.success(null)
                }
                "setSpeed" -> {
                    setSpeed((call.arguments as Double).toFloat())
                    result.success(null)
                }
                "setLoop" -> {
                    setLoop(call.arguments as Boolean)
                    result.success(null)
                }
                "setHardwareDecoderEnable" -> {
                    setHardwareDecoderEnable(call.arguments as Boolean)
                    result.success(null)
                }
                "enterPip" -> {
                    result.success(enterPip())
                }
                "openSettings" -> {
                    openSettings()
                    result.success(null)
                }
                "release" -> {
                    release()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

    }

    private fun createPlayer(): Unit {
        player = AliPlayerFactory.createAliPlayer(context)
        val config = player!!.config
        config.mMaxBufferDuration = 1000 * 60 * 10
        config.mMaxBackwardBufferDurationMs = 1 * 60 * 10
        player!!.config = config
        player!!.volume = 1.0f
        videoEvent = videoEvent.copy(
            featurePictureInPicture = activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
        )
        sendEvent()
        setupPlayer()
    }

    private fun setupPlayer(): Unit {
        player?.setSurface(surface)
        player?.setOnVideoSizeChangedListener { i, i2 ->
            surfaceTexture.setDefaultBufferSize(i, i2)
            videoEvent = videoEvent.copy(
                width = i,
                height = i2
            )
            sendEvent()
        }
        player?.setOnPreparedListener {
            videoEvent = videoEvent.copy(
                duration = player!!.duration,
                playSpeed = player!!.speed,
                ready = true,
            )
            sendEvent()
        }
        player?.setOnStateChangedListener {
            videoEvent = videoEvent.copy(
                state = it,
            )
            sendEvent()
        }
        player?.setOnErrorListener {
            videoEvent = videoEvent.copy(
                errorDescription = "${it.code}: ${it.msg}"
            )
            sendEvent()
//            stop()
        }
        player?.setOnCompletionListener {
//            stop()
        }
        player?.setOnInfoListener {
            when (it.code) {
                InfoCode.CurrentPosition -> {
                    videoEvent = videoEvent.copy(
                        position = it.extraValue,
                    )
                    sendEvent()
                }
                InfoCode.CurrentDownloadSpeed -> {
                    videoEvent = videoEvent.copy(
                        bufferingSpeed = it.extraValue,
                    )
                    sendEvent()
                }
                InfoCode.BufferedPosition -> {
                    videoEvent = videoEvent.copy(
                        buffered = it.extraValue,
                    )
                    sendEvent()
                }
                InfoCode.SwitchToSoftwareVideoDecoder -> {
                    videoEvent = videoEvent.copy(
                        enableHardwareDecoder = false,
                    )
                    sendEvent()
                }
                else -> {}
            }
        }
        player?.setOnLoadingStatusListener(object : IPlayer.OnLoadingStatusListener {
            override fun onLoadingBegin() {
                videoEvent = videoEvent.copy(
                    isBuffering = true,
                    bufferingPercentage = 0
                )
                sendEvent()
            }

            override fun onLoadingProgress(p0: Int, p1: Float) {
                videoEvent = videoEvent.copy(
                    bufferingPercentage = p0,
                )
                sendEvent()

            }

            override fun onLoadingEnd() {
                videoEvent = videoEvent.copy(
                    isBuffering = false
                )
                sendEvent()
            }

        })
    }

    private fun resetValue(): Unit {
        videoEvent = videoEvent.copy(
            state = IPlayer.idle,
            position = 0,
            duration = 0,
            isBuffering = false,
            buffered = 0,
            bufferingSpeed = 0,
            bufferingPercentage = 0,
            errorDescription = "",
        )
        stop();
        videoEvent = VideoEvent().copy(
            featurePictureInPicture = videoEvent.featurePictureInPicture,
        )
        sendEvent()
    }

    private fun setDataSource(config: Map<String, Any>): Unit {
        val urlSource = UrlSource()
        urlSource.uri = config["url"] as String
        if (player != null) {
            resetValue();
            val playerConfig: PlayerConfig = player!!.config;
            val userAgent: String? = config["userAgent"] as String?
            val referer: String? = config["referer"] as String?
            if (userAgent != null) {
                playerConfig.mUserAgent = userAgent
            }
            if (referer != null) {
                playerConfig.mReferrer = referer
            }
            playerConfig.customHeaders = (config["customHeaders"] as List<String>).toTypedArray()
            player!!.config = playerConfig
            player!!.setDataSource(urlSource)
        }
    }

    private fun prepare(isAutoPlay: Boolean): Unit {
        player?.isAutoPlay = isAutoPlay
        player?.prepare()
    }

    private fun play(): Unit {
        player?.start()
    }

    private fun pause(): Unit {
        player?.pause()
    }

    private fun stop(): Unit {
        player?.stop()
        player?.clearScreen()
    }

    private fun seekTo(position: Long): Unit {
        player?.seekTo(position, IPlayer.SeekMode.Accurate)
        if (player != null) {
            videoEvent = videoEvent.copy(
                position = position
            )
            sendEvent()
        }
    }

    private fun setSpeed(speed: Float): Unit {
        player?.speed = speed
        if (player != null) {
            videoEvent = videoEvent.copy(
                playSpeed = speed
            )
            sendEvent()
        }
    }

    private fun setLoop(loop: Boolean): Unit {
        player?.isLoop = loop
        if (player != null) {
            videoEvent = videoEvent.copy(
                loop = player!!.isLoop
            )
            sendEvent()
        }
    }

    private fun setHardwareDecoderEnable(enable: Boolean): Unit {
        resetValue()
        player?.enableHardwareDecoder(enable)
        if (player != null) {
            prepare(player!!.isAutoPlay)
            videoEvent = videoEvent.copy(
                enableHardwareDecoder = enable
            )
            sendEvent()
        }
    }

    private fun release(): Unit {
        player?.setSurface(null)
        player?.release()
        surface.release()
        player = null
        queuingEventSink.endOfStream()
        eventChannel?.setStreamHandler(null)
        methodChannel?.setMethodCallHandler(null)
        eventChannel = null
        methodChannel = null
    }

    private fun sendEvent(): Unit {
        queuingEventSink.success(videoEvent.toMap())
    }

    private fun enterPip(): Boolean {
        when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O -> {
                var builder: PictureInPictureParams.Builder =
                    PictureInPictureParams.Builder()
                        .setAspectRatio(Rational(16, 9))
                        .setSourceRectHint(Rect(0, 0, 0, 0))
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    builder = builder.setSeamlessResizeEnabled(true)
                }
                return activity.enterPictureInPictureMode(
                    builder.build()
                )
            }
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.N -> {
                activity.enterPictureInPictureMode();
                return true;
            }
            else -> {
                return false;
            }
        }
    }
    private fun openSettings(): Unit {
        Toast.makeText(
            context, "请在设置-画中画, 选择本App, 允许进入画中画模式", Toast.LENGTH_SHORT
        ).show()
        activity.startActivity(Intent(Settings.ACTION_SETTINGS))
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        queuingEventSink.setDelegate(events);
        createPlayer();
    }

    override fun onCancel(arguments: Any?) {
        queuingEventSink.setDelegate(null);
    }
}