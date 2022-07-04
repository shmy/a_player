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
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry
import tech.shmy.a_player.player.*
import tech.shmy.a_player.player.impl.AliyunPlayerImpl
import tech.shmy.a_player.player.impl.ExoPlayerImpl
import tech.shmy.a_player.player.impl.IJKPlayerImpl


class APlayer(
    private val context: Context,
    private val activity: Activity,
    private val textureEntry: TextureRegistry.SurfaceTextureEntry,
    private val binaryMessenger: BinaryMessenger,
    private var kernel: Int
) : EventChannel.StreamHandler {
    private var player: APlayerInterface? = null
    private val surfaceTexture: SurfaceTexture = textureEntry.surfaceTexture()
    private val surface: Surface = Surface(surfaceTexture)
    private val queuingEventSink: QueuingEventSink = QueuingEventSink()
    private var eventChannel: EventChannel? = null
    private var methodChannel: MethodChannel? = null
    private var aPlayerEvent: APlayerEvent = APlayerEvent()
    private var lastDataSource: Map<String, Any>? = null

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
                "setKernel" -> {
                    setKernel(call.arguments as Int)
                    result.success(null)
                }
                "prepare" -> {
                    prepare(call.arguments as Boolean)
                    result.success(null)
                }
                "setDataSource" -> {
                    lastDataSource = call.arguments as Map<String, Any>
                    setDataSource(lastDataSource!!)
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
        player?.release()
        player = null
        resetValue()
        when(kernel) {
            KERNEL_ALIYUN -> {
                player = AliyunPlayerImpl.createPlayer(context)
            }
            KERNEL_IJK -> {
                player = IJKPlayerImpl.createPlayer(context)
            }
            KERNEL_EXO -> {
                player = ExoPlayerImpl.createPlayer(context)
            }
        }
        if (player == null) {
            return
        }
        setupPlayer()
    }

    private fun setupPlayer(): Unit {
        player?.setSurface(surface)
        player?.addListener(object: APlayerListener {
            override fun onVideoSizeChangedListener(width: Int, height: Int) {
                surfaceTexture.setDefaultBufferSize(width, height)
                aPlayerEvent = aPlayerEvent.copy(
                    width = width,
                    height = height
                )
                sendEvent()
            }

            override fun onInitializedListener() {
                aPlayerEvent = aPlayerEvent.copy(
                    isInitialized = true,
                )
                sendEvent()
            }

            override fun onPlayingListener(isPlaying: Boolean) {
                aPlayerEvent = aPlayerEvent.copy(
                    isPlaying = isPlaying
                )
                sendEvent()
            }

            override fun onReadyToPlayListener() {
                aPlayerEvent = aPlayerEvent.copy(
                    duration = player!!.duration,
                    playSpeed = player!!.speed,
                    isReadyToPlay = true,
                    isPlaying = true,
                    isError = false,
                    isCompletion = false,
                    isBuffering = false
                )
                sendEvent()
            }

            override fun onErrorListener(code: String, message: String) {
                aPlayerEvent = aPlayerEvent.copy(
                    isError = true,
                    errorDescription = "$code: $message"
                )
                sendEvent()
            }

            override fun onCompletionListener() {
                aPlayerEvent = aPlayerEvent.copy(
                    isCompletion = true
                )
                sendEvent()
            }

            override fun onCurrentPositionChangedListener(position: Long) {
                aPlayerEvent = aPlayerEvent.copy(
                    position = position
                )
                sendEvent()
            }

            override fun onCurrentDownloadSpeedChangedListener(speed: Long) {
                aPlayerEvent = aPlayerEvent.copy(
                    bufferingSpeed = speed
                )
                sendEvent()
            }

            override fun onBufferedPositionChangedListener(buffered: Long) {
                aPlayerEvent = aPlayerEvent.copy(
                    buffered = buffered
                )
                sendEvent()
            }
            override fun onSwitchToSoftwareVideoDecoderListener() {
                aPlayerEvent = aPlayerEvent.copy(
                    enableHardwareDecoder = false,
                )
                sendEvent()
            }

            override fun onLoadingBeginListener() {
                aPlayerEvent = aPlayerEvent.copy(
                    isBuffering = true,
                    bufferingPercentage = 0
                )
                sendEvent()
            }

            override fun onLoadingProgressListener(percent: Int) {
                aPlayerEvent = aPlayerEvent.copy(
                    bufferingPercentage = percent,
                )
                sendEvent()
            }

            override fun onLoadingEndListener() {
                aPlayerEvent = aPlayerEvent.copy(
                    isBuffering = false
                )
                sendEvent()
            }
        })
    }

    private fun resetValue(): Unit {
        aPlayerEvent = APlayerEvent().copy(
            kernel = kernel,
            featurePictureInPicture = activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
        )
        stop();
        sendEvent()
    }

    private fun setDataSource(config: Map<String, Any>): Unit {
        resetValue();
        player?.setHttpDataSource(config["url"] as String, config["position"] as Long, arrayOf<APlayerHeader>())
    }

    private fun prepare(isAutoPlay: Boolean): Unit {
        player?.prepare(isAutoPlay)
    }

    private fun play(): Unit {
        player?.play()
    }

    private fun pause(): Unit {
        player?.pause()
    }

    private fun stop(): Unit {
        player?.stop()
    }
    private fun setKernel(kernel: Int): Unit {
        if (kernel == this.kernel) {
            return
        }
        this.kernel = kernel
        val isAutoPlay = player?.isAutoPlay == true
        val positionBefore = aPlayerEvent.position
        createPlayer()
        if (lastDataSource != null) {
            setDataSource(lastDataSource!!)
            seekTo(positionBefore)
            prepare(isAutoPlay)
        }
    }

    private fun seekTo(position: Long): Unit {
        player?.seekTo(position)
        if (player != null) {
            aPlayerEvent = aPlayerEvent.copy(
                position = position
            )
            sendEvent()
        }
    }

    private fun setSpeed(speed: Float): Unit {
        player?.setSpeed(speed)
        if (player != null) {
            aPlayerEvent = aPlayerEvent.copy(
                playSpeed = speed
            )
            sendEvent()
        }
    }

    private fun setLoop(isLoop: Boolean): Unit {
        player?.setLoop(isLoop)
        if (player != null) {
            aPlayerEvent = aPlayerEvent.copy(
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
            aPlayerEvent = aPlayerEvent.copy(
                enableHardwareDecoder = enable
            )
            sendEvent()
        }
    }

    private fun release(): Unit {
        player?.release()
        player = null
        queuingEventSink.endOfStream()
        eventChannel?.setStreamHandler(null)
        methodChannel?.setMethodCallHandler(null)
        eventChannel = null
        methodChannel = null
    }

    private fun sendEvent(): Unit {
        queuingEventSink.success(aPlayerEvent.toMap())
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