package tech.shmy.a_player.player

import android.view.Surface

data class APlayerHeader(val key: String, val value: String)

interface APlayerInterface {
    val duration: Long
    val speed: Float
    val isLoop: Boolean
    val isAutoPlay: Boolean
    fun addListener(listener: APlayerListener): Unit
    fun setSurface(surface: Surface): Unit
    fun play(): Unit
    fun pause(): Unit
    fun stop(): Unit
    fun setHttpDataSource(url: String, startAtPositionMs: Long, headers: Array<APlayerHeader>): Unit
    fun setFileDataSource(path: String, startAtPositionMs: Long): Unit
    fun setAssetDataSource(path: String, startAtPositionMs: Long): Unit
    fun enableHardwareDecoder(enabled: Boolean): Unit
    fun release(): Unit
    fun prepare(isAutoPlay: Boolean): Unit
    fun seekTo(positionMs: Long): Unit
    fun setSpeed(speed: Float): Unit
    fun setLoop(isLoop: Boolean): Unit
}