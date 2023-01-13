//
//  OnePlayer.swift
//  VersaPlayerViewDemo
//
//  Created by Jie on 2023/1/9.
//

import UIKit
import AVFoundation

class OnePlayer: AVPlayer {
    
    // MARK: - Data ----------------------------
    /// player view
    weak var handler: OnePlayerView?
    /// time Observer
    private var timeObserver: Any?
    
    // MARK: - Init Method ----------------------------
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self)
        removeObserver(self, forKeyPath: OnePlayerObserverKey.status.rawValue)
        if let timeObserver = timeObserver {
            removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
    
    // MARK: - Method ----------------------------
    /// 配置player
    func setupPlayer() {
        // 监听 didEnd
        NotificationCenter.default.addObserver(self,selector: #selector(playerDidEnd),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.currentItem)
        
        // 监听player播放时间的改变
        let oneSeconds = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = addPeriodicTimeObserver(forInterval: oneSeconds, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.handler?.playbackDelegate?.playbackTimeDidChange(player: self, to: time)
        }
        
        // 监听player status
        addObserver(self,forKeyPath: OnePlayerObserverKey.status.rawValue,options: .new, context: nil)
    }
    
    /// 获取当前缓冲的进度
    /// - Returns: 进度比例
    private func getCurrentLoadRange() -> CGFloat {
        guard let item = currentItem else { return 0.0 }
        // 本次缓冲的时间范围 (loadedTimeRanges所有进度
        guard let timeRange = item.loadedTimeRanges.first?.timeRangeValue else { return 0.0 }
        // 缓冲总长度
        let totalLoadTime = CMTimeGetSeconds(timeRange.start) +  CMTimeGetSeconds(timeRange.duration)
        // 总的时间长度
        let duration = endTime()
        if duration <= 0 {
            return 0.0
        }
        // 计算缓冲百分比例
        let scale = totalLoadTime/duration
        debugPrint("缓冲时长，已缓冲：\(totalLoadTime),总时长：\(duration),缓冲百分比：\(scale)")
        return scale
    }
    
    // MARK: - Touch Event ----------------------------
    /// 播放结束的回调
    /// - Parameter notification: note
    @objc private func playerDidEnd(_ notification: Notification) {
        if let item = notification.object as? AVPlayerItem,
           item == currentItem {
            handler?.playbackDelegate?.playbackDidEnd(player: self)
        }
    }
    
    // MARK: - Override ----------------------------
    override func play() {
        super.play()
        handler?.playbackDelegate?.playbackDidBegin(player: self)
    }
    
    override func pause() {
        super.pause()
        handler?.playbackDelegate?.playbackDidPause(player: self)
    }
    
    override func replaceCurrentItem(with item: AVPlayerItem?) {
        if let item = currentItem {
            OnePlayerObserverKey.allCases.forEach { key in
                item.removeObserver(self, forKeyPath: key.rawValue)
            }
        }
        super.replaceCurrentItem(with: item)
        if let newItem = currentItem ?? item {
            handler?.playbackDelegate?.playbackAssetLoaded(player: self)
            OnePlayerObserverKey.allCases.forEach { key in
                newItem.addObserver(self, forKeyPath: key.rawValue, options: .new, context: nil)
            }
        }
    }
    
    // MARK: - Observer ----------------------------
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let handler = handler else {
            return
        }
        // player 的 status
        let keyPathValue = OnePlayerObserverKey(rawValue: keyPath ?? "")
        if let obj = object as? OnePlayer, obj == self {
            if keyPathValue == .status {
                switch obj.status {
                case .readyToPlay:
                    handler.playbackDelegate?.playbackPlayerReadyToPlay(player: self)
                    break
                case .failed:
                    handler.playbackDelegate?.playbackDidFailed(with: OnePlayerError.unknown)
                    break
                default:
                    break
                }
            }
        }else {
        // player item 的 value
            switch keyPathValue {
            case .status:
                // item 信息 有值
                if let item = object as? AVPlayerItem,
                   let value = change?[.newKey] as? Int,
                   let itemStatus = AVPlayerItem.Status(rawValue: value) {
                    switch itemStatus {
                    case .readyToPlay:
                        if let oneItem = currentItem as? OnePlayerItem {
                            handler.playbackDelegate?.playbackItemReadyToPlay(player: self, item: oneItem)
                        }
                        break
                    case .failed:
                        if let error = item.error {
                            handler.playbackDelegate?.playbackDidFailed(with: error)
                        }else {
                            handler.playbackDelegate?.playbackDidFailed(with: OnePlayerError.unknown)
                        }
                        break
                    default:
                        break
                    }
                }
                break
            case .playbackBufferEmpty:
                if currentItem?.isPlaybackBufferEmpty == true {
                    handler.playbackDelegate?.playbackStartBuffering(player: self)
                }
                break
            case .loadedTimeRanges:
                let rangeProgress = getCurrentLoadRange()
                if rangeProgress > 0 {
                    handler.playbackDelegate?.playbackLoadedTimeRanges(player: self, progress: rangeProgress)
                }
                break
            case .playbackLikelyToKeepUp:
                if currentItem?.isPlaybackLikelyToKeepUp == true {
                    handler.playbackDelegate?.playbackEndBuffering(player: self)
                }
                break
            case .playbackBufferFull:
                if currentItem?.isPlaybackBufferFull == true {
                    handler.playbackDelegate?.playbackEndBuffering(player: self)
                }
                break
            default:
                break
            }
        }
    }
}


extension OnePlayer {
    
    /// 开始时间
    /// - Returns: CMTime
    func startTime() -> TimeInterval {
        guard let item = currentItem else {
            return 0.0
        }
        let value = item.currentTime()
        if !value.seconds.isNaN {
            return value.seconds
        }else {
            return 0.0
        }
    }
    
    
    /// 结束时间 ( duration
    /// - Returns: CMTime
    func endTime() -> TimeInterval {
        guard let item = currentItem else {
            return 0.0
        }
        let value = item.duration
        if !value.seconds.isNaN {
            return value.seconds
        }else {
            return 0.0
        }
    }
}
