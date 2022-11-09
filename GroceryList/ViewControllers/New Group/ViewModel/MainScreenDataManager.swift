//
//  ColdStartDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

class MainScreenDataManager {
    
    private let topCellID = UUID()
    
    var dataChangedCallBack: (() -> Void)?
    
    private var coreDataListsArray = CoreDataManager.shared.getAllLists()
    
    var workingSectionsArray: [SectionModel] = [] {
        didSet {
            dataChangedCallBack?()
        }
    }
    
    private var listOfModels: [GroseryListsModel]? {
        didSet {
            createWorkingArray()
        }
    }
   
    init() {
       listOfModels = coreDataListsArray?.map({ transformCoreDataModelToModel($0) }) ?? []
        print(listOfModels?.count)
        createWorkingArray()
    }
    
    func deleteList(with model: GroseryListsModel) {
        if let index = listOfModels?.firstIndex(of: model ) {
            listOfModels?.remove(at: index)
            CoreDataManager.shared.removeList(model.id)
        }
    }
    
    func addOrDeleteFromFavorite(with model: GroseryListsModel) {
        print(model.isFavorite)
        var newModel = model
        newModel.isFavorite = !newModel.isFavorite
        print(newModel.isFavorite)
        if let index = listOfModels?.firstIndex(of: model ) {
            listOfModels?.remove(at: index)
            listOfModels?.insert(newModel, at: 0)
            CoreDataManager.shared.saveList(list: newModel)
        }
    }
    
    private func transformCoreDataModelToModel(_ model: DBGroceryListModel) -> GroseryListsModel {
        let id = model.id ?? UUID()
        let date = model.dateOfCreation ?? Date()
        let color = model.color ?? "1DD31D"
        return GroseryListsModel(id: id, dateOfCreation: date,
                                 name: model.name, color: color, isFavorite: model.isFavorite, supplays: [])
    }

    private func createWorkingArray() {
        var finalArray: [SectionModel] = []
        let list = GroseryListsModel(id: topCellID, dateOfCreation: Date(), name: "k", color: "j", isFavorite: false, supplays: [])
        let topSection = SectionModel(id: 0, cellType: .topMenu, sectionType: .empty, lists: [list])
        var favoriteSection = SectionModel(id: 1, cellType: .usual, sectionType: .favorite, lists: [])
        var todaySection = SectionModel(id: 2, cellType: .usual, sectionType: .today, lists: [])
        var weekSection = SectionModel(id: 3, cellType: .usual, sectionType: .week, lists: [])
        var monthSection = SectionModel(id: 4, cellType: .usual, sectionType: .month, lists: [])
     
        listOfModels?.filter({ $0.isFavorite == true }).forEach({ favoriteSection.lists.append($0) })
       
        listOfModels?.filter({ $0.dateOfCreation > Date() - 86400 && !$0.isFavorite }).forEach({ todaySection.lists.append($0) })
       
        listOfModels?.filter({ $0.dateOfCreation < Date() - 604800 && $0.dateOfCreation < Date() - 86400 && !$0.isFavorite }).forEach({ weekSection.lists.append($0) })
      
        listOfModels?.filter({ $0.dateOfCreation < Date() - 2592000 && $0.dateOfCreation < Date() - 604800 && !$0.isFavorite }).forEach({
            monthSection.lists.append($0) })
        
        let sections = [favoriteSection, todaySection, weekSection, monthSection]
        finalArray.append(topSection)
        sections.filter({ $0.lists != [] }).forEach({ finalArray.append($0) })
        
        workingSectionsArray = finalArray
    }
}
