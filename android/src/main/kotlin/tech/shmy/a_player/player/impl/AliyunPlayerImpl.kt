package tech.shmy.a_player.player.impl

import android.content.Context
import android.view.Surface
import com.aliyun.player.AliPlayer
import com.aliyun.player.AliPlayerFactory
import com.aliyun.player.IPlayer
import com.aliyun.player.bean.InfoCode
import com.aliyun.player.source.UrlSource
import tech.shmy.a_player.player.APlayerHeader
import tech.shmy.a_player.player.APlayerInterface
import tech.shmy.a_player.player.APlayerListener
import tech.shmy.a_player.player.APlayerUtil

class AliyunPlayerImpl(context: Context) : APlayerInterface {
    private val aliPlayer: AliPlayer = AliPlayerFactory.createAliPlayer(context)
    private var listener: APlayerListener? = null

    init {
        aliPlayer.setOnVideoSizeChangedListener { width, height ->
            listener?.onVideoSizeChangedListener(width, height)
        }
        aliPlayer.setOnPreparedListener {
            listener?.onInitializedListener()
        }
        aliPlayer.setOnRenderingStartListener {
            listener?.onReadyToPlayListener()
        }
        aliPlayer.setOnStateChangedListener {
            when (it) {
                IPlayer.started -> {
                    listener?.onPlayingListener(true)
                }
                else -> {
                    listener?.onPlayingListener(false)
                }
            }
        }
        aliPlayer.setOnErrorListener {
            listener?.onErrorListener(it.code.name, it.msg)
        }
        aliPlayer.setOnCompletionListener {
            listener?.onCompletionListener()
        }
        aliPlayer.setOnInfoListener { it ->
            when (it.code) {
                InfoCode.CurrentPosition -> {
                    listener?.onCurrentPositionChangedListener(it.extraValue)
                }
                InfoCode.CurrentDownloadSpeed -> {
                    listener?.onCurrentDownloadSpeedChangedListener(it.extraValue)
                }
                InfoCode.BufferedPosition -> {
                    listener?.onBufferedPositionChangedListener(it.extraValue)
                }
                InfoCode.SwitchToSoftwareVideoDecoder -> {
                    listener?.onSwitchToSoftwareVideoDecoderListener()
                }
            }

        }
        aliPlayer.setOnLoadingStatusListener(object : IPlayer.OnLoadingStatusListener {
            override fun onLoadingBegin() {
                listener?.onLoadingBeginListener()
            }

            override fun onLoadingProgress(p0: Int, p1: Float) {
                listener?.onLoadingProgressListener(p0)
            }

            override fun onLoadingEnd() {
                listener?.onLoadingEndListener()
            }
        })
    }

    companion object {
        fun createPlayer(context: Context): APlayerInterface {
            return AliyunPlayerImpl(context)
        }
    }

    override val duration: Long
        get() = aliPlayer.duration
    override val speed: Float
        get() = aliPlayer.speed
    override val isLoop: Boolean
        get() = aliPlayer.isLoop
    override val isAutoPlay: Boolean
        get() = aliPlayer.isAutoPlay

    override fun addListener(listener: APlayerListener): Unit {
        this.listener = listener
    }

    override fun setSurface(surface: Surface) {
        aliPlayer.setSurface(surface)
    }

    override fun play(): Unit {
        aliPlayer.start()
    }

    override fun pause(): Unit {
        aliPlayer.pause()
    }

    override fun stop(): Unit {
        aliPlayer.stop()
    }

    override fun setHttpDataSource(url: String, startAtPositionMs: Long, headers: Array<APlayerHeader>): Unit {
        val config = aliPlayer.config
        config.mMaxBufferDuration = 1000 * 60 * 10
        config.mMaxBackwardBufferDurationMs = 1 * 60 * 10
        var userAgent: String? = null
        var referer: String? = null
        val customHeaders: ArrayList<String> = ArrayList()
        headers.forEach { header ->
            when {
                APlayerUtil.isUserAgentKey(header.key) -> {
                    userAgent = header.value
                }
                APlayerUtil.isRefererKey(header.key) -> {
                    referer = header.value
                }
                else -> {
                    customHeaders.add("${header.key}:${header.value}")
                }
            }
        }
        if (userAgent != null) {
            config.mUserAgent = userAgent
        }
        if (referer != null) {
            config.mReferrer = referer
        }
        config.customHeaders = customHeaders.toTypedArray()
        aliPlayer.config = config
        aliPlayer.volume = 1.0f
        val urlSource = UrlSource()
        urlSource.uri = url
        aliPlayer.setDataSource(urlSource)
        aliPlayer.seekTo(startAtPositionMs)
    }

    override fun setFileDataSource(path: String, startAtPositionMs: Long) {
        TODO("Not yet implemented")
    }

    override fun setAssetDataSource(path: String, startAtPositionMs: Long) {
        TODO("Not yet implemented")
    }

    override fun enableHardwareDecoder(enabled: Boolean) {
        aliPlayer.enableHardwareDecoder(enabled)
    }

    override fun release(): Unit {
        listener = null
        aliPlayer.setSurface(null)
        aliPlayer.stop()
        aliPlayer.release()
    }

    override fun prepare(isAutoPlay: Boolean): Unit {
        aliPlayer.isAutoPlay = isAutoPlay
        aliPlayer.prepare()
    }

    override fun seekTo(positionMs: Long): Unit {
        aliPlayer.seekTo(positionMs, IPlayer.SeekMode.Accurate)
    }

    override fun setSpeed(speed: Float): Unit {
        aliPlayer.speed = speed
    }

    override fun setLoop(isLoop: Boolean): Unit {
        aliPlayer.isLoop = isLoop
    }
}