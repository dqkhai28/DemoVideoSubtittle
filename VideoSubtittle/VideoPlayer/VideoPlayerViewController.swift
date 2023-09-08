//
//  VideoPlayerViewController.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import UIKit
import AVPlayerViewControllerSubtitles
import AVKit
import SnapKit

class VideoPlayerViewController: BaseViewController {
    @IBOutlet private weak var playerView: UIView!
    @IBOutlet private weak var playerViewRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var playerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var commentView: UIView!
    @IBOutlet private weak var commentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var commentViewLeftConstraint: NSLayoutConstraint!
    
    var player: AVPlayer!
    var playerViewController: AVPlayerViewController!
    private var isShowingComment: Bool = false {
        didSet {
            self.updatePlayerLayouts()
            self.commentView.isHidden = !isShowingComment
        }
    }
    private var playerHeight: CGFloat = 0 {
        didSet {
            self.playerViewHeightConstraint.constant = playerHeight
        }
    }
    private var commentViewDefaultTopValue: CGFloat = 0 {
        didSet {
            self.commentViewTopConstraint.constant = self.commentViewDefaultTopValue
        }
    }
    
    private struct Constant {
        static var horizontalCommentViewWidth: CGFloat {
            if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
                return (UIScreen.main.bounds.height * 2) / 5 - (2 * UIApplication.safeAreaLeftInset())
            } else {
                return (UIScreen.main.bounds.width * 2) / 5 - (2 * UIApplication.safeAreaLeftInset())
            }
        }
        static var commentViewLeftValue: CGFloat {
            if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
                return (UIScreen.main.bounds.height * 3) / 5
            } else {
                return (UIScreen.main.bounds.width * 3) / 5
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupPlayer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        if windowInterfaceOrientation.isPortrait, self.commentViewDefaultTopValue == 0 {
            self.commentViewDefaultTopValue = self.playerView.frame.maxY
        }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.updatePlayerLayouts()
        })
    }
    
    private func setupUI() {
        self.updatePlayerLayouts()
        
    }

    private func setupPlayer() {
        let urlString = "https://test-videos.co.uk/vids/jellyfish/mp4/h264/1080/Jellyfish_1080_10s_1MB.mp4"
        guard let videoURL = URL(string: urlString),
              let subtitleURLString = Bundle.main.path(forResource: "trailer_720p", ofType: "srt") else {
            return
        }
        let subtitleURL = URL(fileURLWithPath: subtitleURLString)
        self.player = AVPlayer(url: videoURL)
        self.playerViewController = AVPlayerViewController()

        playerViewController.player = self.player
        playerViewController.view.frame = self.playerView.frame
        playerViewController.showsPlaybackControls = true
        playerViewController.player?.pause()

        self.addChild(playerViewController)
        self.playerView.addSubview(playerViewController.view)
        self.playerViewController.view.snp.makeConstraints{ constrains in
            constrains.edges.equalToSuperview()
        }

        playerViewController.addSubtitles()
        do {
            try playerViewController.open(fileFromLocal: subtitleURL, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }

        playerViewController.subtitleLabel?.textColor = UIColor.white
    }

    private func playVideo() {
        playerViewController.player?.play()
    }
    
    private func updatePlayerLayouts() {
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        
        if windowInterfaceOrientation.isLandscape {
            // activate landscape changes
            self.playerHeight = UIScreen.main.bounds.height
            self.playerViewRightConstraint.constant = self.isShowingComment ? Constant.horizontalCommentViewWidth : 0
            self.commentViewLeftConstraint.constant = Constant.commentViewLeftValue
            self.commentViewTopConstraint.constant =  0
        } else {
            // activate portrait changes
            self.playerHeight = UIScreen.main.bounds.width / 2
            self.playerViewRightConstraint.constant = 0
            self.commentViewLeftConstraint.constant = 0
            self.commentViewTopConstraint.constant = self.commentViewDefaultTopValue
        }
    }
    
    private func showFullScreenPlayerIfNeeded() {
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        
        if windowInterfaceOrientation.isLandscape {
//            self.commentViewLeftConstraint.constant = 0
//            self.view.layoutIfNeeded()
            self.playerViewController.goFullScreen()
        }
    }

    @IBAction func onTapShowCommentsButton(_ sender: UIButton) {
        self.showComment()
    }
    
    func showComment() {
        self.isShowingComment = true
        
        if let commentVC = self.children.first(where: { $0 is CommentViewController }) as? CommentViewController {
            commentVC.verticalPresent()
        } else {
            let vc = CommentViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.topConstraintValue = 0
            vc.onDismiss = { [weak self] in
                guard let self = self else { return }
                self.isShowingComment = false
                self.showFullScreenPlayerIfNeeded()
            }
            self.addAndDisplayChildViewController(vc)
        }
    }
}

extension VideoPlayerViewController {
    fileprivate func addAndDisplayChildViewController(_ childViewController: UIViewController) {
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        commentView.addSubview(childViewController.view)
        childViewController.view.snp.makeConstraints { constraints in
            constraints.edges.equalToSuperview()
        }
        
        childViewController.willMove(toParent: self)
        addChild(childViewController)
    }
    
    fileprivate func removeAndDismissChildViewController(_ childViewController: UIViewController) {
        childViewController.view.removeFromSuperview()
        childViewController.willMove(toParent: nil)
        childViewController.removeFromParent()
    }
}
