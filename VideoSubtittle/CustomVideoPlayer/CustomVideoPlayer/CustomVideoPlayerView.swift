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
        self.player?.replaceCurrentItem(with: playerItem)
        
        do {
            try self.open(fileFromLocal: subtitleURL, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }
        
        self.controlView.playVideo()
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
        self.player = AVPlayer()
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer.frame = videoView.bounds
        self.playerLayer.videoGravity = .resizeAspect
        self.videoView.layer.addSublayer(playerLayer)
        self.addSubtitles()
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

// MARK: - Add and display subtitles
extension CustomVideoPlayerView {
    
    private struct AssociatedKeys {
        static var FontKey = "FontKey"
        static var ColorKey = "FontKey"
        static var SubtitleKey = "SubtitleKey"
        static var SubtitleHeightKey = "SubtitleHeightKey"
        static var PayloadKey = "PayloadKey"
    }
    
    // MARK: - Public properties
    
    var subtitleLabel: UILabel? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleKey) as? UILabel }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Private properties
    
    fileprivate var subtitleLabelHeightConstraint: NSLayoutConstraint? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey) as? NSLayoutConstraint }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    fileprivate var parsedPayload: NSDictionary? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.PayloadKey) as? NSDictionary }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.PayloadKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Public methods
    
    func addSubtitles() {
        // Create label
        addSubtitleLabel()
    }
    
    func open(fileFromLocal filePath: URL, encoding: String.Encoding = .utf8) throws {
        let contents = try String(contentsOf: filePath, encoding: encoding)
        show(subtitles: contents)
    }
    
    func open(fileFromRemote filePath: URL, encoding: String.Encoding = .utf8) {
        subtitleLabel?.text = "..."
        let dataTask = URLSession.shared.dataTask(with: filePath) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                //Check status code
                if statusCode != 200 {
                    NSLog("Subtitle Error: \(httpResponse.statusCode) - \(error?.localizedDescription ?? "")")
                    return
                }
            }
            
            // Update UI elements on main thread
            DispatchQueue.main.async {
                self.subtitleLabel?.text = ""
                if let checkData = data as Data?, let contents = String(data: checkData, encoding: encoding) {
                    self.show(subtitles: contents)
                }
            }
        }
        dataTask.resume()
    }
    
    func show(subtitles string: String) {
        // Parse
        parsedPayload = try? Subtitles.parseSubRip(string)
        if let parsedPayload = parsedPayload {
            addPeriodicNotification(parsedPayload: parsedPayload)
        }
    }
    
    func showByDictionary(dictionaryContent: NSMutableDictionary) {
        // Add Dictionary content direct to Payload
        parsedPayload = dictionaryContent
        if let parsedPayload = parsedPayload {
            addPeriodicNotification(parsedPayload: parsedPayload)
        }
    }
    
    func addPeriodicNotification(parsedPayload: NSDictionary) {
        // Add periodic notifications
        let interval = CMTimeMake(value: 1, timescale: 60)
        self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let strongSelf = self, let label = strongSelf.subtitleLabel else {
                return
            }
            
            // Search && show subtitles
            label.text = Subtitles.searchSubtitles(strongSelf.parsedPayload, time.seconds)
            
            // Adjust size
            let baseSize = CGSize(width: label.bounds.width, height: .greatestFiniteMagnitude)
            let rect = label.sizeThatFits(baseSize)
            if label.text != nil {
                strongSelf.subtitleLabelHeightConstraint?.constant = rect.height + 5.0
            } else {
                strongSelf.subtitleLabelHeightConstraint?.constant = rect.height
            }
        }
    }
    
    fileprivate func addSubtitleLabel() {
        guard subtitleLabel == nil else {
            return
        }
        
        // Label
        subtitleLabel = UILabel()
        subtitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel?.backgroundColor = UIColor.clear
        subtitleLabel?.textAlignment = .center
        subtitleLabel?.numberOfLines = 0
        let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 40.0 : 22.0
        subtitleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        subtitleLabel?.textColor = .white
        subtitleLabel?.layer.shadowColor = UIColor.black.cgColor
        subtitleLabel?.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        subtitleLabel?.layer.shadowOpacity = 0.9
        subtitleLabel?.layer.shadowRadius = 1.0
        subtitleLabel?.layer.shouldRasterize = true
        subtitleLabel?.layer.rasterizationScale = UIScreen.main.scale
        subtitleLabel?.lineBreakMode = .byWordWrapping
        
        videoView?.addSubview(subtitleLabel!)
        
        // Position
        subtitleLabel?.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(-10)
        }
    }
}
