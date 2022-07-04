//
//  AVPlayerImpl.swift
//  a_player
//
//  Created by drm-chao wang on 2022/7/4.
//

import Foundation
import AVFoundation

class AVPlayerImpl: NSObject, APlayerInterface {
 
  
    private let avPlayer: AVPlayer = AVPlayer.init()
    private var listener: APlayerListener?
    var duration: Int64 = 0
    
    var speed: Float = 0.0
    
    var isLoop: Bool = false
    
    var isAutoPlay: Bool = false
    override init() {
        super.init()
        avPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
    }
    override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == #keyPath(AVPlayerItem.status)) {
            
        }
    }
    func addListener(listener: APlayerListener) {
        self.listener = listener
    }
    
    func play() {
        avPlayer.play()
    }
    
    func pause() {
        avPlayer.pause()
    }
    
    func stop() {
        avPlayer.pause()
    }
    
    func enableHardwareDecoder(enabled: Bool) {
        //
    }
    
    func destroy() {
        //
    }
    
    func prepare(isAutoPlay: Bool) {
        avPlayer.play()
    }
    
    func seekTo(positionMs: Int64) {
        //
    }
    
    func setSpeed(speed: Float) {
        avPlayer.rate = speed
    }
    
    func setLoop(isLoop: Bool) {
        //
    }
    
}
