//
//  AVPlayer+Extensions.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import AVKit

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
