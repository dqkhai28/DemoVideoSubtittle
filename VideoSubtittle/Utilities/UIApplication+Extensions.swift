//
//  UIApplication+Extensions.swift
//  VideoSubtittle
//
//  Created by BM Kane on 07/09/2023.
//

import UIKit

extension UIApplication {
    static func safeAreaLeftInset() -> CGFloat {
        if #available(iOS 15, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return windowScene?.windows.first?.safeAreaInsets.left ?? 0
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0
        }
    }
}
