package tech.shmy.a_player

import android.app.Activity
import android.app.PictureInPictureParams
import android.content.Context
import android.content.Intent
import android.graphics.Color
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
) : EventChannel.StreamHandler {
    private var kernel: Int? = null;
    private var player: APlayerInterface? = null
    private val surfaceTexture: SurfaceTexture = textureEntry.surfaceTexture()
    private var surface: Surface? = null
    private val queuingEventSink: QueuingEventSink = QueuingEventSink()
    private var eventChannel: EventChannel? = null
    private var methodChannel: MethodChannel? = null

    init {
        bindFlutter()
    }

    private fun bindFlutter() {
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
                    prepare()
                    result.success(null)
                }
                "restart" -> {
                    restart()
                    result.success(null)
                }
                "setDataSource" -> {
                    setDataSource(call.arguments as MutableMap<String, Any>)
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

    private fun createPlayer() {
        queuingEventSink.success(
            mapOf(
                "type" to "initializing"
            )
        )
        player?.release()
        player = null
        when (kernel) {
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

        queuingEventSink.success(
            mapOf(
                "type" to "initialized",
                "data" to kernel
            )
        )
    }

    private fun setupPlayer() {
        player?.addListener(object : APlayerListener {
            override fun onVideoSizeChangedListener(width: Int, height: Int) {
                surfaceTexture.setDefaultBufferSize(width, height)
                queuingEventSink.success(
                    mapOf(
                        "type" to "videoSizeChanged",
                        "data" to mapOf(
                            "height" to height,
                            "width" to width,
                        )
                    )
                )
            }

            override fun onPlayingListener(isPlaying: Boolean) {
                queuingEventSink.success(
                    mapOf(
                        "type" to "playing",
                        "data" to isPlaying,
                    )
                )
            }

            override fun onReadyToPlayListener() {
                queuingEventSink.success(
                    mapOf(
                        "type" to "readyToPlay",
                        "data" to mapOf(
                            "duration" to player!!.duration,
                            "playSpeed" to player!!.speed,
                        )
                    )
                )
            }

            override fun onErrorListener(code: String, message: String) {
                queuingEventSink.success(
                    mapOf(
                        "type" to "error",
                        "data" to "$code: $message"
                    )
                )
            }

            override fun onCompletionListener() {
                queuingEventSink.success(
                    mapOf(
                        "type" to "completion",
                    )
                )
            }

            override fun onCurrentPositionChangedListener(position: Long) {
                queuingEventSink.success(
                    mapOf(
                        "type" to "currentPositionChanged",
                        "data" to position
                    )
                )
            }

            override fun onCurrentDownloadSpeedChangedListener(speed: Long) {
                queuingEventSink.success(
                    mapOf(
                        "type" to "currentDownloadSpeedChanged",
                        "data" to speed
                    )
                )
            }

            override fun onBufferedPositionChangedListener(buffered: Long) {
                queuingEventSink.success(
                    mapOf(
                        "type" to "bufferedPositionChanged",
                        "data" to buffered
                    )
                )
            }

            override fun onLoadingBeginListener() {
                queuingEventSink.success(
                    mapOf(
                        "type" to "loadingBegin",
                    )
                )
            }

            override fun onLoadingProgressListener(percent: Int) {
                queuingEventSink.success(
                    mapOf(
                        "type" to "loadingProgress",
                        "data" to percent,
                    )
                )
            }

            override fun onLoadingEndListener() {
                queuingEventSink.success(
                    mapOf(
                        "type" to "loadingEnd",
                    )
                )
            }
        })
        setSurface()
    }

    private fun setSurface() {
        val canvas = surface?.lockCanvas(null)
        canvas?.drawColor(Color.BLACK)
        surface?.unlockCanvasAndPost(canvas)
        surface?.release()
        surface = Surface(surfaceTexture)
        player?.setSurface(surface!!)
    }

    private fun restart() {
        seekTo(0)
        play()
    }

    private fun setDataSource(
       args: Map<String, Any>
    ) {
        val kernel = args["kernel"] as Int
        val url = args["url"] as String
        val position = (args["position"] as Int).toLong()
        val httpHeaders = args["httpHeaders"] as Map<String, String>
        setKernel(kernel)
        if (APlayerUtil.isHttpProtocol(url)) {
            player?.setHttpDataSource(
                url,
                position, httpHeaders
            )
        } else if (APlayerUtil.isFileProtocol(url)) {
            player?.setFileDataSource(url, position)
        }
    }

    private fun prepare() {
        player?.prepare()
    }

    private fun play() {
        player?.play()
    }

    private fun pause() {
        player?.pause()
    }

    private fun stop() {
        player?.stop()
    }

    private fun setKernel(kernel: Int) {
        if (kernel == this.kernel) {
            return
        }
        this.kernel = kernel
        createPlayer()
    }

    private fun seekTo(position: Long) {
        player?.seekTo(position)
    }

    private fun setSpeed(speed: Float) {
        player?.setSpeed(speed)
    }

    private fun setLoop(isLoop: Boolean) {
        player?.setLoop(isLoop)
    }

    private fun release() {
        player?.release()
        player = null
        queuingEventSink.endOfStream()
        eventChannel?.setStreamHandler(null)
        methodChannel?.setMethodCallHandler(null)
        eventChannel = null
        methodChannel = null
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
                activity.enterPictureInPictureMode()
                return true
            }
            else -> {
                return false
            }
        }
    }

    private fun openSettings() {
        Toast.makeText(
            context, "请在设置-画中画, 选择本App, 允许进入画中画模式", Toast.LENGTH_SHORT
        ).show()
        activity.startActivity(Intent(Settings.ACTION_SETTINGS))
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        queuingEventSink.setDelegate(events)
    }

    override fun onCancel(arguments: Any?) {
        queuingEventSink.setDelegate(null)
    }
}