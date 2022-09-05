////
////  APlayerEvent.swift
////  a_player
////
////  Created by drm-chao wang on 2022/7/5.
////
//
//import Foundation
//
//class APlayerEvent: NSObject {
//    public var isInitialized: Bool
//    public var isPlaying: Bool
//    public var isError: Bool
//    public var isCompletion: Bool
//    public var isReadyToPlay: Bool
//    public var errorDescription: String
//    public var duration: Int64
//    public var position: Int64
//    public var height: Int32
//    public var width: Int32
//    public var playSpeed: Float
//    public var loop: Bool
////    public var enableHardwareDecoder: Bool
//    public var isBuffering: Bool
//    public var bufferingPercentage: Int
//    public var bufferingSpeed: Int64
//    public var buffered: Int64
//    public var featurePictureInPicture: Bool
//    public var kernel: Int
//   
//    init(
//       isInitialized: Bool = false,
//       isPlaying: Bool = false,
//       isError: Bool = false,
//       isCompletion: Bool = false,
//       isReadyToPlay: Bool = false,
//       errorDescription: String = "",
//       duration: Int64 = 0,
//       position: Int64 = 0,
//       height: Int32 = 0,
//       width: Int32 = 0,
//       playSpeed: Float = 0.0,
//       loop: Bool = false,
////       enableHardwareDecoder: Bool = true,
//       isBuffering: Bool = false,
//       bufferingPercentage: Int = 0,
//       bufferingSpeed: Int64 = 0,
//       buffered: Int64 = 0,
//       featurePictureInPicture: Bool = false,
//       kernel: Int = KERNEL_ALIYUN
//    
//    ) {
//        self.isInitialized = isInitialized
//        self.isPlaying = isPlaying
//        self.isError = isError
//        self.isCompletion = isCompletion
//        self.isReadyToPlay = isReadyToPlay
//        self.errorDescription = errorDescription
//        self.duration = duration
//        self.position = position
//        self.height = height
//        self.width = width
//        self.playSpeed = playSpeed
//        self.loop = loop
////        self.enableHardwareDecoder = enableHardwareDecoder
//        self.isBuffering = isBuffering
//        self.bufferingPercentage = bufferingPercentage
//        self.bufferingSpeed = bufferingSpeed
//        self.buffered = buffered
//        self.featurePictureInPicture = featurePictureInPicture
//        self.kernel = kernel
//    }
//    
//    func toMap() -> Dictionary<String, Any> {
//        return [
//            "isInitialized": isInitialized,
//            "isPlaying": isPlaying,
//            "isError": isError,
//            "isCompletion": isCompletion,
//            "isReadyToPlay": isReadyToPlay,
//            "errorDescription": errorDescription,
//            "duration": duration,
//            "position": position,
//            "height": height,
//            "width": width,
//            "playSpeed": playSpeed,
//            "loop": loop,
////            "enableHardwareDecoder": enableHardwareDecoder,
//            "isBuffering": isBuffering,
//            "bufferingPercentage": bufferingPercentage,
//            "bufferingSpeed": bufferingSpeed,
//            "buffered": buffered,
//            "featurePictureInPicture": featurePictureInPicture,
//            "kernel": kernel
//        ]
//    }
//    
//}
