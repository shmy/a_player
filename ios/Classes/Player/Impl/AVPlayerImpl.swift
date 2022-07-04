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
    private var avPlayerItem: AVPlayerItem?
    var _duration: Int64 = 0
    var duration: Int64 {
        get {
            return _duration
        }
    }
    
    var speed: Float = 0.0
    
    var isLoop: Bool = false
    
    var isAutoPlay: Bool = false
    override init() {
        super.init()
        bindEvent()
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch (keyPath) {
        case #keyPath(AVPlayerItem.status):
            onStatusChanged()
            break
        case #keyPath(AVPlayerItem.loadedTimeRanges):
            onLoadedTimeRangesChanged()
            break
        case #keyPath(AVPlayerItem.presentationSize):
            onPresentationSizeChanged()
            break
        case #keyPath(AVPlayerItem.duration):
            onDurationChanged()
            break
        case #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp):
            onPlaybackLikelyToKeepUpChanged()
            break
        case #keyPath(AVPlayerItem.isPlaybackBufferEmpty):
            onPlaybackBufferEmptyChanged()
            break
        case #keyPath(AVPlayerItem.isPlaybackBufferFull):
            onPlaybackBufferFull()
            break
        default:
            break
        }
    }
    
    private func bindEvent() {
        avPlayerItem = AVPlayerItem.init(url: URL.init(string: "")!)
        avPlayerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
        avPlayerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: .new, context: nil)
        avPlayerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.presentationSize), options: .new, context: nil)
        avPlayerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration), options: .new, context: nil)
        avPlayerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: .new, context: nil)
        avPlayerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: .new, context: nil)
        avPlayerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferFull), options: .new, context: nil)
    
    }
    private func onStatusChanged() {
        switch(avPlayerItem?.status) {
        case .readyToPlay:
            break
        case .failed:
            break
        case .unknown:
            break
        default:
            break
        }
    }
    private func onLoadedTimeRangesChanged() {
//        let d = cmtTimeToMillisecond(avPlayerItem?.loadedTimeRanges.last)
    }
    private func onPresentationSizeChanged() {
        let presentationSize = avPlayerItem!.presentationSize
        listener?.onVideoSizeChangedListener(width: Int32(presentationSize.width), height: Int32(presentationSize.height))
    }
    private func onDurationChanged() {
        _duration = cmtTimeToMillisecond(avPlayerItem!.duration)
    }
    private func onPlaybackLikelyToKeepUpChanged() {
        if (avPlayerItem!.isPlaybackLikelyToKeepUp) {
            listener?.onLoadingEndListener()
        }
    }
    private func onPlaybackBufferEmptyChanged() {
        if (avPlayerItem!.isPlaybackBufferEmpty) {
            listener?.onLoadingBeginListener()
        }
    }
    private func onPlaybackBufferFull() {
        if (avPlayerItem!.isPlaybackBufferFull) {
            listener?.onLoadingEndListener()
        }
    }
    private func cmtTimeToMillisecond(_ time: CMTime)-> Int64 {
        return time.value * 1000 / Int64(time.timescale)
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
