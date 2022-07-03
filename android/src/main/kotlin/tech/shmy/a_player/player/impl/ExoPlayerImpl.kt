package tech.shmy.a_player.player.impl

import android.content.Context
import android.media.session.PlaybackState
import android.net.Uri
import android.os.Handler
import android.view.Surface
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.source.dash.DashMediaSource
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.source.smoothstreaming.DefaultSsChunkSource
import com.google.android.exoplayer2.source.smoothstreaming.SsMediaSource
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultDataSource
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource
import com.google.android.exoplayer2.util.Util
import com.google.android.exoplayer2.video.VideoSize
import tech.shmy.a_player.player.APlayerInterface
import tech.shmy.a_player.player.APlayerListener


class ExoPlayerImpl(
    private val context: Context
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

    override fun setUrlDataSource(url: String) {
        exoPlayer.stop()
        exoPlayer.clearMediaItems()
        val uri = Uri.parse(url)
        val dataSourceFactory: DataSource.Factory = if (isHTTP(uri)) {
            // TODO: 设置header userAgent
            val httpDataSourceFactory = DefaultHttpDataSource.Factory()
                .setUserAgent("ExoPlayer")
                .setAllowCrossProtocolRedirects(true)
//            if (httpHeaders != null && !httpHeaders.isEmpty()) {
//                httpDataSourceFactory.setDefaultRequestProperties(httpHeaders)
//            }
            httpDataSourceFactory
        } else {
            DefaultDataSource.Factory(context)
        }
        val mediaSource = buildMediaSource(Uri.parse(url), dataSourceFactory, context)
        exoPlayer.setMediaSource(mediaSource)
    }

    override fun setFileDataSource(path: String) {
        TODO("Not yet implemented")
    }

    override fun enableHardwareDecoder(enabled: Boolean) {
        // can't enable
    }

    override fun release(): Unit {
        exoPlayer.setVideoSurface(null)
        exoPlayer.stop()
        exoPlayer.release()
        handler = null
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
        listener?.setOnPlayingListener(isPlaying)
    }

//    override fun onIsLoadingChanged(isLoading: Boolean) {
//        if (isLoading) {
//            listener?.setOnLoadingBeginListener()
//        } else {
//            listener?.setOnLoadingEndListener()
//        }
//    }

    override fun onPlaybackStateChanged(playbackState: Int) {
        when (playbackState) {
            Player.STATE_IDLE -> {}
            Player.STATE_BUFFERING -> {
                listener?.setOnLoadingBeginListener()
                listener?.setOnLoadingProgressListener(exoPlayer.bufferedPercentage)
                listener?.setOnBufferedPositionChangedListener(exoPlayer.bufferedPosition)
            }
            Player.STATE_READY -> {
                listener?.setOnInitializedListener()
            }
            Player.STATE_ENDED -> {
                listener?.setOnCompletionListener()
            }
        }
        if (playbackState != Player.STATE_BUFFERING) {
            listener?.setOnLoadingEndListener()
        }
    }

    override fun onPlayerError(error: PlaybackException) {
        listener?.setOnErrorListener(error.errorCodeName, error.message.toString())
    }

    override fun onVideoSizeChanged(videoSize: VideoSize) {
        listener?.setOnVideoSizeChangedListener(videoSize.width, videoSize.height)
    }

    override fun onRenderedFirstFrame() {
        listener?.setOnReadyToPlayListener()
    }

    override fun run() {
        if (exoPlayer.isPlaying) {
            listener?.setOnCurrentPositionChangedListener(exoPlayer.currentPosition)
        }
        handler?.postDelayed(this, 500);
    }

    private fun buildMediaSource(
        uri: Uri, mediaDataSourceFactory: DataSource.Factory, context: Context
    ): MediaSource {
        return when (val type: Int =
            Util.inferContentTypeForExtension(uri.lastPathSegment.toString())) {
            C.CONTENT_TYPE_SS -> SsMediaSource.Factory(
                DefaultSsChunkSource.Factory(mediaDataSourceFactory),
                DefaultDataSource.Factory(context, mediaDataSourceFactory)
            )
                .createMediaSource(MediaItem.fromUri(uri))
            C.CONTENT_TYPE_DASH -> DashMediaSource.Factory(
                DefaultDashChunkSource.Factory(mediaDataSourceFactory),
                DefaultDataSource.Factory(context, mediaDataSourceFactory)
            )
                .createMediaSource(MediaItem.fromUri(uri))
            C.CONTENT_TYPE_HLS -> HlsMediaSource.Factory(mediaDataSourceFactory)
                .createMediaSource(MediaItem.fromUri(uri))
            C.CONTENT_TYPE_OTHER -> ProgressiveMediaSource.Factory(mediaDataSourceFactory)
                .createMediaSource(MediaItem.fromUri(uri))
            else -> {
                throw IllegalStateException("Unsupported type: $type")
            }
        }
    }

    private fun isHTTP(uri: Uri?): Boolean {
        if (uri == null || uri.scheme == null) {
            return false
        }
        val scheme = uri.scheme
        return scheme == "http" || scheme == "https"
    }
}