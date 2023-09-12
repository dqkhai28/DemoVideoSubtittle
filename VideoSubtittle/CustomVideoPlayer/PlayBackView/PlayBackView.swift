//
//  PlayBackView.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import UIKit
import AVFoundation

final class PlayBackView: UIView {
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var speakerButton: UIButton!
    @IBOutlet private weak var volumeView: CustomVolumeView!
    @IBOutlet private weak var timeSlider: UISlider!
    @IBOutlet private weak var timeRemainingLabel: UILabel!
    @IBOutlet private weak var volumeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var expandShrinkButton: UIButton!
    
    private var player: AVPlayer?
    private var isVideoFinished: Bool = false
    private var rateObserver: NSKeyValueObservation?
    private var isMuted: Bool = false
    
    var didTapInsideView: (() -> Void)?
    
    private struct Constant {
        static let icPlay = UIImage(named: "ic-play")
        static let icPause = UIImage(named: "ic-pause")
        static let icReplay = UIImage(named: "ic-replay")
        static let icTrack = UIImage(named: "ic-track")
        static let icAudio = UIImage(named: "ic-audio")
        static let icNoAudio = UIImage(named: "ic-no-audio")
        static let icExpand = UIImage(named: "ic-landscape-expand")
        static let icShrink = UIImage(named: "ic-portrait-shrink")
        static let minWidthVolumeSlider: CGFloat = 0
        static let maxWidthVolumeSlider: CGFloat = 80
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
        setup()
    }
    
    deinit {
        rateObserver?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    func config(with player: AVPlayer) {
        self.player = player
        addObservers()
    }
    
    private func setup() {
        timeSlider.setThumbImage(Constant.icTrack, for: .normal)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged(_:event:)), for: .valueChanged)
        speakerButton.setImage(isMuted ? Constant.icNoAudio : Constant.icAudio, for: .normal)
        volumeView.didTapInsideView = { [weak self] in
            guard let self = self else { return }
            self.didTapInsideView?()
        }
    }
    
    @objc private func timeSliderValueChanged(_ sender: UISlider, event: UIEvent) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else { return }
        let value = Float64(sender.value) * totalSeconds
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        
        // Seek and scrub video
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                pauseVideo()
            case .moved:
                player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
            case .ended:
                playVideo()
                isVideoFinished = false
            default:
                break
            }
        }
        
        // Update time remaining label
        let timeRemaining = duration - seekTime
        guard let timeRemainingString = timeRemaining.getTimeString() else { return }
        timeRemainingLabel.text = timeRemainingString
        self.didTapInsideView?()
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
    
    @IBAction func onTapExpandShrinkButton(_ sender: UIButton) {
        if sender.isSelected {
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        } else {
            AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeLeft)
        }
        sender.isSelected.toggle()
        self.didTapInsideView?()
    }
    
    @IBAction func onTapSpeakerButton(_ sender: UIButton) {
        isMuted = !isMuted
        player?.isMuted = isMuted
        speakerButton.setImage(isMuted ? Constant.icNoAudio : Constant.icAudio, for: .normal)
        showHideVolumeSlider()
        self.didTapInsideView?()
    }
    
    private func showHideVolumeSlider() {
        volumeView.isHidden = isMuted
        volumeViewWidthConstraint.constant = isMuted ? Constant.minWidthVolumeSlider : Constant.maxWidthVolumeSlider
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Play, Pause, Replay Video
extension PlayBackView {
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
}

// MARK: - Observers
private extension PlayBackView {
    func addObservers() {
        // Observer player's status
        addNotificationObserver()
        addPlayerStatusObserver()
        addTimeObserver()
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
    
    func addTimeObserver() {
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] progressTime in
            self?.updateVideoPlayerState(progressTime: progressTime)
        })
    }
    
    func updateVideoPlayerState(progressTime: CMTime) {
        // Update time slider's value
        guard let duration = player?.currentItem?.duration else { return }
        timeSlider.value = Float(progressTime.seconds / duration.seconds)
        
        // Update time remaining label
        let timeRemaining = duration - progressTime
        guard let timeRemainingString = timeRemaining.getTimeString() else { return }
        timeRemainingLabel.text = timeRemainingString
    }
}
