package tech.shmy.a_player.player.impl

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.view.Surface
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.analytics.AnalyticsListener
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
import com.google.android.exoplayer2.upstream.FileDataSource
import com.google.android.exoplayer2.util.Util
import com.google.android.exoplayer2.video.VideoSize
import tech.shmy.a_player.player.APlayerInterface
import tech.shmy.a_player.player.APlayerListener
import tech.shmy.a_player.player.APlayerUtil


class ExoPlayerImpl(
    private val context: Context
) : Player.Listener, APlayerInterface, Runnable {
    private val exoPlayer: ExoPlayer = ExoPlayer.Builder(context).setLoadControl(
        DefaultLoadControl.Builder()
            .setBufferDurationsMs(600 * 1000, 600 * 1000, 1000, 1000)
            .build()
    ).build()
    private var listener: APlayerListener? = null
    private var _speed: Float = 1.0F
    private var handler: Handler? = null

    init {
        exoPlayer.contentBufferedPosition
        exoPlayer.addListener(this)
        exoPlayer.addAnalyticsListener(object : AnalyticsListener {
            override fun onBandwidthEstimate(
                eventTime: AnalyticsListener.EventTime,
                totalLoadTimeMs: Int,
                totalBytesLoaded: Long,
                bitrateEstimate: Long
            ) {
                listener?.onCurrentDownloadSpeedChangedListener(bitrateEstimate / 8)
                super.onBandwidthEstimate(
                    eventTime,
                    totalLoadTimeMs,
                    totalBytesLoaded,
                    bitrateEstimate
                )
            }
        })
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

    private fun willSetDataSource() {
        exoPlayer.stop()
        exoPlayer.clearMediaItems()
    }

    override fun setHttpDataSource(
        url: String,
        startAtPositionMs: Long,
        headers: Map<String, String>
    ) {
        willSetDataSource()
        var userAgent = "ExoPlayer"
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
        val dataSourceFactory: DataSource.Factory = DefaultHttpDataSource.Factory()
            .setUserAgent(userAgent)
            .setAllowCrossProtocolRedirects(true)
            .setKeepPostFor302Redirects(true)
            .setDefaultRequestProperties(customHeaders)
        val mediaSource = buildMediaSource(Uri.parse(url), dataSourceFactory, context)
        exoPlayer.setMediaSource(mediaSource)
        exoPlayer.seekTo(startAtPositionMs)
    }

    override fun setFileDataSource(path: String, startAtPositionMs: Long) {
        willSetDataSource()
        val dataSourceFactory: DataSource.Factory = FileDataSource.Factory()
        val mediaSource = buildMediaSource(Uri.parse(path), dataSourceFactory, context)
        exoPlayer.setMediaSource(mediaSource)
        exoPlayer.seekTo(startAtPositionMs)
    }

    override fun release() {
        handler = null
        listener = null
        exoPlayer.clearVideoSurface()
        exoPlayer.setVideoSurface(null)
        exoPlayer.stop()
        exoPlayer.release()
    }

    override fun prepare() {
        exoPlayer.playWhenReady = false
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

    private fun buildMediaSource(
        uri: Uri, mediaDataSourceFactory: DataSource.Factory, context: Context
    ): MediaSource {
        return when (Util.inferContentType(uri)) {
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
//            C.CONTENT_TYPE_OTHER -> ProgressiveMediaSource.Factory(mediaDataSourceFactory)
//                .createMediaSource(MediaItem.fromUri(uri))
            else -> ProgressiveMediaSource.Factory(mediaDataSourceFactory)
                .createMediaSource(MediaItem.fromUri(uri))
        }
    }

    override fun run() {
        listener?.onCurrentPositionChangedListener(exoPlayer.currentPosition)
        listener?.onLoadingProgressListener(exoPlayer.bufferedPercentage)
        listener?.onBufferedPositionChangedListener(exoPlayer.bufferedPosition)
        handler?.postDelayed(this, 500)
    }
}