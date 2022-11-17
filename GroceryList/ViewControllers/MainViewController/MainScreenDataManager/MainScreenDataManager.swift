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
    
    private var listOfModels: [GroceryListsModel]? {
        didSet {
            createWorkingArray()
        }
    }
    
    func deleteList(with model: GroceryListsModel) -> Set<GroceryListsModel> {
    setOfModelsToUpdate = []
        if let index = listOfModels?.firstIndex(of: model ) {
            CoreDataManager.shared.removeList(model.id)
            listOfModels?.remove(at: index)
        }
        updateFirstAndLastModels()
        return setOfModelsToUpdate
    }
    
    @discardableResult
    func updateListOfModels() -> Set<GroceryListsModel> {
        setOfModelsToUpdate = []
        updateFirstAndLastModels()
        coreDataListsArray = CoreDataManager.shared.getAllLists()
        listOfModels = coreDataListsArray?.map({ transformCoreDataModelToModel($0) }) ?? []
        updateFirstAndLastModels()
        return setOfModelsToUpdate
    }
    
    func addOrDeleteFromFavorite(with model: GroceryListsModel) -> Set<GroceryListsModel> {
        setOfModelsToUpdate = []
        updateFirstAndLastModels()
        var newModel = model
        newModel.isFavorite = !newModel.isFavorite
        if let index = listOfModels?.firstIndex(of: model ) {
            listOfModels?.remove(at: index)
            listOfModels?.insert(newModel, at: 0)
            CoreDataManager.shared.saveList(list: newModel)
        }
        updateFirstAndLastModels()
        setOfModelsToUpdate.remove(newModel)
        setOfModelsToUpdate.remove(model)
        return setOfModelsToUpdate
    }
    
    func updateFirstAndLastModels() {
        workingSectionsArray.forEach({
            setOfModelsToUpdate.insert($0.lists.first!)
            setOfModelsToUpdate.insert($0.lists.last!)
        })
    }
    
    var setOfModelsToUpdate: Set<GroceryListsModel> = []
    
    private func transformCoreDataModelToModel(_ model: DBGroceryListModel) -> GroceryListsModel {
        let id = model.id ?? UUID()
        let date = model.dateOfCreation ?? Date()
        let color = model.color
        let sortType = Int(model.typeOfSorting)
        let supplays = model.supplays?.allObjects as? [DBSupplay]
        let supp = supplays?.map({ transformCoredataSupplays(supplay: $0)})
        
        return GroceryListsModel(id: id, dateOfCreation: date,
                                 name: model.name, color: Int(color), isFavorite: model.isFavorite, supplays: supp!, typeOfSorting: sortType)
    }
    
    private func transformCoredataSupplays(supplay: DBSupplay?) -> Supplay {
        guard let supplay = supplay else { return Supplay(listId: UUID(), name: "",
                                                          isPurchased: false, dateOfCreation: Date(), category: "")}

        let id = supplay.id ?? UUID()
        let listId = supplay.listId ?? UUID()
        let name = supplay.name ?? ""
        let isPurchased = supplay.isPurchased 
        let dateOfCreation = supplay.dateOfCreation ?? Date()
        let category = supplay.category ?? ""
        
        return Supplay(id: id, listId: listId, name: name, isPurchased: isPurchased, dateOfCreation: dateOfCreation, category: category)
    }

    private func createWorkingArray() {
        var finalArray: [SectionModel] = []
        let list = GroceryListsModel(id: topCellID, dateOfCreation: Date(), name: "k",
                                     color: 0, isFavorite: false, supplays: [], typeOfSorting: 0)
        let topSection = SectionModel(id: 0, cellType: .topMenu, sectionType: .empty, lists: [list])
        var favoriteSection = SectionModel(id: 1, cellType: .usual, sectionType: .favorite, lists: [])
        var todaySection = SectionModel(id: 2, cellType: .usual, sectionType: .today, lists: [])
        var weekSection = SectionModel(id: 3, cellType: .usual, sectionType: .week, lists: [])
        var monthSection = SectionModel(id: 4, cellType: .usual, sectionType: .month, lists: [])
     
        listOfModels?.filter({ $0.isFavorite == true }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ favoriteSection.lists.append($0) })
       
        listOfModels?.filter({ $0.dateOfCreation > Date() - 86400 && !$0.isFavorite }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ todaySection.lists.append($0) })
       
        listOfModels?.filter({ $0.dateOfCreation < Date() - 604800 && $0.dateOfCreation < Date() - 86400 && !$0.isFavorite }).forEach({ weekSection.lists.append($0) })
      
        listOfModels?.filter({ $0.dateOfCreation < Date() - 2592000 && $0.dateOfCreation < Date() - 604800 && !$0.isFavorite }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({
            monthSection.lists.append($0) })
        
        let sections = [favoriteSection, todaySection, weekSection, monthSection]
        finalArray.append(topSection)
        sections.filter({ $0.lists != [] }).forEach({ finalArray.append($0) })
        
        workingSectionsArray = finalArray
    }
}
