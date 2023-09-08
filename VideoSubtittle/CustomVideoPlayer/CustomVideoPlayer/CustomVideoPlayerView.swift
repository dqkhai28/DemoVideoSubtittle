//
//  CustomVideoPlayerView.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import UIKit
import AVFoundation

class CustomVideoPlayerView: UIView {
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var controlView: PlayBackView!

    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var isShowPlayBack = true

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

    func playVideo(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let playerItem = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: playerItem)
        controlView.playVideo()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showHidePlayBackView()
        }
    }

    func updateLayoutSubviews() {
        layoutIfNeeded()
        playerLayer.frame = videoView.bounds
    }

    private func config() {
        setupPlayer()
        controlView.config(with: player)
        let controlTapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewHandleTap))
        self.addGestureRecognizer(controlTapGesture)
    }

    private func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
    }

    @objc private func playerViewHandleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        guard let contentView = self.getViewsByType(type: PlayBackView.self).first else { return }

        if contentView.frame.contains(location) && isShowPlayBack {
            return
        }

        showHidePlayBackView()
    }
}

// MARK: - Show / Hide PlayBack
private extension CustomVideoPlayerView {
    func showHidePlayBackView() {
        isShowPlayBack = !isShowPlayBack
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
//            self.closeButton.alpha = !self.isShowPlayBack ? 0 : 1
            self.controlView.alpha = !self.isShowPlayBack ? 0 : 1
        })
//        if isShowPlayBack {
//            resetTimer()
//        }
    }
}
