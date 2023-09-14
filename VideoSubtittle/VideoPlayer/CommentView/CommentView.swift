//
//  CommentView.swift
//  VideoSubtittle
//
//  Created by BM Kane on 13/09/2023.
//

import UIKit

class CommentView: UIView {
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var contentLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var infoView: UIView!
    @IBOutlet private weak var messageHeaderView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var commentPinView: UIView!
    @IBOutlet private weak var commentHistoryTableView: UITableView!
    @IBOutlet private weak var pinnedCommentCollectionView: UICollectionView!
    
    var onTapDismiss: (() -> Void)?
    
    private struct Constants {

    }
    
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
    
    private func config() {
        setupTableView()
        setupCollectionView()
    }
    
    private func setupTableView() {
        self.commentHistoryTableView.delegate = self
        self.commentHistoryTableView.dataSource = self
        self.commentHistoryTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
    }
    
    private func setupCollectionView() {
        self.pinnedCommentCollectionView.delegate = self
        self.pinnedCommentCollectionView.dataSource = self
        self.pinnedCommentCollectionView.register(UINib(nibName: "PinnedCommentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PinnedCommentCollectionViewCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        self.pinnedCommentCollectionView.collectionViewLayout = flowLayout
    }
    
    func updateUI(in orientation: UIInterfaceOrientation) {
        self.infoView.isHidden = orientation == .landscapeRight
        self.closeButton.isHidden = orientation == .portrait
    }
    
    @IBAction func onTapCloseButton(_ sender: UIButton) {
        self.onTapDismiss?()
    }
}

extension CommentView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell else {
            return UITableViewCell()
        }

        return cell
    }
}

extension CommentView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinnedCommentCollectionViewCell", for: indexPath) as? PinnedCommentCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 85, height: self.pinnedCommentCollectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}
