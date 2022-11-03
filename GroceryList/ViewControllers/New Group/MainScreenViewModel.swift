//
//  MainScreenViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import Foundation
import UIKit

protocol MainScreenViewModelDelegate: AnyObject {
    func getTitleForHeader(at ind: Int) -> String
    func getNumberOfSections() -> Int
    func getNumberOfCells(at section: Int) -> Int
    func getNameOfList(at ind: IndexPath) -> String
    func getBGColor(at ind: Int) -> UIColor
    func isTopRounded(at ind: Int) -> Bool
    func isBottomRounded(at ind: Int) -> Bool
}

class MainScreenViewModel: MainScreenViewModelDelegate {
    
    private let coldStartDataSource = ColdStartDataSource()
    private var isFirstStart = true
    
    private var model: [SectionModel] {
        if isFirstStart { return coldStartDataSource.sectionsModel }
        return coldStartDataSource.sectionsModel
    }
   
    func getNumberOfSections() -> Int {
        return model.count
    }
    
    func getTitleForHeader(at ind: Int) -> String {
        return model[ind].nameOfSection
    }

    func getNumberOfCells(at section: Int) -> Int {
        return model[section].lists.count
    }
    
    func getNameOfList(at ind: IndexPath) -> String {
        return model[ind.section].lists[ind.row].name ?? "No name"
    }
    
    func getBGColor(at ind: Int) -> UIColor {
        return UIColor.blue
    }
    
    func isTopRounded(at ind: Int) -> Bool {
        return true
    }
    
    func isBottomRounded(at ind: Int) -> Bool {
        return false
    }
}

class ColdStartDataSource {
   
    let favoriteModel = [
        GroseryListsModel(dateOfCreation: Date(), name: "SuperMarket".localized, color: .green, isFavorite: true, supplays: [])
    ]
    
    let todayModel = [
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .green, isTestCell: true, supplays: [] )
    ]
    
    let sevenDaysModel = [
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .green, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .green, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .green, isEmpty: true, supplays: [] )
    ]
    
    let oneMonthModel = [
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .green, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .green, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .green, isEmpty: true, supplays: [] )
    ]
    
    lazy var sectionsModel = [
        SectionModel(nameOfSection: "favorite", lists: favoriteModel),
        SectionModel(nameOfSection: "today", lists: todayModel),
        SectionModel(nameOfSection: "sevenDays", lists: sevenDaysModel),
        SectionModel(nameOfSection: "oneMonth", lists: oneMonthModel)
    ]
    
}

struct SectionModel {
    var nameOfSection: String
    var lists: [GroseryListsModel]
}

struct GroseryListsModel {
    var dateOfCreation: Date?
    var name: String?
    var color: UIColor
    var isFavorite: Bool = false
    var isEmpty: Bool = false
    var isTestCell: Bool = false
    var supplays: [Supplay?]
}

struct Supplay {
    var name: String
    var isPurchased: Bool
    var dateOfCreation: Date
    var category: Category
}

enum Category {
    case head
}
