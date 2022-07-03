package tech.shmy.a_player.player.impl

import android.content.Context
import android.media.session.PlaybackState
import android.os.Handler
import android.view.Surface
import com.google.android.exoplayer2.Player
import tech.shmy.a_player.player.APlayerInterface
import tech.shmy.a_player.player.APlayerListener
import tv.danmaku.ijk.media.player.IMediaPlayer
import tv.danmaku.ijk.media.player.IjkMediaPlayer

class IJKPlayerImpl(
    private val context: Context
) : Player.Listener, APlayerInterface, Runnable {

    private val ijkMediaPlayer: IjkMediaPlayer = IjkMediaPlayer()
    private var _speed: Float = 1.0F
    private var _isAutoPlay: Boolean = false
    private var listener: APlayerListener? = null
    private var handler: Handler? = null
    private lateinit var surface: Surface

    init {
        ijkMediaPlayer.setOnVideoSizeChangedListener { iMediaPlayer, i, i2, i3, i4 ->
            listener?.setOnVideoSizeChangedListener(i, i2)
        }
        ijkMediaPlayer.setOnPreparedListener {
            listener?.setOnInitializedListener()
        }
        ijkMediaPlayer.setOnInfoListener { iMediaPlayer, i, i2 ->
            when (i) {
                IMediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START -> {
                    listener?.setOnReadyToPlayListener()
                }
                IMediaPlayer.MEDIA_INFO_BUFFERING_START -> {
                    listener?.setOnLoadingBeginListener()
                }
                IMediaPlayer.MEDIA_INFO_BUFFERING_END -> {
                    listener?.setOnLoadingEndListener()
                }
                IMediaPlayer.MEDIA_INFO_NETWORK_BANDWIDTH -> {
                    listener?.setOnCurrentDownloadSpeedChangedListener(i2.toLong())
                }
            }
            true
        }
        ijkMediaPlayer.setOnBufferingUpdateListener { iMediaPlayer, i ->
            listener?.setOnLoadingProgressListener(if (i > 100) 100 else i)
        }
        ijkMediaPlayer.setOnErrorListener { iMediaPlayer, i, i2 ->
            listener?.setOnErrorListener(i.toString(), i2.toString())
            true
        }
        ijkMediaPlayer.setOnCompletionListener {
            listener?.setOnCompletionListener()
        }
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

    override fun setUrlDataSource(url: String) {
        ijkMediaPlayer.reset()
        ijkMediaPlayer.setSurface(surface)
        // TODO: headers, userAgent, referer
        ijkMediaPlayer.setOption(
            IjkMediaPlayer.OPT_CATEGORY_FORMAT,
            "user_agent",
            "headers.get(key)"
        );
        ijkMediaPlayer.setOption(
            IjkMediaPlayer.OPT_CATEGORY_PLAYER,
            "seek-at-start",
            10000
        );
        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "reconnect", 5);
        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "framedrop", 5);
        ijkMediaPlayer.setOption(
            IjkMediaPlayer.OPT_CATEGORY_PLAYER,
            "max_cached_duration",
            10 * 60 * 1000
        );
        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max-fps", 30);
        ijkMediaPlayer.setDataSource(url, mapOf());
    }

    override fun setFileDataSource(path: String) {
        TODO("Not yet implemented")
    }

    override fun enableHardwareDecoder(enabled: Boolean) {
        TODO("Not yet implemented")
    }

    override fun release() {
        ijkMediaPlayer.setSurface(null)
        ijkMediaPlayer.stop()
        ijkMediaPlayer.release()
        handler = null
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
        if (ijkMediaPlayer.isPlaying) {
            listener?.setOnCurrentPositionChangedListener(ijkMediaPlayer.currentPosition)
            listener?.setOnCurrentDownloadSpeedChangedListener(ijkMediaPlayer.tcpSpeed)

        }
        handler?.postDelayed(this, 500);
    }
}