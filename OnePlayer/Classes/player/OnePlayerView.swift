//
//  OnePlayerView.swift
//  VersaPlayerViewDemo
//
//  Created by Jie on 2023/1/9.
//

import UIKit
import AVFoundation

class OnePlayerItem: AVPlayerItem { }

class OnePlayerView: UIView {
    
    // MARK: - UI ----------------------------
    /// 播放器
    var player: OnePlayer!
    /// 播放回调
    weak var playbackDelegate: OnePlayerPlaybackDelegate?
    /// 渲染的playerView
    var renderingView: OnePlayerRenderingView!
    // MARK: - Data ----------------------------
    // -----------------Public-----------------------
    /// 是否自动播放, 默认true
    var isAutoPlay: Bool = true
    // -----------------Private-----------------------
    /// 是否正常播放
    private var isPlaying: Bool = false
    /// 存储extension
    private var extensions: [String: OnePlayerManagerExtension] = [:]
    
    // MARK: - Life Cycle ----------------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Init Method ----------------------------
    func setup() {
        player = OnePlayer()
        player.handler = self
        player.setupPlayer()
        renderingView = OnePlayerRenderingView(with: self)
        addSubview(renderingView)
    }
    
    // MARK: - Public Method ----------------------------
    /// 设置播放的item
    /// - Parameter item: player item
    func set(item: OnePlayerItem?) {
        player.replaceCurrentItem(with: item)
        if isAutoPlay && item?.error == nil {
            play()
        }
    }
    
    /// 播放
    func play() {
        player.play()
        isPlaying = true
    }
    
    /// 暂停
    func pause() {
        player.pause()
        isPlaying = false
    }
    
    /// 播放 & 暂停
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    /// 重播
    /// - Parameter isAutoPlay: 是否自动播放
    func rePlay(isAutoPlay: Bool = true) {
        seek(to: 0.0, isAutoPlay: isAutoPlay) { _ in }
    }
    
    /// 指定进度播放
    /// - Parameters:
    ///   - time: 播放位置
    ///   - isAutoPlay: 是否自动播放
    func seek(to time: Double,
              isAutoPlay: Bool = true,
              completionHandler: @escaping (Bool) -> Void) {
        let toTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // 精确播放
        player.seek(to: toTime, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { [weak self] finished in
            if finished {
                if isAutoPlay {
                    self?.play()
                }
            }
            completionHandler(finished)
        })
    }
    
    /// 添加player extension
    /// - Parameters:
    ///   - ext: OnePlayerManagerExtension
    ///   - name: name
    func addExtension(extension ext: OnePlayerManagerExtension, with name: String) {
        ext.playerView = self
        ext._setup()
        extensions[name] = ext
    }
    
    /// 获取player extension
    /// - Parameter name: name
    /// - Returns: extenison
    open func getExtension(with name: String) -> OnePlayerManagerExtension? {
        return extensions[name]
    }
}
