package tech.shmy.a_player.player

class APlayerUtil {
    companion object {
        fun isHttpProtocol(url: String): Boolean {
            return url.startsWith("http://") || url.startsWith("https://")
        }
        fun isFileProtocol(url: String): Boolean {
            return url.startsWith("file://")
        }
        fun isAssetProtocol(url: String): Boolean {
            return !isHttpProtocol(url) && !isFileProtocol(url)
        }
        fun isUserAgentKey(key: String): Boolean {
            return key.uppercase() == "USER-AGENT"
        }
        fun isRefererKey(key: String): Boolean {
            return key.uppercase() == "REFERER"
        }
    }
}