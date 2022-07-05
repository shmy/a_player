package tech.shmy.a_player.player.impl

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.view.Surface
import tech.shmy.a_player.player.APlayerInterface
import tech.shmy.a_player.player.APlayerListener
import tech.shmy.a_player.player.APlayerUtil
import tv.danmaku.ijk.media.player.IMediaPlayer
import tv.danmaku.ijk.media.player.IjkMediaPlayer

class IJKPlayerImpl(private val context: Context) : APlayerInterface, Runnable {

    private var ijkMediaPlayer: IjkMediaPlayer = IjkMediaPlayer()
    private var _speed: Float = 1.0F
    private var _isAutoPlay: Boolean = false
    private var listener: APlayerListener? = null
    private var surface: Surface? = null
    private var handler: Handler? = null

    init {
        bindEvent()
    }

    companion object {
        fun createPlayer(context: Context): APlayerInterface {
            return IJKPlayerImpl(context)
        }
    }

    override val duration: Long
        get() = ijkMediaPlayer.duration
    override val speed: Float
        get() = _speed
    override val isLoop: Boolean
        get() = ijkMediaPlayer.isLooping
    override val isAutoPlay: Boolean
        get() = _isAutoPlay

    override fun addListener(listener: APlayerListener) {
        this.listener = listener
        handler = Handler()
        handler!!.post(this)
    }

    override fun setSurface(surface: Surface) {
        this.surface = surface
    }

    override fun play() {
        ijkMediaPlayer.start()
    }

    override fun pause() {
        ijkMediaPlayer.pause()
    }

    override fun stop() {
        ijkMediaPlayer.stop()
    }
    private fun willSetDataSource() {
        ijkMediaPlayer.stop()
        ijkMediaPlayer.reset()
        ijkMediaPlayer.setSurface(surface)
    }
    override fun setHttpDataSource(
        url: String,
        startAtPositionMs: Long,
        headers: Map<String, String>
    ) {
        willSetDataSource()
        var userAgent: String? = null
        val customHeaders: MutableMap<String, String> = mutableMapOf()
        headers.forEach { header ->
            when {
                APlayerUtil.isUserAgentKey(header.key) -> {
                    userAgent = header.value
                }
                else -> {
                    customHeaders[header.key] = header.value
                }
            }
        }
        if (userAgent != null) {
            ijkMediaPlayer.setOption(
                IjkMediaPlayer.OPT_CATEGORY_FORMAT,
                "user_agent",
                userAgent
            )
        }
        ijkMediaPlayer.setOption(
            IjkMediaPlayer.OPT_CATEGORY_PLAYER,
            "seek-at-start",
            startAtPositionMs
        )
        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "reconnect", 5)
        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "framedrop", 5)
        ijkMediaPlayer.setOption(
            IjkMediaPlayer.OPT_CATEGORY_PLAYER,
            "max-buffer-size",
            10 * 1024 * 1024
        )
        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max-fps", 30)

//        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "fflags", "fastseek")
//        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "enable-accurate-seek", 1)
        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec", 1) // 开硬解
        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "packet-buffering", 1)

        ijkMediaPlayer.setDataSource(url, customHeaders)
    }

    override fun setFileDataSource(path: String, startAtPositionMs: Long) {
        willSetDataSource()
        ijkMediaPlayer.setDataSource(context, Uri.parse(path))
    }

    override fun release() {
        handler = null
        listener = null
        surface = null
        ijkMediaPlayer.setSurface(null)
        removeEvent()
        ijkMediaPlayer.reset()
        ijkMediaPlayer.stop()
        ijkMediaPlayer.release()
        IjkMediaPlayer.native_profileEnd()
    }

    override fun prepare(isAutoPlay: Boolean) {
        ijkMediaPlayer.prepareAsync()
        _isAutoPlay = isAutoPlay
        if (isAutoPlay) {
            ijkMediaPlayer.start()
        }
    }

    override fun seekTo(positionMs: Long) {
        ijkMediaPlayer.seekTo(positionMs)
    }

    override fun setSpeed(speed: Float) {
        _speed = speed
        ijkMediaPlayer.setSpeed(speed)
    }

    override fun setLoop(isLoop: Boolean) {
        ijkMediaPlayer.isLooping = isLoop
    }

    override fun run() {
        listener?.onCurrentPositionChangedListener(ijkMediaPlayer.currentPosition)
        listener?.onCurrentDownloadSpeedChangedListener(ijkMediaPlayer.tcpSpeed)
//        listener?.onBufferedPositionChangedListener(ijkMediaPlayer.videoCachedDuration)
        listener?.onPlayingListener(ijkMediaPlayer.isPlaying)
        handler?.postDelayed(this, 500)
    }

    private fun bindEvent() {
        ijkMediaPlayer.setOnVideoSizeChangedListener { _, width, height, _, _ ->
            listener?.onVideoSizeChangedListener(width, height)
        }
        ijkMediaPlayer.setOnPreparedListener {
            listener?.onInitializedListener()
        }
        ijkMediaPlayer.setOnInfoListener { _, what, extraValue ->
            when (what) {
                IMediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START -> {
                    listener?.onReadyToPlayListener()
                }
                IMediaPlayer.MEDIA_INFO_BUFFERING_START -> {
                    listener?.onLoadingBeginListener()
                }
                IMediaPlayer.MEDIA_INFO_BUFFERING_END -> {
                    listener?.onLoadingEndListener()
                }
                IMediaPlayer.MEDIA_INFO_NETWORK_BANDWIDTH -> {
                    listener?.onCurrentDownloadSpeedChangedListener(extraValue.toLong())
                }
            }
            true
        }
        ijkMediaPlayer.setOnBufferingUpdateListener { _, percent ->
            listener?.onLoadingProgressListener(if (percent > 100) 100 else percent)
        }
        ijkMediaPlayer.setOnErrorListener { _, code, message ->
            listener?.onErrorListener(code.toString(), message.toString())
            true
        }
        ijkMediaPlayer.setOnCompletionListener {
            listener?.onCompletionListener()
        }
    }
    private fun removeEvent() {
        ijkMediaPlayer.resetListeners()
        ijkMediaPlayer.setOnVideoSizeChangedListener(null)
        ijkMediaPlayer.setOnPreparedListener(null)
        ijkMediaPlayer.setOnInfoListener(null)
        ijkMediaPlayer.setOnBufferingUpdateListener(null)
        ijkMediaPlayer.setOnErrorListener(null)
        ijkMediaPlayer.setOnCompletionListener(null)
    }
}