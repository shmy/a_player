//
//  IJKPlayerImpl.swift
//  a_player
//
//  Created by drm-chao wang on 2022/7/6.
//

import Foundation
import IJKMediaPlayer

class IJKPlayerImpl: NSObject, APlayerInterface, IJKMPEventHandler, IJKCVPBViewProtocol {
    
    private var ijkPlayer: IJKFFMediaPlayer? = IJKFFMediaPlayer.init()
    private var listener: APlayerListener?
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
            return 1.0
        }
    }
    
    var isLoop: Bool {
        get {
            return ijkPlayer?.getLoop() == 1
        }
    }
    
    var isAutoPlay: Bool {
        get {
            return false
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
        ijkPlayer?.reset()
        ijkPlayer?.setDataSource(url)
        seekTo(positionMs: startAtPositionMs)
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
//        ijkPlayer?.shouldAutoplay = isAutoPlay
        ijkPlayer?.prepareAsync()
    }
    
    func seekTo(positionMs: Int64) {
        ijkPlayer?.seek(to: Int(positionMs))
    }
    
    func setSpeed(speed: Float) {
        ijkPlayer?.setSpeed(speed)
    }
    
    func setLoop(isLoop: Bool) {
        //
    }
    private func bindEvent() {
        ijkPlayer?.setOptionValue("fcc-bgra", forKey: "overlay-format", of: kIJKFFOptionCategoryPlayer)
        ijkPlayer?.add(self)
        ijkPlayer?.setupCVPixelBufferView(self)
    }
    func onEvent4Player(_ player: IJKFFMediaPlayer, withType waht: Int32, andArg1 arg1: Int32, andArg2 arg2: Int32, andExtra extra: UnsafeMutableRawPointer) {
        switch(waht) {
        case 200:
            listener?.onReadyToPlayListener()
            break
        default:
            break

        }
    }
    func display_pixelbuffer(_ pixelbuffer: CVPixelBuffer!) {
        listener?.onPixelBuffer(pixelBuffer: pixelbuffer)
    }
}
