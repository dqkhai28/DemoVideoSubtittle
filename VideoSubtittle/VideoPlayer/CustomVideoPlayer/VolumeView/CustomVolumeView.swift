//
//  CustomVolumeView.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import MediaPlayer
import AVKit

final class CustomVolumeView: MPVolumeView {
    var didTapInsideView: (() -> Void)?
    let padding: CGFloat = 12.0

    private struct Constant {
        static let icTrack = UIImage(named: "ic-track")
        static let minTrackColor: UIColor = .white
        static let maxTrackColor: UIColor = .gray
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func volumeSliderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x,
                      y: bounds.origin.y,
                      width: bounds.width - padding,
                      height: bounds.height)
    }

    private func setupView() {
        if #available(iOS 13.0, *) {
            self.subviews.first(where: { $0 is UIButton })?.isHidden = true
        } else {
            self.showsRouteButton = false
        }

        self.backgroundColor = .clear
        self.setVolumeThumbImage(Constant.icTrack, for: .normal)
        self.setupSlider()
    }

    private func setupSlider() {
        guard let slider = self.subviews.first(where: { $0 is UISlider }) as? UISlider else { return }
        slider.minimumTrackTintColor = Constant.minTrackColor
        slider.maximumTrackTintColor = Constant.maxTrackColor
        slider.addTarget(self, action: #selector(volumeSliderValueChanged(_:event:)), for: .valueChanged)
    }
    
    @objc private func volumeSliderValueChanged(_ sender: UISlider, event: UIEvent) {
        self.didTapInsideView?()
    }
}
