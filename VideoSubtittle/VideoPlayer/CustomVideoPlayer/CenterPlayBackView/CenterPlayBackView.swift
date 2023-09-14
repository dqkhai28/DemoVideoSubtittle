//
//  CenterPlayBackView.swift
//  VideoSubtittle
//
//  Created by BM Kane on 11/09/2023.
//

import UIKit
import AVKit

class CenterPlayBackView: UIView {
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    private var player: AVPlayer?
    private var isVideoFinished: Bool = false
    private var rateObserver: NSKeyValueObservation?
    
    var didTapInsideView: (() -> Void)?
    
    private struct Constant {
        static let icPlay = UIImage(named: "ic-play-large")
        static let icPause = UIImage(named: "ic-pause-large")
        static let icReplay = UIImage(named: "ic-replay-large")
        static let timeSkipPercentage: Float64 = 0.05
        static let minTimeSkipValue: Float64 = 1.0
        static let maxTimeSkipValue: Float64 = 15.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
    
    deinit {
        rateObserver?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    func config(with player: AVPlayer) {
        self.player = player
        addObservers()
    }

    @IBAction func onTapPlayPauseButton(_ sender: UIButton) {
        guard let player = player else { return }
        if player.isPlaying {
            pauseVideo()
        } else {
            if isVideoFinished {
                replayVideo()
            } else {
                playVideo()
            }
        }
        self.didTapInsideView?()
    }
    
    @IBAction func onTapBackwardButton(_ sender: UIButton) {
        self.backForwardVideo(isForwarding: false)
        self.didTapInsideView?()
    }
    
    @IBAction func onTapForwardButton(_ sender: UIButton) {
        self.backForwardVideo(isForwarding: true)
        self.didTapInsideView?()
    }
}

// MARK: - Video Playback Controls
extension CenterPlayBackView {
    func playVideo() {
        player?.play()
    }
    
    func pauseVideo() {
        player?.pause()
    }
    
    func replayVideo() {
        isVideoFinished = false
        player?.seek(to: CMTime.zero, completionHandler: { [weak self] isFinished in
            self?.player?.play()
        })
    }
    
    func backForwardVideo(isForwarding: Bool = true) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else { return }
        var timeSkipValue = totalSeconds * Constant.timeSkipPercentage
        if timeSkipValue < Constant.minTimeSkipValue {
            timeSkipValue = Constant.minTimeSkipValue
        } else if timeSkipValue > Constant.maxTimeSkipValue {
            timeSkipValue = Constant.maxTimeSkipValue
        }
        let currentTime = CMTimeGetSeconds(player?.currentTime() ?? .zero)
        let newTime = isForwarding ? currentTime + timeSkipValue : currentTime - timeSkipValue
        let seekTime = CMTime(value: CMTimeValue(newTime), timescale: 1)
        player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
        if currentTime != totalSeconds || (currentTime == totalSeconds && !isForwarding) {
            playVideo()
        }
    }
}

// MARK: - Observers
private extension CenterPlayBackView {
    func addObservers() {
        addPlayerStatusObserver()
        addNotificationObserver()
    }
    
    func addPlayerStatusObserver() {
        rateObserver = player?.observe(\.rate, options: .new) { [weak self] currentPlayer, rate in
            guard let self = self else { return }
            if currentPlayer.rate != 0 {
                self.playPauseButton.setImage(Constant.icPause, for: .normal)
            } else {
                self.playPauseButton.setImage(Constant.icPlay, for: .normal)
            }
        }
    }
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    @objc func playerDidFinishPlaying() {
        isVideoFinished = true
        playPauseButton.setImage(Constant.icReplay, for: .normal)
    }
}
