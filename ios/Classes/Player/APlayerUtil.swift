//
//  APlayerUtil.swift
//  a_player
//
//  Created by drm-chao wang on 2022/7/5.
//

import Foundation

class APlayerUtil {
    static func isHttpProtocol(url: String) -> Bool {
        return url.starts(with: "http://") || url.starts(with: "https://")
    }
    static func isFileProtocol(url: String) -> Bool {
        return url.starts(with: "file://")
    }
    static func isUserAgentKey(key: String) -> Bool {
        return key.uppercased() == "USER-AGENT"
    }
    static func isRefererKey(key: String) -> Bool {
        return key.uppercased() == "REFERER"
    }
}
