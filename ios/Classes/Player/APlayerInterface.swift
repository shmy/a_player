//
//  APlayerInterface.swift
//  a_player
//
//  Created by drm-chao wang on 2022/7/4.
//

import Foundation

protocol APlayerInterface {
    var duration: Int64 { get }
    var speed: Float { get }
    var isLoop: Bool { get }
    var isAutoPlay: Bool { get }
    func addListener(listener: APlayerListener) -> Void
    func play() -> Void
    func pause() -> Void
    func stop() -> Void
    func enableHardwareDecoder(enabled: Bool) -> Void
    func destroy() -> Void
    func prepare(isAutoPlay: Bool) -> Void
    func seekTo(positionMs: Int64) -> Void
    func setSpeed(speed: Float) -> Void
    func setLoop(isLoop: Bool) -> Void
}
