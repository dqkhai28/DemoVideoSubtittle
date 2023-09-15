//
//  VideoPlayerViewController.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import UIKit
import AVKit
import SnapKit

class VideoPlayerViewController: BaseViewController {
    @IBOutlet private weak var playerView: CustomVideoPlayerView!
    @IBOutlet private weak var playerViewRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var playerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var commentView: CommentView!
    @IBOutlet private weak var commentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var commentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var commentViewRightConstraint: NSLayoutConstraint!
    
    private var isShowingComment: Bool = true {
        didSet {
            self.updatePlayerLayouts()
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
    
    private struct Constants {
        static var horizontalCommentViewWidth: CGFloat {
            if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
                return UIScreen.main.bounds.height / 3
            } else {
                return UIScreen.main.bounds.width / 3
            }
        }
        static let presentTimeout: TimeInterval = 0.3
        static let dismissTimeout: TimeInterval = 0.3
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupPlayer()
        self.updateCommentView()
        self.updateSubtitleFontSize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerView.updateLayoutSubviews()
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        if windowInterfaceOrientation.isPortrait, self.commentViewDefaultTopValue == 0 {
            self.commentViewDefaultTopValue = self.playerView.frame.maxY
        }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.updatePlayerLayouts()
            self.updateCommentView()
            self.updateSubtitleFontSize()
        })
    }
    
    private func setupUI() {
        self.updatePlayerLayouts()
        self.commentView.onTapDismiss = { [weak self] in
            guard let self = self else { return }
            
            self.dismissCommentView()
        }
        self.playerView.onTapShowHideComment = { [weak self] in
            guard let self = self,
                  let windowInterfaceOrientation = self.windowInterfaceOrientation else {
                return
            }
            
            if windowInterfaceOrientation == .portrait {
                return
            } else {
                if self.isShowingComment {
                    self.dismissCommentView()
                } else {
                    self.showCommentView()
                }
            }
        }
    }

    private func setupPlayer() {
        let urlString = "https://test-videos.co.uk/vids/jellyfish/mp4/h264/1080/Jellyfish_1080_10s_1MB.mp4"
        guard let videoURL = URL(string: urlString),
              let subtitleURLString = Bundle.main.path(forResource: "trailer_720p", ofType: "srt") else {
            return
        }
        let subtitleURL = URL(fileURLWithPath: subtitleURLString)
        playerView.playVideo(with: videoURL, subtitleURL: subtitleURL)
    }
    
    private func updatePlayerLayouts() {
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        
        if windowInterfaceOrientation.isLandscape {
            // activate landscape changes
            self.navigationController?.isNavigationBarHidden = true
            self.playerHeight = UIScreen.main.bounds.height
            self.playerViewRightConstraint.constant = self.isShowingComment ? Constants.horizontalCommentViewWidth : 0
            self.commentViewWidthConstraint.constant = Constants.horizontalCommentViewWidth
            self.commentViewTopConstraint.constant =  0
            self.commentViewRightConstraint.constant = self.isShowingComment ? 0 : -Constants.horizontalCommentViewWidth
        } else {
            // activate portrait changes
            self.navigationController?.isNavigationBarHidden = false
            self.playerHeight = UIScreen.main.bounds.width / 2
            self.playerViewRightConstraint.constant = 0
            self.commentViewWidthConstraint.constant = UIScreen.main.bounds.width
            self.commentViewTopConstraint.constant = self.commentViewDefaultTopValue
            self.commentViewRightConstraint.constant = 0
        }
    }
    
    private func updateCommentView() {
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        self.commentView.updateUI(in: windowInterfaceOrientation)
        self.playerView.hideMessageButtonIfNeeded(isHidden: windowInterfaceOrientation == .portrait)
    }
    
    private func updateSubtitleFontSize() {
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        self.playerView.updateSubFontSize(orientation: windowInterfaceOrientation)
    }
}

// MARK: - Handle show/hide comment view
extension VideoPlayerViewController {
    private func showCommentView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isShowingComment = true
            UIView.animate(withDuration: Constants.dismissTimeout) {
                self.commentViewRightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func dismissCommentView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isShowingComment = false
            UIView.animate(withDuration: Constants.dismissTimeout) {
                self.commentViewRightConstraint.constant = -Constants.horizontalCommentViewWidth
                self.view.layoutIfNeeded()
            }
        }
    }
}
