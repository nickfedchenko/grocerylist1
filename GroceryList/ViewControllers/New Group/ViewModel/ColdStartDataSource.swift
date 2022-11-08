//
//  ColdStartDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

class DataSource {
    
    var dataChangedCallBack: (() -> Void)?
    
    private var coreDataListsArray = CoreDataManager.shared.getAllLists()
    
    var workingSectionsArray: [SectionModel] = [] {
        didSet {
            dataChangedCallBack?()
        }
    }
    
    var listOfModels: [GroseryListsModel]? {
        didSet {
            createWorkingArray()
        }
    }
   
    init() {
       listOfModels = coreDataListsArray?.map({ transformCoreDataModelToModel($0) }) ?? []
        createWorkingArray()
    }
    
    private func transformCoreDataModelToModel(_ model: DBGroceryListModel) -> GroseryListsModel {
        let id = model.id ?? UUID()
        let date = model.dateOfCreation ?? Date()
        let color = model.color ?? "1DD31D"
        return GroseryListsModel(id: id, dateOfCreation: date,
                                 name: model.name, color: color, isFavorite: model.isFavorite, supplays: [])
    }

    func createWorkingArray() {
        var finalArray: [SectionModel] = []
        var favoriteSection = SectionModel(cellType: .usual, sectionType: .favorite, lists: [])
        var todaySection = SectionModel(cellType: .usual, sectionType: .today, lists: [])
        var weekSection = SectionModel(cellType: .usual, sectionType: .week, lists: [])
        var monthSection = SectionModel(cellType: .usual, sectionType: .month, lists: [])
     
        listOfModels?.filter({ $0.isFavorite == true }).forEach({ favoriteSection.lists.append($0) })
       
        listOfModels?.filter({ $0.dateOfCreation > Date() - 86400 && !$0.isFavorite }).forEach({ todaySection.lists.append($0) })
       
        listOfModels?.filter({ $0.dateOfCreation > Date() - 604800 && $0.dateOfCreation < Date() - 86400 && !$0.isFavorite }).forEach({ weekSection.lists.append($0) })
      
        listOfModels?.filter({ $0.dateOfCreation < Date() - 2592000 && $0.dateOfCreation < Date() - 604800 && !$0.isFavorite }).forEach({
            monthSection.lists.append($0) })
        
        let sections = [favoriteSection, todaySection, weekSection, monthSection]
        sections.filter({ $0.lists != [] }).forEach({ finalArray.append($0) })
        
        workingSectionsArray = finalArray
    }
}
