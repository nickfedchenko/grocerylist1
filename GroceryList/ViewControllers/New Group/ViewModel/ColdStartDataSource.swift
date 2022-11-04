//
//  ColdStartDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

class ColdStartDataSource {
    
    lazy var sectionsModel = [
        SectionModel(cellType: .usual, sectionType: .favorite, lists: favoriteModel),
        SectionModel(cellType: .instruction, sectionType: .today, lists: todayModel),
        SectionModel(cellType: .empty, sectionType: .week, lists: sevenDaysModel),
        SectionModel(cellType: .empty, sectionType: .month, lists: oneMonthModel)
    ]
   
    let favoriteModel = [
        GroseryListsModel(dateOfCreation: Date(), name: "SuperMarket".localized,
                          color: ColorManager.shared.getGradient(index: 1).0, isFavorite: true, supplays: [])
    ]
    
    let todayModel = [
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .red, isTestCell: true, supplays: [] )
    ]
    
    let sevenDaysModel = [
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 0), isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 1), isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 2), isEmpty: true, supplays: [] )
    ]
    
    let oneMonthModel = [
        GroseryListsModel(dateOfCreation: nil, name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 0), isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 1), isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 2), isEmpty: true, supplays: [] )
   
    ]
}
