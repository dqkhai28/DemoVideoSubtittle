//
//  CustomVideoPlayerViewController.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import UIKit
import AVKit
import AVPlayerViewControllerSubtitles

class CustomVideoPlayerViewController: BaseViewController {
    @IBOutlet weak var customPlayerView: CustomVideoPlayerView!

    private struct Constant {
        static let urlString = "https://test-videos.co.uk/vids/jellyfish/mp4/h264/1080/Jellyfish_1080_10s_1MB.mp4"
    }

//    var player: AVPlayer!
//    var playerViewController: AVPlayerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        customPlayerView.playVideo(with: Constant.urlString)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customPlayerView.updateLayoutSubviews()
    }


//    private func setupPlayer() {
//        let urlString = "https://test-videos.co.uk/vids/jellyfish/mp4/h264/1080/Jellyfish_1080_10s_1MB.mp4"
//        guard let videoURL = URL(string: urlString),
//              let subtitleURLString = Bundle.main.path(forResource: "trailer_720p", ofType: "srt") else {
//            return
//        }
//        let subtitleURL = URL(fileURLWithPath: subtitleURLString)
//        self.player = AVPlayer(url: videoURL)
//        self.playerViewController = AVPlayerViewController()
//
//        playerViewController.player = self.player
//        playerViewController.view.frame = self.playerView.frame
//        playerViewController.showsPlaybackControls = true
//        playerViewController.player?.pause()
//
//        self.addChild(playerViewController)
//        self.playerView.addSubview(playerViewController.view)
//        self.playerViewController.view.snp.makeConstraints{ constrains in
//            constrains.edges.equalToSuperview()
//        }
//
//        playerViewController.addSubtitles()
//        do {
//            try playerViewController.open(fileFromLocal: subtitleURL, encoding: String.Encoding.utf8)
//        } catch {
//            print(error)
//        }
//
//        playerViewController.subtitleLabel?.textColor = UIColor.white
//    }
//
//    private func playVideo() {
//        playerViewController.player?.play()
//    }
}
