//
//  VideoEvent.swift
//  a_player
//
//  Created by drm-chao wang on 2022/6/27.
//

import Foundation
class VideoEvent: NSObject {
    public var state: Int
    public var errorDescription: String
    public var duration: Int64
    public var position: Int64
    public var height: Int32
    public var width: Int32
    public var playSpeed: Float
    public var mirrorMode: Int
    public var loop: Bool
    public var enableHardwareDecoder: Bool
    public var isBuffering: Bool
    public var bufferingPercentage: Int
    public var bufferingSpeed: Int64
    public var buffered: Int64
   
    init(
       state: Int = -1,
       errorDescription: String = "",
       duration: Int64 = 0,
       position: Int64 = 0,
       height: Int32 = 0,
       width: Int32 = 0,
       playSpeed: Float = 0.0,
       mirrorMode: Int = 0,
       loop: Bool = false,
       enableHardwareDecoder: Bool = true,
       isBuffering: Bool = false,
       bufferingPercentage: Int = 0,
       bufferingSpeed: Int64 = 0,
       buffered: Int64 = 0
    
    ) {
        self.state = state
        self.errorDescription = errorDescription
        self.duration = duration
        self.position = position
        self.height = height
        self.width = width
        self.playSpeed = playSpeed
        self.mirrorMode = mirrorMode
        self.loop = loop
        self.enableHardwareDecoder = enableHardwareDecoder
        self.isBuffering = isBuffering
        self.bufferingPercentage = bufferingPercentage
        self.bufferingSpeed = bufferingSpeed
        self.buffered = buffered
    }
    
//    func copyWith(
//      state: Int?,
//      errorDescription: String?,
//      duration: Int64?,
//      position: Int64?,
//      height: Int?,
//      width: Int?,
//      playSpeed: Float?,
//      mirrorMode: Int?,
//      loop: Bool?,
//      enableHardwareDecoder: Bool?,
//      isBuffering: Bool?,
//      bufferingPercentage: Int?,
//      bufferingSpeed: Int64?,
//      buffered: Int64?
//    ) -> VideoEvent {
//        let videoEvent = VideoEvent.init(
//            state: state ?? self.state,
//            errorDescription: errorDescription ?? self.errorDescription,
//            duration: duration ?? self.duration,
//            position: position ?? self.position,
//            height: height ?? self.height,
//            width: width ?? self.width,
//            playSpeed: playSpeed ?? self.playSpeed,
//            mirrorMode: mirrorMode ?? self.mirrorMode,
//            loop: loop ?? self.loop,
//            enableHardwareDecoder: enableHardwareDecoder ?? self.enableHardwareDecoder,
//            isBuffering: isBuffering ?? self.isBuffering,
//            bufferingPercentage: bufferingPercentage ?? self.bufferingPercentage,
//            bufferingSpeed: bufferingSpeed ?? self.bufferingSpeed,
//            buffered: buffered ?? self.buffered
//        )
//        return videoEvent
//    }
    
    func toMap() -> Dictionary<String, Any> {
        return [
            "state": state,
            "errorDescription": errorDescription,
            "duration": duration,
            "position": position,
            "height": height,
            "width": width,
            "playSpeed": playSpeed,
            "mirrorMode": mirrorMode,
            "loop": loop,
            "enableHardwareDecoder": enableHardwareDecoder,
            "isBuffering": isBuffering,
            "bufferingPercentage": bufferingPercentage,
            "bufferingSpeed": bufferingSpeed,
            "buffered": buffered
        ]
    }
    
}
