package tech.shmy.a_player.player

import android.view.Surface

data class APlayerHeader(val key: String, val value: String)

interface APlayerInterface {
    val duration: Long
    val speed: Float
    val isLoop: Boolean
    val isAutoPlay: Boolean
    fun addListener(listener: APlayerListener)
    fun setSurface(surface: Surface)
    fun play()
    fun pause()
    fun stop()
    fun setHttpDataSource(url: String, startAtPositionMs: Long, headers: Array<APlayerHeader>)
    fun setFileDataSource(path: String, startAtPositionMs: Long)
    fun setAssetDataSource(path: String, startAtPositionMs: Long)
    fun enableHardwareDecoder(enabled: Boolean)
    fun release()
    fun prepare(isAutoPlay: Boolean)
    fun seekTo(positionMs: Long)
    fun setSpeed(speed: Float)
    fun setLoop(isLoop: Boolean)
}