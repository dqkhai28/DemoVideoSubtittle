//
//  ViewController.swift
//  VideoSubtittle
//
//  Created by Kane on 04/09/2023.
//

import UIKit
import AVPlayerViewControllerSubtitles
import AVKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func playVideo() {
        // Video file
        guard let videoFile = Bundle.main.path(forResource: "trailer_720p", ofType: "mov"),
              // Subtitle file
              let subtitleFile = Bundle.main.path(forResource: "trailer_720p", ofType: "srt") else {
            return
        }
        let subtitleURL = URL(fileURLWithPath: subtitleFile)

        // Movie player
        let moviePlayer = AVPlayerViewController()
        moviePlayer.player = AVPlayer(url: URL(fileURLWithPath: videoFile))
        moviePlayer.showsPlaybackControls = true
        present(moviePlayer, animated: true, completion: nil)

        // Add subtitles
//        moviePlayer.addSubtitles()
//        do {
//            try moviePlayer.open(fileFromLocal: subtitleURL)
//        } catch {
//            print(error)
//        }
        moviePlayer.addSubtitles()
        do {
            try moviePlayer.open(fileFromLocal: subtitleURL, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }

        // Change text properties
        moviePlayer.subtitleLabel?.textColor = UIColor.red

        // Play
        moviePlayer.player?.play()
    }

    private func playRemoteVideo() {
//    https://www.youtube.com/watch?v=itnqEauWQZM

        guard let videoURL = URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_5MB.mp4"),          // Video file
              let subtitleURL = URL(string: "https://www.youtube.com/watch?v=itnqEauWQZM") else { // Subtitle file
            return
        }

        // Movie player
        let moviePlayer = AVPlayerViewController()
        moviePlayer.player = AVPlayer(url: videoURL)
        moviePlayer.showsPlaybackControls = true
        present(moviePlayer, animated: true, completion: nil)

//        moviePlayer.addSubtitles()
//        moviePlayer.open(fileFromRemote: subtitleURL, encoding: String.Encoding.utf8)
//
//        // Change text properties
//        moviePlayer.subtitleLabel?.textColor = UIColor.red

        // Play
        moviePlayer.player?.play()
    }

    @IBAction func onTapButton(_ sender: UIButton) {
        self.playVideo()
    }

    @IBAction func onTapPlayRemoteButton(_ sender: UIButton) {
        let vc = VideoPlayerViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

