//
//  RateUsModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import Foundation

enum RateUsModel: Hashable {
    case topCell(model: RateUsTopCellModel)
    case bottomCell(model: RateUsBottomCellModel)
}

struct RateUsTopCellModel: Hashable {
    let id = UUID()
}

struct RateUsBottomCellModel: Hashable {
    let id = UUID()
}

enum RateUsSection: Hashable {
    case main
}
