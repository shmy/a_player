//
//  APlayer.swift
//  a_player
//
//  Created by drm-chao wang on 2022/6/23.
//

import Foundation
import Flutter
import AliyunPlayer

class APlayer: NSObject, FlutterTexture, CicadaRenderDelegate, FlutterStreamHandler {
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
              case "setMirrorMode":
                self?.setMirrorMode(mode: call.arguments as! Int)
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
        self.player?.renderDelegate = self
    }
    
    private func resetValue() -> Void {
        videoEvent = VideoEvent.init()
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
            if (userAgent != nil) {
                playerConfig?.userAgent = userAgent
            }
            if (referer != nil) {
                playerConfig?.referer = referer
            }
            playerConfig?.httpHeaders = config["customHeaders"] as? NSMutableArray
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
    private func setMirrorMode(mode: Int) -> Void {
        var avpMirrorMode: AVPMirrorMode
        var newMirrorMode: Int
        switch (mode) {
        case 1:
            avpMirrorMode = AVP_MIRRORMODE_HORIZONTAL
            newMirrorMode = 1
            break
        case 2:
            avpMirrorMode = AVP_MIRRORMODE_VERTICAL
            newMirrorMode = 2
            break
        default:
            avpMirrorMode = AVP_MIRRORMODE_NONE
            newMirrorMode = 0
            break
        }
        self.player?.mirrorMode = avpMirrorMode
        if (self.player != nil) {
            self.videoEvent.mirrorMode = newMirrorMode
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
        self.player?.reload()
        self.player?.enableHardwareDecoder = enable
        if (self.player != nil) {
            self.prepare(isAutoPlay: self.player!.isAutoPlay)
            self.videoEvent.enableHardwareDecoder = enable
            self.sendEvent()
       }
    }
    private func release() -> Void {
        self.player?.stop()
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
}
