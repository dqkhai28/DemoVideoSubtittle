//
//  BaseViewController.swift
//  VideoSubtittle
//
//  Created by BM Kane on 07/09/2023.
//

import UIKit

class BaseViewController: UIViewController {
    var windowInterfaceOrientation: UIInterfaceOrientation? {
        if #available(iOS 15, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return windowScene?.interfaceOrientation
        } else {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        }
    }
}
