//
//  CustomVideoPlayerView.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import UIKit
import AVFoundation
import AVPlayerViewControllerSubtitles
import AVKit
import SnapKit

class CustomVideoPlayerView: UIView {
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var controlView: PlayBackView!
    @IBOutlet private weak var centerControlView: CenterPlayBackView!
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var playerViewController: AVPlayerViewController!
    private var isShowPlayBack = true
    private var fadingTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
        config()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
        config()
    }
    
    deinit {
        self.fadingTimer?.invalidate()
    }

    func playVideo(with videURL: URL, subtitleURL: URL) {
        let playerItem = AVPlayerItem(url: videURL)
        player?.replaceCurrentItem(with: playerItem)
        controlView.playVideo()
        
        self.startFadingTimer()
    }

    func updateLayoutSubviews() {
        layoutIfNeeded()
        playerLayer.frame = videoView.bounds
    }

    func config() {
        setupPlayer()
        controlView.config(with: player)
        centerControlView.config(with: player)
        let controlTapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewHandleTap))
        self.addGestureRecognizer(controlTapGesture)
        controlView.didTapInsideView = { [weak self] in
            guard let self = self else { return }
            self.startFadingTimer()
        }
        centerControlView.didTapInsideView = { [weak self] in
            guard let self = self else { return }
            self.startFadingTimer()
        }
    }

    private func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
    }

    @objc private func playerViewHandleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if isShowPlayBack {
            hidePlaybackViews()
        } else {
            showPlaybackViews()
        }
    }
}

// MARK: - Show / Hide PlayBack
private extension CustomVideoPlayerView {
    private func startFadingTimer() {
        self.fadingTimer?.invalidate()
        self.fadingTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.hidePlaybackViews()
        }
    }
    
    private func showPlaybackViews() {
        isShowPlayBack = true
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.controlView.alpha = 1
            self.centerControlView.alpha = 1
        })
        self.startFadingTimer()
    }
    
    private func hidePlaybackViews() {
        self.isShowPlayBack = false
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.controlView.alpha = 0
            self.centerControlView.alpha = 0
        })
    }
}
