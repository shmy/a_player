//
//  APlayer.swift
//  a_player
//
//  Created by drm-chao wang on 2022/6/23.
//

import Foundation
import Flutter
import AliyunPlayer

class APlayer: NSObject, FlutterTexture, CicadaRenderDelegate, FlutterStreamHandler, AVPDelegate {
    private let queuingEventSink: QueuingEventSink = QueuingEventSink.init()
    private var videoEvent: VideoEvent = VideoEvent.init()
    private var player: AliPlayer?
    private var eventChannel: FlutterEventChannel?
    private var methodChannel: FlutterMethodChannel?
    private var latestBuffer: CVImageBuffer!
    private var registrar: FlutterPluginRegistrar!
    private var _textureId: Int64!
    private var textureRegistry: FlutterTextureRegistry?
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        self.textureRegistry = self.registrar.textures()
        super.init()
        self.bindFlutter()
    }
    
    
    func textureId() -> Int64 {
        return self._textureId
    }
    private func bindFlutter() -> Void {
        
        self._textureId = self.textureRegistry?.register(self)
        
        self.eventChannel = FlutterEventChannel.init(name: PLAYER_EVENT_CHANNEL_NAME + String(self._textureId), binaryMessenger: registrar.messenger())
        self.methodChannel = FlutterMethodChannel.init(name: PLAYER_METHOD_CHANNEL_NAME + String(self._textureId), binaryMessenger: registrar.messenger())
        
        self.eventChannel?.setStreamHandler(self)
        self.methodChannel?.setMethodCallHandler {[weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
           
            switch call.method {
              case "play":
                self?.play()
                break
              case "pause":
                self?.pause()
                break
              case "stop":
                self?.stop()
                break
              case "prepare":
                self?.prepare(isAutoPlay: call.arguments as! Bool)
                break
              case "setDataSource":
                self?.setDataSource(config: call.arguments as! Dictionary<String, Any>)
                break
              case "seekTo":
                self?.seekTo(position: call.arguments as! Int64)
                break
              case "setSpeed":
                self?.setSpeed(speed: call.arguments as! Float)
                break
              case "setLoop":
                self?.setLoop(loop: call.arguments as! Bool)
                break
              case "setHardwareDecoderEnable":
                self?.setHardwareDecoderEnable(enable: call.arguments as! Bool)
                break
              case "release":
                self?.release()
                break
              default:
                break
            }
            result(nil)
        }
    }
    
    private func createPlayer() -> Void {
        self.player = AliPlayer.init()
        let playerConfig = self.player!.getConfig()
        playerConfig?.maxBufferDuration = 1000 * 60 * 10
        playerConfig?.mMAXBackwardDuration =  1 * 60 * 10
        self.player?.setConfig(playerConfig)
        self.player?.volume = 1.0
        self.setupPlayer()
    }
    
    private func setupPlayer() -> Void {
        self.player?.delegate = self
        self.player?.renderDelegate = self
    }
    
    private func resetValue() -> Void {
        self.videoEvent = VideoEvent.init()
        self.stop();
        self.sendEvent()
    }
    
    private func setDataSource(config: Dictionary<String, Any>) -> Void {
        let urlSource = AVPUrlSource.init().url(with: config["url"] as? String)
        if (self.player != nil) {
            self.resetValue()
            let playerConfig = self.player!.getConfig()
            let userAgent: String? = config["userAgent"] as? String
            let referer: String? = config["referer"] as? String
            playerConfig?.clearShowWhenStop = true
            if (userAgent != nil) {
                playerConfig?.userAgent = userAgent
            }
            if (referer != nil) {
                playerConfig?.referer = referer
            }
            
//            playerConfig?.httpHeaders = NSMutableArray.init(array: config["customHeaders"] as! Array<String>)
            self.player!.setConfig(playerConfig)
            self.player!.setUrlSource(urlSource)
        }
        
    }
    private func prepare(isAutoPlay: Bool) -> Void {
        self.player?.isAutoPlay = isAutoPlay
        self.player?.prepare()
    }
    
    private func play() -> Void {
        self.player?.start()
    }
    
    private func pause() -> Void {
        self.player?.pause()
    }
    private func stop() -> Void {
        self.player?.stop()
        self.player?.clearScreen()
    }
    private func seekTo(position: Int64) -> Void {
        self.player?.seek(toTime: position, seekMode: AVP_SEEKMODE_ACCURATE)
        if (self.player != nil) {
            self.videoEvent.position = position
            self.sendEvent()
        }
        
    }
    private func setSpeed(speed: Float) -> Void {
        self.player?.rate = speed
        if (self.player != nil) {
            self.videoEvent.playSpeed = speed
            self.sendEvent()
        }
    }
    
    private func setLoop(loop: Bool) -> Void {
        self.player?.isLoop = loop
        if (self.player != nil) {
            self.videoEvent.loop = loop
            self.sendEvent()
        }
    }
    private func setHardwareDecoderEnable(enable: Bool) -> Void {
        self.resetValue()
        self.player?.enableHardwareDecoder = enable
        if (self.player != nil) {
            self.prepare(isAutoPlay: self.player!.isAutoPlay)
            self.videoEvent.enableHardwareDecoder = enable
            self.sendEvent()
       }
    }
    private func release() -> Void {
        self.player?.stop()
        self.player?.delegate = nil
        self.player?.renderDelegate = nil
        self.player = nil
        self.queuingEventSink.endOfStream()
        self.textureRegistry = nil
        self.eventChannel = nil
        self.methodChannel = nil
    }
    private func sendEvent() -> Void {
        self.queuingEventSink.success(event: self.videoEvent.toMap())
    }
    
    func onVideoPixelBuffer(_ pixelBuffer: CVPixelBuffer!, pts: Int64) -> Bool {
        latestBuffer = pixelBuffer
        self.textureRegistry?.textureFrameAvailable(self._textureId)
        return false
    }
    func onVideoRawBuffer(_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>!, lineSize: UnsafeMutablePointer<Int32>!, pts: Int64, width: Int32, height: Int32) -> Bool {
        return false
    }
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if latestBuffer == nil {
            return nil
        }
        return Unmanaged<CVPixelBuffer>.passRetained(latestBuffer)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.queuingEventSink.setDelegate(delegate: events)
        self.createPlayer()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.queuingEventSink.setDelegate(delegate: nil)
        return nil
    }
    func onPlayerEvent(_ player: AliPlayer!, eventType: AVPEventType) {
        switch(eventType) {
        case AVPEventPrepareDone:
            self.videoEvent.duration = player.duration
            self.videoEvent.playSpeed = player.rate
            self.sendEvent()
            break
        case AVPEventLoadingStart:
            self.videoEvent.isBuffering = true
            self.videoEvent.bufferingPercentage = 0
            self.sendEvent()
            break
        case AVPEventLoadingEnd:
            self.videoEvent.isBuffering = false
            self.sendEvent()
            break
        case AVPEventFirstRenderedStart:
            self.videoEvent.ready = true
            self.sendEvent()
            break
        default:
            break
        }
    }
    func onPlayerEvent(_ player: AliPlayer!, eventWithString: AVPEventWithString, description: String!) {
        if (eventWithString == EVENT_SWITCH_TO_SOFTWARE_DECODER) {
            self.videoEvent.enableHardwareDecoder = false
            self.sendEvent()
        }
    }
    func onVideoSizeChanged(_ player: AliPlayer!, width: Int32, height: Int32, rotation: Int32) {
        self.videoEvent.height = height
        self.videoEvent.width = width
        self.sendEvent()
    }
    func onError(_ player: AliPlayer!, errorModel: AVPErrorModel!) {
        self.videoEvent.errorDescription = "\(errorModel.code): \(String(describing: errorModel.message))"
        self.sendEvent()
        
    }
    func onCurrentDownloadSpeed(_ player: AliPlayer!, speed: Int64) {
        self.videoEvent.bufferingSpeed = speed
        self.sendEvent()
    }
    func onCurrentPositionUpdate(_ player: AliPlayer!, position: Int64) {
        self.videoEvent.position = position
        self.sendEvent()
    }
    func onLoadingProgress(_ player: AliPlayer!, progress: Float) {
        self.videoEvent.bufferingPercentage = Int(progress)
        self.sendEvent()
    }
    func onBufferedPositionUpdate(_ player: AliPlayer!, position: Int64) {
        self.videoEvent.buffered = position
        self.sendEvent()
    }
    
    func onPlayerStatusChanged(_ player: AliPlayer!, oldStatus: AVPStatus, newStatus: AVPStatus) {
        var ready = self.videoEvent.ready
        var state = -1
        switch(newStatus) {
        case AVPStatusIdle:
            state = 0
            break
        case AVPStatusInitialzed:
            state = 1
            break
        case AVPStatusPrepared:
            state = 2
            break
        case AVPStatusStarted:
            state = 3
            break
        case AVPStatusPaused:
            state = 4
            break
        case AVPStatusStopped:
            state = 5
            ready = false
            break
        case AVPStatusCompletion:
            state = 6
            break
        case AVPStatusError:
            state = 7
            break
        default:
            break
        }
        self.videoEvent.state = state
        self.videoEvent.ready = ready
        self.sendEvent()
    }
    
}
