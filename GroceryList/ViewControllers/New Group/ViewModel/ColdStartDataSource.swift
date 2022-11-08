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
            print(workingSectionsArray)
            dataChangedCallBack?()
        }
    }
    
    var listOfModels: [GroseryListsModel]?
   
    init() {
       listOfModels = coreDataListsArray?.map({ transformCoreDataModelToModel($0) }) ?? []
        createWorkingArray()
    }
    
    private func transformCoreDataModelToModel(_ model: DBGroceryListModel) -> GroseryListsModel {
        let id = model.id ?? UUID()
        let date = model.dateOfCreation ?? Date()
        return GroseryListsModel(id: id, dateOfCreation: date,
                                 name: model.name, color: .lightGray, isFavorite: model.isFavorite, supplays: [])
    }

    func createWorkingArray() {
        var favoriteSection = SectionModel(cellType: .usual, sectionType: .favorite, lists: [])
        var todaySection = SectionModel(cellType: .usual, sectionType: .today, lists: [])
        var weekSection = SectionModel(cellType: .usual, sectionType: .week, lists: [])
        var monthSection = SectionModel(cellType: .usual, sectionType: .month, lists: [])
     
        listOfModels?.forEach({ if $0.isFavorite { favoriteSection.lists.append($0)} })
       
        listOfModels?.filter({ $0.dateOfCreation > Date() - 86400 }).forEach({ todaySection.lists.append($0) })
       
        listOfModels?.filter({ $0.dateOfCreation > Date() - 604800 && $0.dateOfCreation < Date() - 86400 }).forEach({ weekSection.lists.append($0) })
      
        listOfModels?.filter({ $0.dateOfCreation < Date() - 2592000 && $0.dateOfCreation < Date() - 604800 }).forEach({
            monthSection.lists.append($0) })
        
        let sections = [favoriteSection, todaySection, weekSection, monthSection]
        sections.forEach({ if !$0.lists.isEmpty { workingSectionsArray.append($0)} })
       
        workingSectionsArray = sections
    }
}
