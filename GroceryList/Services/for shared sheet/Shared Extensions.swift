//
//  shared extensions.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.08.2023.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
    
    func addDefaultShadowForPopUp() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 12)
        self.layer.shadowRadius = 11
        self.layer.shadowOpacity = 0.2
    }
    
    func addShadow(color: UIColor = .black, opacity: Float = 0.15,
                   radius: CGFloat = 2, offset: CGSize = .zero) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
    }

    func fadeIn(duration: TimeInterval = 0.3,
                delay: TimeInterval = 0.0) {
        self.alpha = 0.0
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.isHidden = false
            self.alpha = 1.0
        })
    }

    func fadeOut(duration: TimeInterval = 0.3,
                 delay: TimeInterval = 0.0, completion: (() -> Void)? = nil) {
        self.alpha = 1.0
        
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut) {
            self.alpha = 0.0
        } completion: { _ in
            self.isHidden = true
            completion?()
        }
    }
    
    func roundCorners(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(
            shouldRoundRect: bounds,
            topLeftRadius: topLeftRadius,
            topRightRadius: topRightRadius,
            bottomLeftRadius: bottomLeftRadius,
            bottomRightRadius: bottomRightRadius
        )
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    func makeCustomRound(topLeft: CGFloat = 0, topRight: CGFloat = 0,
                         bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0, hasBorder: Bool = false) {
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY
        
//        print(self.bounds)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: minX + topLeft, y: minY))
        path.addLine(to: CGPoint(x: maxX - topRight, y: minY))
        path.addArc(withCenter: CGPoint(x: maxX - topRight, y: minY + topRight), radius: topRight, startAngle:CGFloat(3 * Double.pi / 2), endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: maxX, y: maxY - bottomRight))
        path.addArc(withCenter: CGPoint(x: maxX - bottomRight, y: maxY - bottomRight), radius: bottomRight, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
        path.addLine(to: CGPoint(x: minX + bottomLeft, y: maxY))
        path.addArc(withCenter: CGPoint(x: minX + bottomLeft, y: maxY - bottomLeft), radius: bottomLeft, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
        path.addLine(to: CGPoint(x: minX, y: minY + topLeft))
        path.addArc(withCenter: CGPoint(x: minX + topLeft, y: minY + topLeft), radius: topLeft, startAngle: CGFloat(Double.pi), endAngle: CGFloat(3 * Double.pi / 2), clockwise: true)
        path.close()

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        layer.cornerCurve = .continuous

        if hasBorder {
            let borderLayer = CAShapeLayer()
            borderLayer.name = "CustomRoundBorder"
            borderLayer.path = path.cgPath
            borderLayer.lineWidth = 1
            borderLayer.strokeColor = UIColor.white.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(borderLayer)
        } else {
            layer.sublayers?.forEach({
                if $0.name == "CustomRoundBorder" {
                    $0.removeFromSuperlayer()
                }
            })
        }
    }
}

extension Date {
    func toString(format: String = "dd.MM.yyyy HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.string(from: self)
        return date
    }
}
