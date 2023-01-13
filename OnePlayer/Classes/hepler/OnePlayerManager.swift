//
//  OnePlayerManager.swift
//  VersaPlayerViewDemo
//
//  Created by Jie on 2023/1/11.
//

import UIKit
import AVFoundation

// MARK: - PlayerManagerExtension ----------------------------
class OnePlayerManagerExtension: NSObject {
    
    /// 这里需要使用weak , 不然内存泄漏
    weak var playerView: OnePlayerView?
    
    init(with playerView: OnePlayerView) {
        self.playerView = playerView
    }
    
    /// 初始化设置
    func _setup() {
        
    }
    
    /// 播放
    func play() {
        playerView?.play()
    }
    
    /// 暂停
    func pause() {
        playerView?.pause()
    }
    
    /// 播放 & 暂停
    func togglePlayback() {
        playerView?.togglePlayback()
    }
    
    /// 重播
    /// - Parameter isAutoPlay: 是否自动播放
    func rePlay(isAutoPlay: Bool = true) {
        playerView?.rePlay(isAutoPlay: isAutoPlay)
    }
    
    /// 指定进度播放
    /// - Parameters:
    ///   - time: 播放位置
    ///   - isAutoPlay: 是否自动播放
    func seek(to time: Double,
              isAutoPlay: Bool = true,
              completionHandler: @escaping (Bool) -> Void) {
        playerView?.seek(to: time, isAutoPlay: isAutoPlay, completionHandler: completionHandler)
    }
}

// MARK: - OnePlayerManager ----------------------------
class OnePlayerManager: OnePlayerManagerExtension {
    
    public var status: VideoPlayerManagerPlayerStatus = .none
    public weak var coordinator: OnePlayerControlsCoordinator?
    public var statusChangedHander: VideoPlayStatusHanderClosure? // 状态改变回调
    public var timeChangedHander: VideoPlayTimeHanderClosure? // 时间改变回调
    
    required init(with playerView: OnePlayerView, and coordinator: OnePlayerControlsCoordinator) {
        super.init(with: playerView)
        self.coordinator = coordinator
        playerView.playbackDelegate = self
        playerView.addSubview(coordinator)
        playerView.bringSubviewToFront(coordinator)
    }
    
    deinit {
        debugPrint("OnePlayerManager is deinit")
    }
    
    override func _setup() {
        
    }
    
    public func playerStatusDidChanged(status: VideoPlayerManagerPlayerStatus) {
        coordinator?.playerStatusDidChanged(status: status)
        statusChangedHander?(status)
    }
    
    public func timeDidChange(time: CMTime) {
        let timeValue = TimeInterval(time.seconds)
        coordinator?.timeDidChange(time: timeValue)
        timeChangedHander?(timeValue)
    }
}

extension OnePlayerManager: OnePlayerPlaybackDelegate {
    
    func playbackAssetLoaded(player: OnePlayer) {
        status = .assetLoaded
        playerStatusDidChanged(status: status)
    }
    
    func playbackPlayerReadyToPlay(player: OnePlayer) {
        status = .readyToPlay
        playerStatusDidChanged(status: status)
    }
    
    func playbackItemReadyToPlay(player: OnePlayer, item: OnePlayerItem) {
        status = .readyToPlay
        playerStatusDidChanged(status: status)
    }
    
    func playbackTimeDidChange(player: OnePlayer, to time: CMTime) {
        timeDidChange(time: time)
    }
    
    func playbackDidBegin(player: OnePlayer) {
        status = .didPlay
        playerStatusDidChanged(status: status)
    }
    
    func playbackDidPause(player: OnePlayer) {
        status = .didPause
        playerStatusDidChanged(status: status)
    }
    
    func playbackDidEnd(player: OnePlayer) {
        status = .didEnd
        playerStatusDidChanged(status: status)
    }
    
    func playbackStartBuffering(player: OnePlayer) {
        status = .buffering
        playerStatusDidChanged(status: status)
    }
    
    func playbackLoadedTimeRanges(player: OnePlayer, progress: CGFloat) {
        status = .loadedTimeRanges
        playerStatusDidChanged(status: status)
    }
    
    func playbackEndBuffering(player: OnePlayer) {
        status = .endBuffering
        playerStatusDidChanged(status: status)
    }
    
    func playbackDidFailed(with error: Error) {
        status = .failed
        playerStatusDidChanged(status: status)
    }
}

// MARK: - OnePlayerView Extension ----------------------------
extension OnePlayerView {
    
    var onePlayerManager: OnePlayerManager? {
        let manager = getExtension(with: "OnePlayerManager") as? OnePlayerManager
        return manager
    }

    func useOnePlayerManager(manager: OnePlayerManager?) {
        if let manager = manager {
            addExtension(extension: manager, with: "OnePlayerManager")
        }
    }
}
