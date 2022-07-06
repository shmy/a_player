//
//  APlayer.swift
//  a_player
//
//  Created by drm-chao wang on 2022/6/23.
//

import Foundation
import Flutter

class APlayer: NSObject, FlutterTexture, FlutterStreamHandler, APlayerListener {
    
    private let queuingEventSink: QueuingEventSink = QueuingEventSink.init()
    private var aPlayerEvent: APlayerEvent = APlayerEvent.init()
  
    private var eventChannel: FlutterEventChannel?
    private var methodChannel: FlutterMethodChannel?
    private var latestBuffer: CVImageBuffer!
    private var registrar: FlutterPluginRegistrar!
    private var _textureId: Int64!
    private var textureRegistry: FlutterTextureRegistry?
    private var player: APlayerInterface?
    private var kernel: Int
    private var lastDataSource: Dictionary<String, Any>?
    
    init(registrar: FlutterPluginRegistrar, kernel: Int) {
        self.registrar = registrar
        self.kernel = kernel
        self.textureRegistry = registrar.textures()
        super.init()
        self.bindFlutter()
    }
    
    
    func textureId() -> Int64 {
        return _textureId
    }
    private func bindFlutter() -> Void {
        
        _textureId = textureRegistry?.register(self)
        
        eventChannel = FlutterEventChannel.init(name: PLAYER_EVENT_CHANNEL_NAME + String(_textureId), binaryMessenger: registrar.messenger())
        methodChannel = FlutterMethodChannel.init(name: PLAYER_METHOD_CHANNEL_NAME + String(_textureId), binaryMessenger: registrar.messenger())
        
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
              case "setKernel":
                self?.setKernel(kernel: call.arguments as! Int)
                break
              case "setDataSource":
                self?.lastDataSource = call.arguments as? Dictionary<String, Any>
                self?.setDataSource()
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
              case "release":
                self?.destroy()
                break
              default:
                break
            }
            result(nil)
        }
    }
    private func setupPlayer() -> Void {
        player?.addListener(listener: self)
    }
    
    private func createPlayer() -> Void {
        resetValue()
        player?.destroy()
        player = nil
        switch(kernel) {
        case KERNEL_ALIYUN:
//            player = AliyunPlayerImpl.init()
            break
        case KERNEL_IJK:
            player = IJKPlayerImpl.init()
            break
        case KERNEL_AV:
            player = AVPlayerImpl.init()
            break
        default:
            break
        }
        if (player == nil) {
            return
        }
        setupPlayer()
    }
    
    private func resetValue() -> Void {
        aPlayerEvent = APlayerEvent.init()
        aPlayerEvent.kernel = kernel
        stop();
        sendEvent()
    }
    
    private func setDataSource() -> Void {
        resetValue()
        let config: Dictionary<String, Any> = lastDataSource!
        let url = config["url"] as! String
        let position = config["position"] as! Int64
        if (APlayerUtil.isHttpProtocol(url: url) == true) {
            player?.setHttpDataSource(url: url, startAtPositionMs: position, headers: Dictionary<String, String>.init())
        } else if (APlayerUtil.isFileProtocol(url: url) == true) {
            player?.setFileDataSource(path: url, startAtPositionMs: position)
        }
        
    }
    private func setKernel(kernel: Int) {
        if (self.kernel == kernel) {
            return
        }
        self.kernel = kernel
        let isAutoPlay = player?.isAutoPlay == true
        let positionBefore = aPlayerEvent.position
        createPlayer()
        if (lastDataSource != nil) {
            lastDataSource!["position"] = positionBefore
            setDataSource()
            prepare(isAutoPlay: isAutoPlay)
        }
    }
    private func prepare(isAutoPlay: Bool) -> Void {
        player?.prepare(isAutoPlay: isAutoPlay)
    }
    
    private func play() -> Void {
        player?.play()
    }
    
    private func pause() -> Void {
        player?.pause()
    }
    private func stop() -> Void {
        player?.stop()
    }
    private func seekTo(position: Int64) -> Void {
        player?.seekTo(positionMs: position)
        aPlayerEvent.position = position
        sendEvent()
    }
    private func setSpeed(speed: Float) -> Void {
        player?.setSpeed(speed: speed)
        aPlayerEvent.playSpeed = speed
        sendEvent()
    }
    
    private func setLoop(loop: Bool) -> Void {
        player?.setLoop(isLoop: loop)
        aPlayerEvent.loop = loop
        sendEvent()
    }
    private func destroy() -> Void {
        player?.destroy()
        player = nil
        queuingEventSink.endOfStream()
        textureRegistry = nil
        eventChannel = nil
        methodChannel = nil
    }
    private func sendEvent() -> Void {
        queuingEventSink.success(event: self.aPlayerEvent.toMap())
    }
    
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if latestBuffer == nil {
            return nil
        }
        return Unmanaged<CVPixelBuffer>.passRetained(latestBuffer)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        queuingEventSink.setDelegate(delegate: events)
        createPlayer()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        queuingEventSink.setDelegate(delegate: nil)
        return nil
    }
    func onPixelBuffer(pixelBuffer: CVPixelBuffer) {
        latestBuffer = pixelBuffer
        textureRegistry?.textureFrameAvailable(_textureId)
    }
    
    func onInitializedListener() {
        aPlayerEvent.isInitialized = true
        sendEvent()
    }
    
    func onPlayingListener(isPlaying: Bool) {
        aPlayerEvent.isPlaying = isPlaying
        sendEvent()
    }
    
    func onErrorListener(code: String, message: String) {
        aPlayerEvent.isError = true
        aPlayerEvent.errorDescription = "\(code): \(message)"
        sendEvent()
    }
    
    func onCompletionListener() {
        aPlayerEvent.isCompletion = true
        sendEvent()
    }
    
    func onReadyToPlayListener() {
        aPlayerEvent.isReadyToPlay = true
        aPlayerEvent.duration = player!.duration
        aPlayerEvent.playSpeed = player!.speed
        aPlayerEvent.isPlaying = true
        aPlayerEvent.isError = false
        aPlayerEvent.isCompletion = false
        aPlayerEvent.isBuffering = false
        sendEvent()
    }
    
    func onVideoSizeChangedListener(width: Int32, height: Int32) {
        aPlayerEvent.width = width
        aPlayerEvent.height = height
        sendEvent()
    }
    
    func onCurrentPositionChangedListener(position: Int64) {
        aPlayerEvent.position = position
        sendEvent()
    }
    
    func onCurrentDownloadSpeedChangedListener(speed: Int64) {
        aPlayerEvent.bufferingSpeed = speed
        sendEvent()
    }
    
    func onBufferedPositionChangedListener(buffered: Int64) {
        aPlayerEvent.buffered = buffered
        sendEvent()
    }
    
    func onLoadingBeginListener() {
        aPlayerEvent.isBuffering = true
        sendEvent()
    }
    
    func onLoadingProgressListener(percent: Int) {
        aPlayerEvent.bufferingPercentage = percent
        sendEvent()
    }
    
    func onLoadingEndListener() {
        aPlayerEvent.isBuffering = false
        sendEvent()
    }
}
