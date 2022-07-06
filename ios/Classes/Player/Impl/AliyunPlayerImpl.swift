//
//  AliyunPlayerImpl.swift
//  a_player
//
//  Created by drm-chao wang on 2022/7/4.
//

import Foundation
import AliyunPlayer

class AliyunPlayerImpl: NSObject, APlayerInterface, AVPDelegate, CicadaRenderDelegate {

   private let aliPlayer: AliPlayer = AliPlayer.init()
   private var listener: APlayerListener?
   var duration: Int64 {
       get {
           return aliPlayer.duration
       }
   }

   var speed: Float {
       get {
           return aliPlayer.rate
       }
   }

   var isLoop: Bool {
       get {
           return aliPlayer.isLoop
       }
   }

   var isAutoPlay: Bool {
       get {
           return aliPlayer.isAutoPlay
       }
   }

   override init() {
       AliPlayerGlobalSettings.setUseHttp2(true)
       super.init()
       aliPlayer.delegate = self
       aliPlayer.renderDelegate = self
   }
   func addListener(listener: APlayerListener) {
       self.listener = listener
   }
   func setHttpDataSource(url: String, startAtPositionMs: Int64, headers: Dictionary<String, String>) {
       let urlSource = AVPUrlSource.init().url(with: url)
       let playerConfig = aliPlayer.getConfig()
       playerConfig?.clearShowWhenStop = true
       playerConfig?.maxBufferDuration = 1000 * 60 * 10
       playerConfig?.mMAXBackwardDuration = 1 * 60 * 10
       var userAgent: String? = nil
       var referer: String? = nil
       let customHeaders: NSMutableArray = NSMutableArray.init()
       headers.forEach { (key: String, value: String) in
           if (APlayerUtil.isUserAgentKey(key: key)) {
               userAgent = value
           } else if (APlayerUtil.isRefererKey(key: key)) {
               referer = value
           } else {
               customHeaders.add("\(key):\(value)")
           }
       }
       if (userAgent != nil) {
         playerConfig?.userAgent = userAgent
       }
       if (referer != nil) {
         playerConfig?.referer = referer
       }

//       playerConfig?.httpHeaders = customHeaders
       aliPlayer.setConfig(playerConfig)
       aliPlayer.setUrlSource(urlSource)
       aliPlayer.seek(toTime: startAtPositionMs, seekMode: AVP_SEEKMODE_ACCURATE)

   }

   func setFileDataSource(path: String, startAtPositionMs: Int64) {
       setHttpDataSource(url: path, startAtPositionMs: startAtPositionMs, headers: Dictionary<String, String>.init())
   }

   func play() {
       aliPlayer.start()
   }

   func pause() {
       aliPlayer.pause()
   }

   func stop() {
       aliPlayer.stop()
   }

   func destroy() {
       aliPlayer.destroy()
   }

   func prepare(isAutoPlay: Bool) {
       aliPlayer.isAutoPlay = isAutoPlay
       aliPlayer.prepare()
   }

   func seekTo(positionMs: Int64) {
       aliPlayer.seek(toTime: positionMs, seekMode: AVP_SEEKMODE_ACCURATE)
   }

   func setSpeed(speed: Float) {
       aliPlayer.rate = speed
   }

   func setLoop(isLoop: Bool) {
       aliPlayer.isLoop = isLoop
   }

   // CicadaRenderDelegate
   func onVideoPixelBuffer(_ pixelBuffer: CVPixelBuffer!, pts: Int64) -> Bool {
       listener?.onPixelBuffer(pixelBuffer: pixelBuffer)
       return false
   }
   // AVPDelegate
   func onPlayerEvent(_ player: AliPlayer!, eventType: AVPEventType) {
       switch(eventType) {
       case AVPEventPrepareDone:
           listener?.onInitializedListener()
           break
       case AVPEventLoadingStart:
           listener?.onLoadingBeginListener()
           break
       case AVPEventLoadingEnd:
           listener?.onLoadingEndListener()
           break
       case AVPEventFirstRenderedStart:
           listener?.onReadyToPlayListener()
           break
       default:
           break
       }
   }
   func onVideoSizeChanged(_ player: AliPlayer!, width: Int32, height: Int32, rotation: Int32) {
       listener?.onVideoSizeChangedListener(width: width, height: height)
   }
   func onError(_ player: AliPlayer!, errorModel: AVPErrorModel!) {
       listener?.onErrorListener(code: "\(errorModel.code)", message: errorModel.message)
   }

   func onCurrentDownloadSpeed(_ player: AliPlayer!, speed: Int64) {
       listener?.onCurrentDownloadSpeedChangedListener(speed: speed)
   }
   func onCurrentPositionUpdate(_ player: AliPlayer!, position: Int64) {
       listener?.onCurrentPositionChangedListener(position: position)
   }
   func onLoadingProgress(_ player: AliPlayer!, progress: Float) {
       listener?.onLoadingProgressListener(percent: Int(progress))
   }
   func onBufferedPositionUpdate(_ player: AliPlayer!, position: Int64) {
       listener?.onBufferedPositionChangedListener(buffered: position)
   }
   func onPlayerStatusChanged(_ player: AliPlayer!, oldStatus: AVPStatus, newStatus: AVPStatus) {
       if (newStatus == AVPStatusStarted) {
           listener?.onPlayingListener(isPlaying: true)
       } else {
           listener?.onPlayingListener(isPlaying: false)
       }
       if (newStatus == AVPStatusCompletion) {
           listener?.onCompletionListener()
       }
   }
}
