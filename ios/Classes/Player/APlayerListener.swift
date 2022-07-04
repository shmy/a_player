//
//  APlayerListener.swift
//  a_player
//
//  Created by drm-chao wang on 2022/7/4.
//

import Foundation

protocol APlayerListener {
    func onInitializedListener() -> Void
    func onPlayingListener(isPlaying: Bool) -> Void
    func onErrorListener(code: String, message: String) -> Void
    func onCompletionListener() -> Void
    func onReadyToPlayListener() -> Void
    func onVideoSizeChangedListener(width: Int32, height: Int32) -> Void
    func onCurrentPositionChangedListener(position: Int64) -> Void
    func onCurrentDownloadSpeedChangedListener(speed: Int64) -> Void
    func onBufferedPositionChangedListener(buffered: Int64) -> Void
    func onSwitchToSoftwareVideoDecoderListener() -> Void
    func onLoadingBeginListener() -> Void
    func onLoadingProgressListener(percent: Int) -> Void
    func onLoadingEndListener() -> Void
    
}
