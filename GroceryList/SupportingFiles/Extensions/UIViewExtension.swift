//
//  UIViewExtension.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import UIKit

extension UIView {
    
    func blink() {
        UIView.animate(withDuration: 0.9, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse], animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            
        }, completion: nil)
    }
    
    func addShadowForView(radius: CGFloat = 2, height: Int = 0 ) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: height)
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    func addDefaultShadowForContentView() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: -12)
        self.layer.shadowRadius = 11
        self.layer.shadowOpacity = 0.2
    }
    
    func animateByScaleTransform() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .init(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
    
    func snapshotNewView(scale: CGFloat = 0.0, isOpaque: Bool = true, with backgroundColor: UIColor?) -> UIImage {
        self.backgroundColor = backgroundColor
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            self.backgroundColor = .clear
            return image
        } else {
            self.backgroundColor = .clear
            return UIImage()
        }
    }
}

extension UIScrollView {
    private func screenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(contentSize, false, 0)
        
        contentOffset = .zero
        frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
        
    }
}

extension UIView {
    func applyGradient(colours: [UIColor]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x : 0.0, y : 1.0)
        gradient.endPoint = CGPoint(x :0.0, y: 0.0)
        gradient.locations = [0.9 , 1.0]
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyGradient(_ colors: [UIColor], locations: [NSNumber]?) {
        self.removeGradient()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.locations = locations
        gradient.setProperties(frame: self.bounds,
                               colors: colors.map { $0.cgColor },
                               startPoint: CGPoint(x: 0.5, y: 0.0),
                               endPoint: CGPoint(x: 0.5, y: 1.0))
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func removeGradient(identifier: String? = nil) {
        self.layer.sublayers?.filter { $0 is CAGradientLayer && $0.name == identifier }
            .forEach {
                $0.removeAllAnimations()
                $0.removeFromSuperlayer()
            }
    }
}

extension UIView {
    static var safeAreaBottom: CGFloat {
        if let window = UIApplication.shared.keyWindowInConnectedScenes {
            return window.safeAreaInsets.bottom
        }
         return 0
    }

    static var safeAreaTop: CGFloat {
        if let window = UIApplication.shared.keyWindowInConnectedScenes {
            return window.safeAreaInsets.top
        }
         return 0
    }
}

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }
}

extension CAGradientLayer {
    func setProperties(frame: CGRect, colors: [CGColor], startPoint: CGPoint, endPoint: CGPoint) {
        self.frame = frame
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
}
