package tech.shmy.a_player.player

const val KERNEL_ALIYUN = 0
const val KERNEL_EXO = 1
data class APlayerEvent(
    val isInitialized: Boolean = false,
    val isPlaying: Boolean = false,
    val isError: Boolean = false,
    val isCompletion: Boolean = false,
    val isReadyToPlay: Boolean = false,
    val errorDescription: String = "",
    val duration: Long = 0,
    val position: Long = 0,
    val height: Int = 0,
    val width: Int = 0,
    val playSpeed: Float = 0f,
    val loop: Boolean = false,
    val enableHardwareDecoder: Boolean = true,
    val isBuffering: Boolean = false,
    val bufferingPercentage: Int = 0,
    val bufferingSpeed: Long = 0,
    val buffered: Long = 0,
    val featurePictureInPicture: Boolean = false,
    val kernel: Int = KERNEL_ALIYUN,
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
            "isInitialized" to isInitialized,
            "isPlaying" to isPlaying,
            "isError" to isError,
            "isCompletion" to isCompletion,
            "isReadyToPlay" to isReadyToPlay,
            "errorDescription" to errorDescription,
            "width" to width,
            "height" to height,
            "duration" to duration,
            "position" to position,
            "playSpeed" to playSpeed,
            "loop" to loop,
            "enableHardwareDecoder" to enableHardwareDecoder,
            "isBuffering" to isBuffering,
            "buffered" to buffered,
            "bufferingPercentage" to bufferingPercentage,
            "bufferingSpeed" to bufferingSpeed,
            "featurePictureInPicture" to featurePictureInPicture,
            "kernel" to kernel,
        )
    }
}
