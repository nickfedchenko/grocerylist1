//
//  CustomSegmentControl.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import UIKit

class CustomSegmentedControl: UISegmentedControl {
    private let segmentInset: CGFloat = 5
    private let segmentImage: UIImage? = UIImage(color: .white)

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.5
        let foregroundIndex = numberOfSegments
        if subviews.indices.contains(foregroundIndex), let foregroundImageView = subviews[foregroundIndex] as? UIImageView {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
            foregroundImageView.image = segmentImage
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height / 2.5
        }
    }
}
