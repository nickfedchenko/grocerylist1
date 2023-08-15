//
//  PaywallModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 02.12.2022.
//

import UIKit

struct PayWallModel {
    var isPopular: Bool = false
    var isVisibleSave: Bool = false
    var isFamily: Bool = false
    var badgeColor: UIColor?
    var savePrecent: Int = 0
    var period: String = "Loading".localized
    var price: String = "Loading".localized
    var description: String = "Loading".localized
}
