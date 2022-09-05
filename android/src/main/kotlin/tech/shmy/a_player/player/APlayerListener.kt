package tech.shmy.a_player.player

interface APlayerListener {
    fun onPlayingListener(isPlaying: Boolean)
    fun onErrorListener(code: String, message: String)
    fun onCompletionListener()
    fun onReadyToPlayListener()
    fun onVideoSizeChangedListener(width: Int, height: Int)
    fun onCurrentPositionChangedListener(position: Long)
    fun onCurrentDownloadSpeedChangedListener(speed: Long)
    fun onBufferedPositionChangedListener(buffered: Long)
    fun onLoadingBeginListener()
    fun onLoadingProgressListener(percent: Int)
    fun onLoadingEndListener()
}