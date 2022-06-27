package tech.shmy.a_player

data class VideoEvent(
    val state: Int = -1,
    val errorDescription: String = "",
    val duration: Long = 0,
    val position: Long = 0,
    val height: Int = 0,
    val width: Int = 0,
    val playSpeed: Float = 0f,
    val mirrorMode: Int = 0,
    val loop: Boolean = false,
    val enableHardwareDecoder: Boolean = true,
    val isBuffering: Boolean = false,
    val bufferingPercentage: Int = 0,
    val bufferingSpeed: Long = 0,
    val buffered: Long = 0,
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
            "state" to state,
            "errorDescription" to errorDescription,
            "width" to width,
            "height" to height,
            "duration" to duration,
            "position" to position,
            "playSpeed" to playSpeed,
            "mirrorMode" to mirrorMode,
            "loop" to loop,
            "enableHardwareDecoder" to enableHardwareDecoder,
            "isBuffering" to isBuffering,
            "buffered" to buffered,
            "bufferingPercentage" to bufferingPercentage,
            "bufferingSpeed" to bufferingSpeed,
        )
    }
}
