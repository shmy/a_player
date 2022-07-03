package tech.shmy.a_player.player

interface APlayerListener {
    fun setOnInitializedListener()
    fun setOnPlayingListener(isPlaying: Boolean)
    fun setOnErrorListener(code: String, message: String)
    fun setOnCompletionListener()
    fun setOnReadyToPlayListener()
    fun setOnVideoSizeChangedListener(width: Int, height: Int)
    fun setOnStateChangedListener()
    fun setOnCurrentPositionChangedListener(position: Long)
    fun setOnCurrentDownloadSpeedChangedListener(speed: Long)
    fun setOnBufferedPositionChangedListener(buffered: Long)
    fun setOnSwitchToSoftwareVideoDecoderListener()
    fun setOnLoadingBeginListener()
    fun setOnLoadingProgressListener(percent: Int)
    fun setOnLoadingEndListener()
}