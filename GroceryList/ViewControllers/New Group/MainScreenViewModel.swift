//
//  MainScreenViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import Foundation
import UIKit

class MainScreenViewModel {
    
    private let coldStartDataSource = ColdStartDataSource()
    private var isFirstStart = true
    
    var model: [SectionModel] {
        if isFirstStart { return coldStartDataSource.sectionsModel }
        return coldStartDataSource.sectionsModel
    }
   
    func getNumberOfSections() -> Int {
        return model.count
    }
    
    func getTitleForHeader(at ind: Int) -> String {
     "dfdf"
        //  return model[ind].nameOfSection
    }

    func getNumberOfCells(at section: Int) -> Int {
        return model[section].lists.count
    }
    
    func getNameOfList(at ind: IndexPath) -> String {
        return model[ind.section].lists[ind.row].name ?? "No name"
    }
    
    func getBGColor(at ind: IndexPath) -> UIColor {
        return model[ind.section].lists[ind.row].color
    }
    
    func isTopRounded(at ind: IndexPath) -> Bool {
        ind.row == 0
    }
    
    func isBottomRounded(at ind: IndexPath) -> Bool {
        let lastCell = model[ind.section].lists.count - 1
        return ind.row == lastCell
    }
    
    func getnumberOfSupplaysInside(at ind: IndexPath) -> String {
        let supply = model[ind.section].lists[ind.row]
        var done = 0
        supply.supplays.forEach({ item in
            guard let item = item else { return }
            if item.isPurchased {done += 1 }
        })
        
        return "\(done)/\(supply.supplays.count)"
    }
}

class ColdStartDataSource {
   
    let favoriteModel = [
        GroseryListsModel(dateOfCreation: Date(), name: "SuperMarket".localized,
                          color: ColorManager.shared.getGradient(index: 1).0, isFavorite: true, supplays: [])
    ]
    
    let todayModel = [
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .red, isTestCell: true, supplays: [] )
    ]
    
    let sevenDaysModel = [
        GroseryListsModel(dateOfCreation: Date(), name: nil, color: .blue, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: Date(), name: nil, color: .green, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: Date(), name: nil, color: .yellow, isEmpty: true, supplays: [] )
    ]
    
    let oneMonthModel = [
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .gray, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .purple, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .green, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .gray, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .purple, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .green, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .gray, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .purple, isEmpty: true, supplays: [] ),
        GroseryListsModel(dateOfCreation: nil, name: nil, color: .green, isEmpty: true, supplays: [] )
    ]
    
    lazy var sectionsModel = [
        SectionModel(cellType: .usual, sectionType: .favorite, lists: favoriteModel),
        SectionModel(cellType: .instruction, sectionType: .today, lists: oneMonthModel)
//        SectionModel(sectionType: ., lists: sevenDaysModel),
//        SectionModel(sectionType: .usual, lists: oneMonthModel)
    ]
    
}

struct SectionModel: Hashable {
    static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
        lhs.cellType == rhs.cellType && lhs.lists == rhs.lists
    }
    
    var cellType: CellType
    var sectionType: SectionType
    var lists: [GroseryListsModel]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(cellType)
    }
}

struct GroseryListsModel: Hashable {
    static func == (lhs: GroseryListsModel, rhs: GroseryListsModel) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    var id = UUID()
    var dateOfCreation: Date?
    var name: String?
    var color: UIColor
    var isFavorite: Bool = false
    var isEmpty: Bool = false
    var isTestCell: Bool = false
    var supplays: [Supplay?]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dateOfCreation)
    }
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

enum CellType {
    case usual
    case instruction
    case empty
}

enum SectionType: String {
    case favorite
    case today
    case week
    case month
}
