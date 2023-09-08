//
//  CommentViewController.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import UIKit

class CommentViewController: BaseViewController {
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var commentTableView: UITableView!
    @IBOutlet private weak var commentTextView: UITextView!
    @IBOutlet private weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var shadowViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var contentViewLeftConstraint: NSLayoutConstraint!
    
    var topConstraintValue: CGFloat = 0
    var onDismiss: (() -> Void)?

    private var initialPosition: CGFloat = 0
    private var currentPosition: CGFloat = 0

    private struct Constants {
        static let swipeRangeToDismiss: CGFloat = 85
        static let presentTimeout: TimeInterval = 0.3
        static let dismissTimeout: TimeInterval = 0.15
        static var landscapeLeftValue: CGFloat {
            if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
                return (UIScreen.main.bounds.height * 3) / 5
            } else {
                return (UIScreen.main.bounds.width * 3) / 5
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.willTransition(to: newCollection, with: coordinator)
//
//        coordinator.animate(alongsideTransition: { (context) in
//            guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
//
//            if windowInterfaceOrientation.isLandscape {
//                // activate landscape changes
//                print("---debug---: is landscape mode")
//                self.contentViewTopConstraint.constant = 0
//                self.shadowViewTopConstraint.constant = 0
////                self.contentViewLeftConstraint.constant = Constants.landscapeLeftValue
//            } else {
//                // activate portrait changes
//                print("---debug---: is portrailt mode")
//                self.contentViewTopConstraint.constant = self.topConstraintValue
//                self.shadowViewTopConstraint.constant = self.topConstraintValue
//                self.contentViewLeftConstraint.constant = 0
//            }
//        })
//    }
    
    private func dismissView() {
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        if windowInterfaceOrientation.isLandscape {
            self.horizontalDismiss()
        } else {
            self.verticalDismiss()
        }
    }

    private func setupUI() {
        if topConstraintValue != 0 {
            self.contentViewTopConstraint.constant = topConstraintValue
            self.shadowViewTopConstraint.constant = topConstraintValue
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.headerView.addGestureRecognizer(panGesture)

        self.setupTableView()
    }

    private func setupTableView() {
        self.commentTableView.delegate = self
        self.commentTableView.dataSource = self
        self.commentTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began:
            initialPosition = contentViewTopConstraint.constant
        case .changed:
            currentPosition = initialPosition + translation.y
            if currentPosition <= initialPosition {
                currentPosition = initialPosition
            }
            UIView.animate(withDuration: 0.15) { [weak self] in
                guard let self = self else { return }
                self.contentViewTopConstraint.constant = self.currentPosition
                self.view.layoutIfNeeded()
            }
        case .ended, .cancelled:
            if translation.y > Constants.swipeRangeToDismiss {
                self.dismissView()
            } else {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.15, options: .curveEaseInOut) { [weak self] in
                    guard let self = self else { return }
//                    self.modalPaddingBottom.constant = -self.dampingSpace
                    self.contentViewTopConstraint.constant = self.topConstraintValue
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }

    @IBAction func onTapCloseButton(_ sender: UIButton) {
        self.dismissView()
    }

    @IBAction func onTapSendButton(_ sender: UIButton) {

    }
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell else {
            return UITableViewCell()
        }

        return cell
    }
}

// MARK: - Handle dismiss with animation
extension CommentViewController {
    func verticalPresent() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: Constants.presentTimeout) {
                self.contentViewTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func verticalDismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: Constants.dismissTimeout) {
                self.contentViewTopConstraint.constant = UIScreen.main.bounds.height
                self.view.layoutIfNeeded()
            } completion: { isFinished in
                self.onDismiss?()
            }
        }
    }
    
    private func horizontalDismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: Constants.dismissTimeout) {
                self.contentViewLeftConstraint.constant = self.contentView.frame.width
                self.view.layoutIfNeeded()
            } completion: { isFinished in
                self.onDismiss?()
            }
            
            self.contentViewLeftConstraint.constant = 0
        }
    }
}
