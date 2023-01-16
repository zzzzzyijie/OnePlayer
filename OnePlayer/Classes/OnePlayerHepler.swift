//
//  OnePlayerHepler.swift
//  VersaPlayerViewDemo
//
//  Created by Jie on 2023/1/9.
//

import UIKit
import Foundation
import AVFoundation

// MARK: - OnePlayerPlaybackDelegate ----------------------------
protocol OnePlayerPlaybackDelegate: AnyObject {
    /// 资源已加载
    func playbackAssetLoaded(player: OnePlayer)
    
    /// 准备播放（可播放
    func playbackPlayerReadyToPlay(player: OnePlayer)
    
    /// 当前item准备播放（可播放
    func playbackItemReadyToPlay(player: OnePlayer, item: OnePlayerItem)
    
    /// 时间改变
    func playbackTimeDidChange(player: OnePlayer, to time: CMTime)
    
    /// 开始播放（点击 play
    func playbackDidBegin(player: OnePlayer)
    
    /// 暂停播放 （点击 pause
    func playbackDidPause(player: OnePlayer)
    
    /// 播放到结束
    func playbackDidEnd(player: OnePlayer)
    
    /// 开始缓冲
    func playbackStartBuffering(player: OnePlayer)
    
    /// 缓冲的进度
    func playbackLoadedTimeRanges(player: OnePlayer, progress: CGFloat)
    
    /// 缓存完毕
    func playbackEndBuffering(player: OnePlayer)
    
    /// 播放错误
    func playbackDidFailed(with error: Error)
}

extension OnePlayerPlaybackDelegate {
    func playbackAssetLoaded(player: OnePlayer) { }
    func playbackPlayerReadyToPlay(player: OnePlayer) { }
    func playbackItemReadyToPlay(player: OnePlayer, item: OnePlayerItem) { }
    func playbackTimeDidChange(player: OnePlayer, to time: CMTime) { }
    func playbackDidBegin(player: OnePlayer) { }
    func playbackDidPause(player: OnePlayer) { }
    func playbackDidEnd(player: OnePlayer) { }
    func playbackStartBuffering(player: OnePlayer) { }
    func playbackLoadedTimeRanges(player: OnePlayer, progress: CGFloat) { }
    func playbackEndBuffering(player: OnePlayer) { }
    func playbackDidFailed(with error: Error) { }
}

// MARK: - Error ----------------------------
// 自定义的错误
enum OnePlayerError: Error {
    case unknown // 未知错误
}

extension OnePlayerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Player遇到未知错误"
        }
    }
}


// MARK: - OnePlayerObserverKey ----------------------------
enum OnePlayerObserverKey: String, CaseIterable {
    case status = "status"
    case playbackBufferEmpty = "playbackBufferEmpty"
    case loadedTimeRanges = "loadedTimeRanges"
    case playbackLikelyToKeepUp = "playbackLikelyToKeepUp"
    case playbackBufferFull = "playbackBufferFull"
}
