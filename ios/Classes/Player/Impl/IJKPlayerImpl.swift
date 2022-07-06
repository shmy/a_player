//
//  IJKPlayerImpl.swift
//  a_player
//
//  Created by drm-chao wang on 2022/7/6.
//

import Foundation
import IJKMediaPlayer

private let IJK_STATTE_IDLE: Int32 = 0
private let IJK_STATTE_INITIALIZED: Int32 = 1
private let IJK_STATTE_ASYNCPREPARING: Int32 = 2
private let IJK_STATTE_PREPARED: Int32 = 3
private let IJK_STATTE_STARTED: Int32 = 4
private let IJK_STATTE_PAUSED: Int32 = 5
private let IJK_STATTE_COMPLETED: Int32 = 6
private let IJK_STATTE_STOPPED: Int32 = 7
private let IJK_STATTE_ERROR: Int32 = 8
private let IJK_STATTE_END: Int32 = 9

class IJKPlayerImpl: NSObject, APlayerInterface, IJKMPEventHandler, IJKCVPBViewProtocol {
    
    private var ijkPlayer: IJKFFMediaPlayer? = IJKFFMediaPlayer.init()
    private var listener: APlayerListener?
    private var _isAutoPlay = false
    private var _speed: Float = 1.0
    private var _isLoop = false
    override init() {
        super.init()
        bindEvent()
    }
    
    var duration: Int64 {
        get {
            if (ijkPlayer == nil) {
                return 0
            }
            return Int64(ijkPlayer!.getDuration())
        }
    }
    
    var speed: Float {
        get {
            return _speed
        }
    }
    
    var isLoop: Bool {
        get {
            return _isLoop
        }
    }
    
    var isAutoPlay: Bool {
        get {
            return _isAutoPlay
        }
    }
    
    func addListener(listener: APlayerListener) {
        self.listener = listener
    }
    
    func play() {
        ijkPlayer?.start()
    }
    
    func pause() {
        ijkPlayer?.pause()
    }
    
    func stop() {
        ijkPlayer?.stop()
    }
    
    func setHttpDataSource(url: String, startAtPositionMs: Int64, headers: Dictionary<String, String>) {
        ijkPlayer?.stop()
        ijkPlayer?.reset()
        
        ijkPlayer?.setOptionValue("fcc-bgra", forKey: "overlay-format", of: kIJKFFOptionCategoryPlayer)
        ijkPlayer?.setOptionIntValue(startAtPositionMs, forKey: "seek-at-start", of: kIJKFFOptionCategoryPlayer)
        ijkPlayer?.setOptionIntValue(5, forKey: "reconnect", of: kIJKFFOptionCategoryPlayer)
        ijkPlayer?.setOptionIntValue(5, forKey: "framedrop", of: kIJKFFOptionCategoryPlayer)
        ijkPlayer?.setOptionIntValue(10 * 1024 * 1024, forKey: "max-buffer-size", of: kIJKFFOptionCategoryPlayer)
        ijkPlayer?.setOptionIntValue(30, forKey: "max-fps", of: kIJKFFOptionCategoryPlayer)
        ijkPlayer?.setOptionIntValue(1, forKey: "packet-buffering", of: kIJKFFOptionCategoryPlayer)
        
        ijkPlayer?.setOptionIntValue(1, forKey: "enable-position-notify", of: kIJKFFOptionCategoryPlayer)
        ijkPlayer?.setOptionIntValue(1, forKey: "videotoolbox", of: kIJKFFOptionCategoryPlayer)
        
        ijkPlayer?.setDataSource(url)
    }
    
    func setFileDataSource(path: String, startAtPositionMs: Int64) {
        setHttpDataSource(url: path, startAtPositionMs: startAtPositionMs, headers: Dictionary<String, String>.init())
    }
    
    func destroy() {
        listener = nil
        ijkPlayer?.remove(self)
        ijkPlayer?.shutdown()
        ijkPlayer = nil
    }
    
    func prepare(isAutoPlay: Bool) {
        _isAutoPlay = isAutoPlay
        ijkPlayer?.setOptionIntValue(_isAutoPlay ? 1 : 0, forKey: "start-on-prepared", of: kIJKFFOptionCategoryPlayer)
        ijkPlayer?.prepareAsync()
    }
    
    func seekTo(positionMs: Int64) {
        ijkPlayer?.seek(to: Int(positionMs))
    }
    
    func setSpeed(speed: Float) {
        _speed = speed
        ijkPlayer?.setSpeed(speed)
    }
    
    func setLoop(isLoop: Bool) {
        _isLoop = isLoop
    }
    private func bindEvent() {
        ijkPlayer?.add(self)
        ijkPlayer?.setupCVPixelBufferView(self)
    }
    private func onStateChange(state: Int32) {
        if (state == IJK_STATTE_COMPLETED) {
            if (_isLoop) {
                play()
            } else {
                listener?.onCompletionListener()
            }
        }
        listener?.onPlayingListener(isPlaying: state == IJK_STATTE_STARTED)
    }
    func onEvent4Player(_ player: IJKFFMediaPlayer, withType waht: Int32, andArg1 arg1: Int32, andArg2 arg2: Int32, andExtra extra: UnsafeMutableRawPointer) {
        switch(Int(waht)) {
        case IJKMPEventType.IJKMPET_PREPARED.rawValue:
            listener?.onInitializedListener()
            break
        case IJKMPEventType.IJKMPET_PLAYBACK_STATE_CHANGED.rawValue:
            onStateChange(state: arg1)
            break
        case IJKMPEventType.IJKMPET_BUFFERING_START.rawValue:
            listener?.onLoadingBeginListener()
            break
        case IJKMPEventType.IJKMPET_BUFFERING_UPDATE.rawValue:
            listener?.onLoadingProgressListener(percent: arg2 > 100 ? 100 : Int(arg2))
            listener?.onBufferedPositionChangedListener(buffered: Int64(arg1))
            break
        case IJKMPEventType.IJKMPET_BUFFERING_END.rawValue:
            listener?.onLoadingEndListener()
            break
        case IJKMPEventType.IJKMPET_VIDEO_SIZE_CHANGED.rawValue:
            listener?.onVideoSizeChangedListener(width: arg1, height: arg2)
            break
        case IJKMPEventType.IJKMPET_VIDEO_RENDERING_START.rawValue:
            listener?.onReadyToPlayListener()
            break
        case IJKMPEventType.IJKMPET_ERROR.rawValue:
            listener?.onErrorListener(code: "\(arg1)", message: "play error")
            break
        case IJKMPEventType.IJKMPET_CURRENT_POSITION_UPDATE.rawValue:
            listener?.onCurrentPositionChangedListener(position: Int64(arg1))
            break
        default:
            break

        }
    }
    func display_pixelbuffer(_ pixelbuffer: CVPixelBuffer!) {
        listener?.onPixelBuffer(pixelBuffer: pixelbuffer)
    }
}
