//
//  TextViewWithPlaceholder.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.07.2023.
//

import UIKit

final class TextViewWithPlaceholder: UITextView {
    
    func setPlaceholder(placeholder: String,
                        textColor: UIColor? = .black.withAlphaComponent(0.3),
                        font: UIFont = UIFont.SFPro.medium(size: 15).font,
                        frame: CGPoint? = nil) {
        guard (self.viewWithTag(222) as? UILabel) == nil else {
            return
        }
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = font
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = frame ?? CGPoint(x: 5, y: (self.font?.pointSize ?? 10) / 2)
        placeholderLabel.textColor = textColor
        placeholderLabel.isHidden = !self.text.isEmpty

        self.addSubview(placeholderLabel)
    }

    func checkPlaceholder() {
        guard let placeholderLabel = self.viewWithTag(222) as? UILabel else {
            return
        }
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}
