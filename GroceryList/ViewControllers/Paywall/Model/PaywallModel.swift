//
//  PaywallModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 02.12.2022.
//

import UIKit

struct PayWallModel {
    var isPopular: Bool
    var period: String
    var price: String
    var description: String
}

struct PayWallModelWithSave {
    var isVisibleBadge: Bool = false
    var badgeColor: UIColor?
    var savePrecent: Int = 0
    var period: String = "Loading".localized
    var price: String = "Loading".localized
    var description: String = "Loading".localized
}
