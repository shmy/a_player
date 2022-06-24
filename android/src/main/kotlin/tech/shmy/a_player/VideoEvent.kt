package tech.shmy.a_player

data class VideoEvent(
    public val state: Int = -1,
    public val errorDescription: String = "",
    public val duration: Long = 0,
    public val position: Long = 0,
    public val height: Int = 0,
    public val width: Int = 0,
    public val playSpeed: Float = 0f,
    public val mirrorMode: Int = 0,
    public val loop: Boolean = false,
    public val enableHardwareDecoder: Boolean = true,
    public val isBuffering: Boolean = false,
    public val bufferingPercentage: Int = 0,
    public val bufferingSpeed: Float = 0f,
    public val buffered: Long = 0,
)
