//
//  IntrinsicTableView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import UIKit

class IntrinsicCollectionView: UICollectionView {
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
