//
//  AliyunPlayerImpl.swift
//  a_player
//
//  Created by drm-chao wang on 2022/7/4.
//

import Foundation
import AliyunPlayer

class AliyunPlayer: NSObject, APlayerInterface, AVPDelegate {
    private let aliPlayer: AliPlayer = AliPlayer.init()
    private var listener: APlayerListener?
    var duration: Int64 = 0
    
    var speed: Float = 0
    
    var isLoop: Bool = false
    
    var isAutoPlay: Bool = false
    
    override init() {
        super.init()
        aliPlayer.delegate = self
    }
    func addListener(listener: APlayerListener) {
        self.listener = listener
    }
    
    func play() {
        aliPlayer.start()
    }
    
    func pause() {
        aliPlayer.pause()
    }
    
    func stop() {
        aliPlayer.stop()
    }
    
    func destroy() {
        aliPlayer.destroy()
    }
    
    func prepare(isAutoPlay: Bool) {
        aliPlayer.isAutoPlay = isAutoPlay
        aliPlayer.prepare()
    }
    
    func seekTo(positionMs: Int64) {
        aliPlayer.seek(toTime: positionMs, seekMode: AVP_SEEKMODE_ACCURATE)
    }
    
    func setSpeed(speed: Float) {
        aliPlayer.rate = speed
    }
    
    func setLoop(isLoop: Bool) {
        aliPlayer.isLoop = isLoop
    }
    
    func onPlayerEvent(_ player: AliPlayer!, eventType: AVPEventType) {
        switch(eventType) {
        case AVPEventPrepareDone:
            listener?.onInitializedListener()
            break
        case AVPEventLoadingStart:
            listener?.onLoadingBeginListener()
            break
        case AVPEventLoadingEnd:
            listener?.onLoadingEndListener()
            break
        case AVPEventFirstRenderedStart:
            listener?.onReadyToPlayListener()
            break
        default:
            break
        }
    }
    func onVideoSizeChanged(_ player: AliPlayer!, width: Int32, height: Int32, rotation: Int32) {
        listener?.onVideoSizeChangedListener(width: width, height: height)
    }
    func onError(_ player: AliPlayer!, errorModel: AVPErrorModel!) {
        listener?.onErrorListener(code: "\(errorModel.code)", message: errorModel.message)
    }

    func onCurrentDownloadSpeed(_ player: AliPlayer!, speed: Int64) {
        listener?.onCurrentDownloadSpeedChangedListener(speed: speed)
    }
    func onCurrentPositionUpdate(_ player: AliPlayer!, position: Int64) {
        listener?.onCurrentPositionChangedListener(position: position)
    }
    func onLoadingProgress(_ player: AliPlayer!, progress: Float) {
        listener?.onLoadingProgressListener(percent: Int(progress))
    }
    func onBufferedPositionUpdate(_ player: AliPlayer!, position: Int64) {
        listener?.onBufferedPositionChangedListener(buffered: position)
    }
    func onPlayerStatusChanged(_ player: AliPlayer!, oldStatus: AVPStatus, newStatus: AVPStatus) {
        if (newStatus == AVPStatusStarted) {
            listener?.onPlayingListener(isPlaying: true)
        } else {
            listener?.onPlayingListener(isPlaying: false)
        }
        if (newStatus == AVPStatusCompletion) {
            listener?.onCompletionListener()
        }
    }
}
