//
//  ArrowView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 18.11.2022.
//

import Foundation
import UIKit

class CheckmarkView: UIView {
    
    var path: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        createCheckMark()
    }
    
    func createCheckMark() {
        path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: self.frame.width / 2, y: self.frame.height - 3))
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width / 2, y: self.frame.height - 3))
        path.close()
        
        let color = UIColor.black
        color.setStroke()
        
        path.lineWidth = 3
        path.stroke()
    }
}
