package tech.shmy.a_player.player

import android.view.Surface

interface APlayerInterface {
    val duration: Long
    val speed: Float
    val isLoop: Boolean
    fun addListener(listener: APlayerListener)
    fun setSurface(surface: Surface)
    fun play()
    fun pause()
    fun stop()
    fun setHttpDataSource(url: String, startAtPositionMs: Long, headers: Map<String, String>)
    fun setFileDataSource(path: String, startAtPositionMs: Long)
    fun release()
    fun prepare()
    fun seekTo(positionMs: Long)
    fun setSpeed(speed: Float)
    fun setLoop(isLoop: Boolean)
}