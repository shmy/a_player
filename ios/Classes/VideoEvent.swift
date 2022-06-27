//
//  VideoEvent.swift
//  a_player
//
//  Created by drm-chao wang on 2022/6/27.
//

import Foundation
class VideoEvent: NSObject {
    public let state: Int
    public let errorDescription: String
    public let duration: Int
    public let position: Int
    public let height: Int
    public let width: Int
    public let playSpeed: Float
    public let mirrorMode: Int
    public let loop: Bool
    public let enableHardwareDecoder: Bool
    public let isBuffering: Bool
    public let bufferingPercentage: Int
    public let bufferingSpeed: Int
    public let buffered: Int
   
    init(
       state: Int = -1,
       errorDescription: String = "",
       duration: Int = 0,
       position: Int = 0,
       height: Int = 0,
       width: Int = 0,
       playSpeed: Float = 0.0,
       mirrorMode: Int = 0,
       loop: Bool = false,
       enableHardwareDecoder: Bool = false,
       isBuffering: Bool = false,
       bufferingPercentage: Int = 0,
       bufferingSpeed: Int = 0,
       buffered: Int = 0
    
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
    
    func copy(
      state: Int?,
      errorDescription: String?,
      duration: Int?,
      position: Int?,
      height: Int?,
      width: Int?,
      playSpeed: Float?,
      mirrorMode: Int?,
      loop: Bool?,
      enableHardwareDecoder: Bool?,
      isBuffering: Bool?,
      bufferingPercentage: Int?,
      bufferingSpeed: Int?,
      buffered: Int?
    ) -> VideoEvent {
        let videoEvent = VideoEvent.init(
            state: state ?? self.state,
            errorDescription: errorDescription ?? self.errorDescription,
            duration: duration ?? self.duration,
            position: position ?? self.position,
            height: height ?? self.height,
            width: width ?? self.width,
            playSpeed: playSpeed ?? self.playSpeed,
            mirrorMode: mirrorMode ?? self.mirrorMode,
            loop: loop ?? self.loop,
            enableHardwareDecoder: enableHardwareDecoder ?? self.enableHardwareDecoder,
            isBuffering: isBuffering ?? self.isBuffering,
            bufferingPercentage: bufferingPercentage ?? self.bufferingPercentage,
            bufferingSpeed: bufferingSpeed ?? self.bufferingSpeed,
            buffered: buffered ?? self.buffered
        )
        return videoEvent
    }
    
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
