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
  
    private var eventChannel: FlutterEventChannel?
    private var methodChannel: FlutterMethodChannel?
    private var latestBuffer: CVImageBuffer!
    private var registrar: FlutterPluginRegistrar!
    private var _textureId: Int64!
    private var textureRegistry: FlutterTextureRegistry?
    private var player: APlayerInterface?
    private var kernel: Int?
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
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
                self?.prepare()
                break
              case "setDataSource":
                self?.setDataSource(args: call.arguments as! Dictionary<String, Any>)
                break
            case "restart":
                self?.restartPlay()
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
        queuingEventSink.success(event: [
            "type": "initializing"
        ])
        resetValue()
        player?.destroy()
        player = nil
        switch(kernel) {
        case KERNEL_ALIYUN:
            player = AliyunPlayerImpl.init()
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
        queuingEventSink.success(event: [
            "type": "initialized",
            "data": self.kernel
        ])
    }
    
    private func resetValue() -> Void {
        latestBuffer = nil
        stop();
    }
    private func restartPlay() -> Void {
        seekTo(position: 0)
        play()
    }
    private func setDataSource(args: Dictionary<String, Any>) -> Void {
        resetValue()
        let kernel = args["kernel"] as! Int
        let url = args["url"] as! String
        let position = args["position"] as! Int64
        if (APlayerUtil.isHttpProtocol(url: url) == true) {
            player?.setHttpDataSource(url: url, startAtPositionMs: position, headers: args["httpHeaders"] as! Dictionary<String, String>)
        } else if (APlayerUtil.isFileProtocol(url: url) == true) {
            player?.setFileDataSource(path: url, startAtPositionMs: position)
        }
        self.setKernel(kernel: kernel)
        
    }
    private func setKernel(kernel: Int) {
        if (self.kernel == kernel) {
            return
        }
        self.kernel = kernel
        createPlayer()
    }
    private func prepare() -> Void {
        player?.prepare()
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
    }
    private func setSpeed(speed: Float) -> Void {
        player?.setSpeed(speed: speed)
    }
    
    private func setLoop(loop: Bool) -> Void {
        player?.setLoop(isLoop: loop)
    }
    private func destroy() -> Void {
        player?.destroy()
        player = nil
        queuingEventSink.endOfStream()
        textureRegistry = nil
        eventChannel = nil
        methodChannel = nil
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
        if (latestBuffer == pixelBuffer) {
            return
        }
        latestBuffer = pixelBuffer
        textureRegistry?.textureFrameAvailable(_textureId)
    }
    
    func onPlayingListener(isPlaying: Bool) {
        queuingEventSink.success(event: [
            "type": "playing",
            "data": isPlaying
        ])
    }
    
    func onErrorListener(code: String, message: String) {
        queuingEventSink.success(event: [
            "type": "error",
            "data": "\(code): \(message)"
        ])
    }
    
    func onCompletionListener() {
        queuingEventSink.success(event: [
            "type": "completion",
        ])
    }
    
    func onReadyToPlayListener() {
        queuingEventSink.success(event: [
            "type": "readyToPlay",
            "data": [
                "duration": player!.duration,
                "playSpeed": player!.speed
            ]
        ])
    }
    
    func onVideoSizeChangedListener(width: Int32, height: Int32) {
        queuingEventSink.success(event: [
            "type": "videoSizeChanged",
            "data": [
                "height": height,
                "width": width
            ]
        ])
    }
    
    func onCurrentPositionChangedListener(position: Int64) {
        queuingEventSink.success(event: [
            "type": "currentPositionChanged",
            "data": position
        ])
    }
    
    func onCurrentDownloadSpeedChangedListener(speed: Int64) {
        queuingEventSink.success(event: [
            "type": "currentDownloadSpeedChanged",
            "data": speed
        ])
    }
    
    func onBufferedPositionChangedListener(buffered: Int64) {
        queuingEventSink.success(event: [
            "type": "bufferedPositionChanged",
            "data": buffered
        ])
    }
    
    func onLoadingBeginListener() {
        queuingEventSink.success(event: [
            "type": "loadingBegin"
        ])
    }
    
    func onLoadingProgressListener(percent: Int) {
        queuingEventSink.success(event: [
            "type": "loadingProgress",
            "data": percent
        ])
    }
    
    func onLoadingEndListener() {
        queuingEventSink.success(event: [
            "type": "loadingEnd"
        ])
    }
}
