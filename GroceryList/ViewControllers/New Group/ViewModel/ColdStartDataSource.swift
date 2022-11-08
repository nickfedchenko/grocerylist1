//
//  ColdStartDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

class DataSource {
    
    init() {
        createWorkingArray()
   
    }
    
    static var shared = DataSource()
    var dataChangedCallBack: (() -> Void)?
    var workingSectionsArray: [SectionModel] = [] {
        didSet {
            dataChangedCallBack?()
        }
    }

    var coreDataSet: Set<GroseryListsModel> = [] {
        didSet {
            createWorkingArray()
        }
    }
    
    func createWorkingArray() {
        var favoriteSection = SectionModel(cellType: .usual, sectionType: .favorite, lists: [])
        var todaySection = SectionModel(cellType: .usual, sectionType: .today, lists: [])
        var weekSection = SectionModel(cellType: .usual, sectionType: .week, lists: [])
        var monthSection = SectionModel(cellType: .usual, sectionType: .month, lists: [])
        var emptySection = SectionModel(cellType: .usual, sectionType: .month, lists: oneMonthModel)
     
        coreDataSet.forEach({ if $0.isFavorite { favoriteSection.lists.append($0)} })
        coreDataSet.filter({ $0.dateOfCreation < Date() - 86400 }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ todaySection.lists.append($0) })
        coreDataSet.filter({ $0.dateOfCreation < Date() - 604800 }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ weekSection.lists.append($0) })
        coreDataSet.filter({ $0.dateOfCreation < Date() - 2592000 }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ monthSection.lists.append($0) })
        
        let sections = [favoriteSection, todaySection, weekSection, monthSection, emptySection]
        sections.forEach({ if !$0.lists.isEmpty { workingSectionsArray.append($0)} })
       
        workingSectionsArray = sections
    }
    
    func createEmptyList() -> GroseryListsModel {
        GroseryListsModel(dateOfCreation: Date(), color: ColorManager.shared.getEmptyCellColor(index: 0), supplays: [])
    }
    
    let oneMonthModel = [
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 0), supplays: [] ),
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 1), supplays: [] ),
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 2), supplays: [] )
   
    ]
    
}

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
        GroseryListsModel(dateOfCreation: Date(), name: nil, color: .red, supplays: [] )
    ]
    
    let sevenDaysModel = [
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 0), supplays: [] ),
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 1), supplays: [] ),
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 2), supplays: [] )
    ]
    
    let oneMonthModel = [
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 0), supplays: [] ),
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 1), supplays: [] ),
        GroseryListsModel(dateOfCreation: Date(), name: nil,
                          color: ColorManager.shared.getEmptyCellColor(index: 2), supplays: [] )
   
    ]
}
