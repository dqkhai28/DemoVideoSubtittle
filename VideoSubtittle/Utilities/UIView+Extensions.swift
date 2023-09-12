//
//  UIView+Extensions.swift
//  VideoSubtittle
//
//  Created by Kane on 05/09/2023.
//

import Foundation
import UIKit

extension UIView {
    @discardableResult
    func loadFromNib<T: UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else { return nil }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        return contentView
    }
    
    func getViewsByType<T: UIView>(type _: T.Type) -> [T] {
        return getAllSubViews().compactMap { $0 as? T }
    }
    
    private func getAllSubViews() -> [UIView] {
        var subviews = self.subviews
        if subviews.isEmpty {
            return subviews
        }
        for view in subviews {
            subviews += view.getAllSubViews()
        }
        return subviews
    }
}

extension UIView {
    
    @IBInspectable
    public var cornerRadiusView: CGFloat
    {
        set (radius) {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = radius > 0
        }
        
        get {
            return self.layer.cornerRadius
        }
    }
    
    @IBInspectable
    public var borderWidthView: CGFloat
    {
        set (borderWidth) {
            self.layer.borderWidth = borderWidth
        }
        
        get {
            return self.layer.borderWidth
        }
    }
    
    @IBInspectable
    public var borderColorView:UIColor?
    {
        set (color) {
            self.layer.borderColor = color?.cgColor
        }
        
        get {
            if let color = self.layer.borderColor
            {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadiusView: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.masksToBounds = false
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacityView: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.masksToBounds = false
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffsetView: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.masksToBounds = false
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColorView: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func makeRoundedWith(borderColor: UIColor, borderWidth: CGFloat) {
        makeBorder(borderColor: borderColor, borderWidth: borderWidth, radius: self.frame.height / 2)
    }
    
    func makeBorder(borderColor: UIColor, borderWidth: CGFloat, radius: CGFloat) {
        DispatchQueue.main.async {
            self.layer.borderWidth = borderWidth
            self.layer.masksToBounds = false
            self.layer.borderColor = borderColor.cgColor
            self.layer.cornerRadius = radius
            self.clipsToBounds = true
        }
    }
    
    func getSubViewsOf<T : UIView>(type : T.Type) -> T? {
        func getSubview(view: UIView) -> T? {
            if let aView = view as? T {
                return aView
            }
            guard !view.subviews.isEmpty else { return nil }
            for v in view.subviews {
                if let tView = getSubview(view: v) {
                    return tView
                }
            }
            return nil
        }
        return getSubview(view: self)
    }
    
    func fade(duration: TimeInterval = 1.0, toAlpha: CGFloat) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = toAlpha
        })
    }
}
