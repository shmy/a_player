//
//  AVPlayerImpl.swift
//  a_player
//
//  Created by drm-chao wang on 2022/7/4.
//

import Foundation
import AVFoundation

class AVPlayerImpl: NSObject, APlayerInterface {

    private var avPlayer: AVPlayer? = AVPlayer.init()
    private var listener: APlayerListener?
    private var avPlayerItem: AVPlayerItem?
    private var avPlayerItemVideoOutput: AVPlayerItemVideoOutput?
    private var displayLink: CADisplayLink?
    var _duration: Int64 = 0
    var _isLoop: Bool = false
    var _isAutoPlay: Bool = false
    var duration: Int64 {
        get {
            return _duration
        }
    }
    
    var speed: Float {
        get {
            return avPlayer?.rate ?? 1.0
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
    @objc func onDisplayLink(_ displayLink: CADisplayLink) {
        if (avPlayerItemVideoOutput == nil) {
            return
        }
        listener?.onCurrentPositionChangedListener(position: cmtTimeToMillisecond(avPlayerItem!.currentTime()))
        let outputItemTime: CMTime = avPlayerItemVideoOutput!.itemTime(forHostTime: CACurrentMediaTime())
        if (avPlayerItemVideoOutput!.hasNewPixelBuffer(forItemTime: outputItemTime)) {
            let pixelBuffer: CVPixelBuffer? = avPlayerItemVideoOutput?.copyPixelBuffer(forItemTime: outputItemTime, itemTimeForDisplay: nil)
            if (pixelBuffer != nil) {
                listener?.onPixelBuffer(pixelBuffer: pixelBuffer!)
            }
        }
    }
    override init() {
        super.init()
        avPlayerItemVideoOutput = AVPlayerItemVideoOutput.init()
        displayLink = CADisplayLink.init(target: self, selector: #selector(onDisplayLink(_:)))
        displayLink?.add(to: .current, forMode: .common)
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
            listener?.onInitializedListener()
            listener?.onReadyToPlayListener()
            avPlayerItem?.add(avPlayerItemVideoOutput!)
            if (self._isAutoPlay) {
                self.play()
            }
            break
        case .failed:
            listener?.onErrorListener(code: "-1", message: "play error")
            break
        default:
            break
        }
    }
    private func onLoadedTimeRangesChanged() {
        let last = avPlayerItem?.loadedTimeRanges.last
        if (last == nil) {
            return
        }
        let range: CMTimeRange = last!.timeRangeValue
        let buffered = cmtTimeToMillisecond(range.end)
        listener?.onBufferedPositionChangedListener(buffered: buffered)
    }
    private func onPresentationSizeChanged() {
        let presentationSize = avPlayerItem!.presentationSize
        listener?.onVideoSizeChangedListener(width: Int32(presentationSize.width), height: Int32(presentationSize.height))
    }
    private func onDurationChanged() {
        _duration = cmtTimeToMillisecond(avPlayerItem!.duration)
    }
    private func onPlaybackLikelyToKeepUpChanged() {
        listener?.onLoadingEndListener()
        
    }
    private func onPlaybackBufferEmptyChanged() {
        listener?.onLoadingBeginListener()
        
    }
    private func onPlaybackBufferFull() {
        listener?.onLoadingEndListener()
        
    }
    private func cmtTimeToMillisecond(_ time: CMTime)-> Int64 {
        if (time.timescale == 0) {
            return 0
        }
        return time.value * 1000 / Int64(time.timescale)
    }
    func addListener(listener: APlayerListener) {
        self.listener = listener
    }
    func setHttpDataSource(url: String, startAtPositionMs: Int64, headers: Dictionary<String, String>) {
        avPlayerItem = AVPlayerItem.init(url: URL.init(string: url)!)
        bindEvent()
        avPlayer?.replaceCurrentItem(with: avPlayerItem!)
    }
    
    func setFileDataSource(path: String, startAtPositionMs: Int64) {
        setHttpDataSource(url: path, startAtPositionMs: startAtPositionMs, headers: Dictionary<String, String>.init())
    }
    
 
    func play() {
        avPlayer?.play()
    }
    
    func pause() {
        avPlayer?.pause()
    }
    
    func stop() {
        avPlayer?.pause()
    }
        
    func destroy() {
        displayLink?.remove(from: .current, forMode: .common)
        displayLink?.invalidate()
        displayLink?.isPaused = true
        displayLink = nil
        avPlayerItem = nil
        avPlayer?.replaceCurrentItem(with: nil)
        avPlayer = nil
    }
    
    func prepare(isAutoPlay: Bool) {
        self._isAutoPlay = isAutoPlay
        avPlayer?.play()
    }
    
    func seekTo(positionMs: Int64) {
        let position = CMTimeMakeWithSeconds(Double(positionMs) / 1000, preferredTimescale: avPlayerItem!.currentTime().timescale)
        avPlayer?.seek(to: position)
    }
    
    func setSpeed(speed: Float) {
        avPlayer?.rate = speed
    }
    
    func setLoop(isLoop: Bool) {
        self._isLoop = isLoop
    }
    
}
