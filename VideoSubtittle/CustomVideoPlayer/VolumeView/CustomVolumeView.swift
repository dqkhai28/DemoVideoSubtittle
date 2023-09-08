//
//  CustomVolumeView.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import MediaPlayer
import AVKit

final class CustomVolumeView: MPVolumeView {
    let padding: CGFloat = 12.0

    private struct Constant {
        static let icTrack = UIImage(named: "ic-track")
        static let minTrackColor: UIColor = .gray
        static let maxTrackColor: UIColor = .white
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

        } else {
            self.showsRouteButton = false
        }

        self.backgroundColor = .clear
        self.setVolumeThumbImage(Constant.icTrack, for: .normal)
    }

    private func setupSlider() {
        guard let slider = self.subviews.first(where: { $0 is UISlider }) as? UISlider else { return }
        slider.minimumTrackTintColor = Constant.minTrackColor
        slider.maximumTrackTintColor = Constant.maxTrackColor
    }
}
