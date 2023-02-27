//
//  UIViewExtension.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
    
    func blink() {
        UIView.animate(withDuration: 0.9, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse], animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            
        }, completion: nil)
    }
    
    func makeCustomRound(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY
        
        print(self.bounds)

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
    }
    
    func addShadowForView(radius: CGFloat = 2, height: Int = 0 ) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: height)
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    func addDefaultShadowForPopUp() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 12)
        self.layer.shadowRadius = 11
        self.layer.shadowOpacity = 0.2
    }
    
    func addCustomShadow(color: UIColor = .black, opacity: Float = 0.15,
                         radius: CGFloat = 2, offset: CGSize = .zero) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
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
}
