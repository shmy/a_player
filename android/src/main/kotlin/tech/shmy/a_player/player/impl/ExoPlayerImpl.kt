package tech.shmy.a_player.player.impl

import android.content.Context
import android.os.Handler
import android.view.Surface
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.video.VideoSize
import tech.shmy.a_player.player.APlayerHeader
import tech.shmy.a_player.player.APlayerInterface
import tech.shmy.a_player.player.APlayerListener


class ExoPlayerImpl(
    context: Context
) : Player.Listener, APlayerInterface, Runnable {
    private val exoPlayer: ExoPlayer = ExoPlayer.Builder(context).build()
    private var listener: APlayerListener? = null
    private var _speed: Float = 1.0F
    private var handler: Handler? = null

    init {
        exoPlayer.addListener(this)
    }

    companion object {
        fun createPlayer(context: Context): APlayerInterface {
            return ExoPlayerImpl(context)
        }
    }

    override val duration: Long
        get() = exoPlayer.duration
    override val speed: Float
        get() = _speed
    override val isLoop: Boolean
        get() = exoPlayer.repeatMode == Player.REPEAT_MODE_ONE
    override val isAutoPlay: Boolean
        get() = exoPlayer.playWhenReady

    override fun addListener(listener: APlayerListener) {
        this.listener = listener
        handler = Handler()
        handler!!.post(this)
    }

    override fun setSurface(surface: Surface) {
        exoPlayer.setVideoSurface(surface)
    }

    override fun play() {
        exoPlayer.play()
    }

    override fun pause() {
        exoPlayer.pause()
    }

    override fun stop() {
        exoPlayer.stop()
    }

    override fun setHttpDataSource(url: String, startAtPositionMs: Long, headers: Array<APlayerHeader>) {
        exoPlayer.stop()
        exoPlayer.clearMediaItems()
        exoPlayer.setMediaItem(MediaItem.fromUri(url))
        exoPlayer.seekTo(startAtPositionMs)
    }

    override fun setFileDataSource(path: String, startAtPositionMs: Long) {
        TODO("Not yet implemented")
    }

    override fun setAssetDataSource(path: String, startAtPositionMs: Long) {
        TODO("Not yet implemented")
    }

    override fun enableHardwareDecoder(enabled: Boolean) {
        // can't enable
    }

    override fun release(): Unit {
        handler = null
        exoPlayer.setVideoSurface(null)
        exoPlayer.stop()
        exoPlayer.release()
    }

    override fun prepare(isAutoPlay: Boolean) {
        exoPlayer.playWhenReady = isAutoPlay
        exoPlayer.prepare()
    }

    override fun seekTo(positionMs: Long) {
        exoPlayer.seekTo(positionMs)
    }

    override fun setSpeed(speed: Float) {
        _speed = speed
        exoPlayer.setPlaybackSpeed(speed)
    }

    override fun setLoop(isLoop: Boolean) {
        val repeatMode = if (isLoop) Player.REPEAT_MODE_ONE else Player.REPEAT_MODE_OFF
        exoPlayer.repeatMode = repeatMode
    }

    override fun onIsPlayingChanged(isPlaying: Boolean) {
        listener?.onPlayingListener(isPlaying)
    }

    override fun onPlaybackStateChanged(playbackState: Int) {
        when (playbackState) {
            Player.STATE_IDLE -> {}
            Player.STATE_BUFFERING -> {
                listener?.onLoadingBeginListener()
                listener?.onLoadingProgressListener(exoPlayer.bufferedPercentage)
                listener?.onBufferedPositionChangedListener(exoPlayer.bufferedPosition)
            }
            Player.STATE_READY -> {
                listener?.onInitializedListener()
            }
            Player.STATE_ENDED -> {
                listener?.onCompletionListener()
            }
        }
        if (playbackState != Player.STATE_BUFFERING) {
            listener?.onLoadingEndListener()
        }
    }

    override fun onPlayerError(error: PlaybackException) {
        listener?.onErrorListener(error.errorCodeName, error.message.toString())
    }

    override fun onVideoSizeChanged(videoSize: VideoSize) {
        listener?.onVideoSizeChangedListener(videoSize.width, videoSize.height)
    }

    override fun onRenderedFirstFrame() {
        listener?.onReadyToPlayListener()
    }

    override fun run() {
        if (exoPlayer.isPlaying) {
            listener?.onCurrentPositionChangedListener(exoPlayer.currentPosition)
        }
        handler?.postDelayed(this, 500);
    }
}