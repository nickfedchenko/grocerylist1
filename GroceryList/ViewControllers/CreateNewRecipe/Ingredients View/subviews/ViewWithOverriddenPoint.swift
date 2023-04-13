//
//  ViewWithOverriddenPoint.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.04.2023.
//

import UIKit

class ViewWithOverriddenPoint: UIView {
     override func point(inside point: CGPoint,
                         with event: UIEvent?) -> Bool {
         let inside = super.point(inside: point, with: event)
         if !inside {
             for subview in subviews {
                 let pointInSubview = subview.convert(point, from: self)
                 if subview.point(inside: pointInSubview, with: event) {
                     return true
                 }
             }
         }
         return inside
     }
}
