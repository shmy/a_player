package tech.shmy.a_player

import android.content.Context
import android.graphics.SurfaceTexture
import android.util.Log
import android.view.Surface
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
                "play" -> play()
                "pause" -> pause()
                "reload" -> reload()
                "stop" -> stop()
                "prepare" -> prepare(call.arguments as Boolean)
                "setNetworkDataSource" -> {
                    setNetworkDataSource(call.arguments as String)
                }
                "seekTo" -> {
                    seekTo((call.arguments as Int).toLong())
                }
                "setSpeed" -> {
                    setSpeed((call.arguments as Double).toFloat())
                }
                "setMirrorMode" -> {
                    setMirrorMode(call.arguments as Int)
                }
                "setLoop" -> {
                    setLoop(call.arguments as Boolean)
                }
                "setHardwareDecoderEnable" -> {
                    setHardwareDecoderEnable(call.arguments as Boolean)
                }
                "setConfig" -> {
                    setConfig(call.arguments as Map<String, Any>)
                }
                "release" -> release()
            }
            result.success(null)
        }
    }

    private fun createPlayer(): Unit {
        player = AliPlayerFactory.createAliPlayer(context)
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
                    bufferingSpeed = p1
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

    private fun setConfig(config: Map<String, Any>): Unit {
        if (player != null) {
            val playerConfig: PlayerConfig = player!!.config;
            val userAgent: String? = config["userAgent"] as String?
            val referer: String? = config["referer"] as String?
            if (userAgent != null) {
                playerConfig.mUserAgent = userAgent
            }
            if (referer != null) {
                playerConfig.mReferrer = referer
            }
            player!!.config = playerConfig
        }
    }

    private fun setNetworkDataSource(url: String): Unit {
        val urlSource = UrlSource()
        urlSource.uri = url
        player?.setDataSource(urlSource)
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

    private fun reload(): Unit {
        player?.reload()
    }

    private fun stop(): Unit {
        player?.stop()
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

    private fun setMirrorMode(mode: Int): Unit {
        when (mode) {
            IPlayer.MirrorMode.MIRROR_MODE_HORIZONTAL.value -> player?.mirrorMode =
                IPlayer.MirrorMode.MIRROR_MODE_HORIZONTAL
            IPlayer.MirrorMode.MIRROR_MODE_VERTICAL.value -> player?.mirrorMode =
                IPlayer.MirrorMode.MIRROR_MODE_VERTICAL
            else -> player?.mirrorMode = IPlayer.MirrorMode.MIRROR_MODE_NONE
        }
        if (player != null) {
            videoEvent = videoEvent.copy(
                mirrorMode = player!!.mirrorMode.value
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
        player?.reload()
        player?.enableHardwareDecoder(enable)
        if (player != null) {
            prepare(player!!.isAutoPlay)
            videoEvent = VideoEvent().copy(
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
        queuingEventSink.success(
            mapOf(
                "state" to videoEvent.state,
                "errorDescription" to videoEvent.errorDescription,
                "width" to videoEvent.width,
                "height" to videoEvent.height,
                "duration" to videoEvent.duration,
                "position" to videoEvent.position,
                "playSpeed" to videoEvent.playSpeed,
                "mirrorMode" to videoEvent.mirrorMode,
                "loop" to videoEvent.loop,
                "enableHardwareDecoder" to videoEvent.enableHardwareDecoder,
                "isBuffering" to videoEvent.isBuffering,
                "buffered" to videoEvent.buffered,
                "bufferingPercentage" to videoEvent.bufferingPercentage,
                "bufferingSpeed" to videoEvent.bufferingSpeed,
            )
        )
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        queuingEventSink.setDelegate(events);
        createPlayer();
    }

    override fun onCancel(arguments: Any?) {
        queuingEventSink.setDelegate(null);
    }
}