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
    private var player: AliPlayer? = AliPlayer.init()
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
        self.player?.renderDelegate = self
        self._textureId = self.textureRegistry?.register(self)
        self.eventChannel = FlutterEventChannel.init(name: "a_player:event" + String(self._textureId), binaryMessenger: registrar.messenger())
        self.methodChannel = FlutterMethodChannel.init(name: "a_player:method" + String(self._textureId), binaryMessenger: registrar.messenger())
        
        self.methodChannel?.setMethodCallHandler {[weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            print("Method called: " + call.method)
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
                self?.setDataSource(url: call.arguments as! String)
                break
              case "release":
                self?.release()
                break
              default:
                break
            }
            result(nil)
        }
        self.eventChannel?.setStreamHandler(self)
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
        //
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        //
        return nil
    }
    
    func textureId() -> Int64 {
        return self._textureId
    }
    private func play() -> Void {
        self.player?.start()
    }
    
    private func pause() -> Void {
        self.player?.pause()
    }
    private func stop() -> Void {
        self.player?.stop()
    }
    private func prepare() -> Void {
        self.player?.isAutoPlay = true
        self.player?.prepare()
    }
    
    private func setDataSource(url: String) -> Void {
        let source = AVPUrlSource.init().url(with: url)
        self.player?.setUrlSource(source)
    }
    private func release() -> Void {
        self.player?.stop()
        self.player = nil
        self.textureRegistry = nil
        self.eventChannel = nil
        self.methodChannel = nil
    }
    
}
