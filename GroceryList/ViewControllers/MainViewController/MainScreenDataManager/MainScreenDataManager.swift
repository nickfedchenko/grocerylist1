//
//  ColdStartDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

class MainScreenDataManager {
    
    init() {
        if UserDefaultsManager.isColdStartModelAdded {
            createWorkingArray()
            UserDefaultsManager.isColdStartModelAdded = true
        }
    }
    
    private let topCellID = UUID()
    var dataChangedCallBack: (() -> Void)?
    var setOfModelsToUpdate: Set<GroceryListsModel> = []
    private var coreDataModles = CoreDataManager.shared.getAllLists()
    
    var dataSourceArray: [SectionModel] = [] {
        didSet {
            dataChangedCallBack?()
        }
    }
    
    private var transformedModels: [GroceryListsModel]? {
        didSet {
            createWorkingArray()
        }
    }
    
    func deleteList(with model: GroceryListsModel) -> Set<GroceryListsModel> {
    setOfModelsToUpdate = []
        if let index = transformedModels?.firstIndex(of: model ) {
            CoreDataManager.shared.removeList(model.id)
            transformedModels?.remove(at: index)
        }
        updateFirstAndLastModels()
        return setOfModelsToUpdate
    }
    
    @discardableResult
    func updateListOfModels() -> Set<GroceryListsModel> {
        setOfModelsToUpdate = []
        updateFirstAndLastModels()
        coreDataModles = CoreDataManager.shared.getAllLists()
        transformedModels = coreDataModles?.map({ transformCoreDataModelToModel($0) }) ?? []
        updateFirstAndLastModels()
        return setOfModelsToUpdate
    }
    
    func addOrDeleteFromFavorite(with model: GroceryListsModel) -> Set<GroceryListsModel> {
        setOfModelsToUpdate = []
        updateFirstAndLastModels()
        var newModel = model
        newModel.isFavorite = !newModel.isFavorite
        if let index = transformedModels?.firstIndex(of: model ) {
            transformedModels?.remove(at: index)
            transformedModels?.insert(newModel, at: 0)
            CoreDataManager.shared.saveList(list: newModel)
        }
        updateFirstAndLastModels()
        setOfModelsToUpdate.remove(newModel)
        setOfModelsToUpdate.remove(model)
        return setOfModelsToUpdate
    }
    
    func updateFirstAndLastModels() {
        dataSourceArray.forEach({
            setOfModelsToUpdate.insert($0.lists.first!)
            setOfModelsToUpdate.insert($0.lists.last!)
        })
    }
    
    private func transformCoreDataModelToModel(_ model: DBGroceryListModel) -> GroceryListsModel {
        let id = model.id ?? UUID()
        let date = model.dateOfCreation ?? Date()
        let color = model.color
        let sortType = Int(model.typeOfSorting)
        let products = model.products?.allObjects as? [DBProduct]
        let prod = products?.map({ transformCoredataProducts(product: $0)})
        
        return GroceryListsModel(id: id, dateOfCreation: date,
                                 name: model.name, color: Int(color), isFavorite: model.isFavorite, products: prod!, typeOfSorting: sortType)
    }
    
    private func transformCoredataProducts(product: DBProduct?) -> Product {
        guard let product = product else { return Product(listId: UUID(), name: "",
                                                          isPurchased: false, dateOfCreation: Date(), category: "", isFavorite: false)}

        let id = product.id ?? UUID()
        let listId = product.listId ?? UUID()
        let name = product.name ?? ""
        let isPurchased = product.isPurchased
        let dateOfCreation = product.dateOfCreation ?? Date()
        let category = product.category ?? ""
        let isFavorite = product.isFavorite
        
        return Product(id: id, listId: listId, name: name, isPurchased: isPurchased, dateOfCreation: dateOfCreation, category: category, isFavorite: isFavorite)
    }
    
    private func createWorkingArray() {
        if UserDefaultsManager.isColdStartModelAdded {
            saveColdStartInCoreData()
        } else {
            createDefaultArray()
        }
    }

    private func saveColdStartInCoreData() {
//        // секция с избранным
        let supermarket = GroceryListsModel(dateOfCreation: Date(), name: "Supermarket".localized, color: 0, isFavorite: true, products: [], typeOfSorting: 0)
        CoreDataManager.shared.saveList(list: supermarket)
//
//        // в этой секции размещается обучающая ячейка
        let learnCell = GroceryListsModel(dateOfCreation: Date(), name: "Supermarket".localized, color: 0, isFavorite: false, products: [], typeOfSorting: 0)
        CoreDataManager.shared.saveList(list: learnCell)
        
        // тут пустые разноцветные ячейки на неделю
        let weekFirst = GroceryListsModel(dateOfCreation: Date() - 100000, color: 0, products: [], typeOfSorting: 0)
        let weekSecond = GroceryListsModel(dateOfCreation: Date() - 100000, color: 1, products: [], typeOfSorting: 0)
        let weekThird = GroceryListsModel(dateOfCreation: Date() - 100000, color: 2, products: [], typeOfSorting: 0)
        CoreDataManager.shared.saveList(list: weekFirst)
        CoreDataManager.shared.saveList(list: weekSecond)
        CoreDataManager.shared.saveList(list: weekThird)
        
        // тут пустые разноцветные ячейки на месяц
        let monthFirst = GroceryListsModel(dateOfCreation: Date() - 3000000, color: 0, products: [], typeOfSorting: 0)
        let monthSecond = GroceryListsModel(dateOfCreation: Date() - 3000000, color: 1, products: [], typeOfSorting: 0)
        let monthThird = GroceryListsModel(dateOfCreation: Date() - 3000000, color: 2, products: [], typeOfSorting: 0)
        CoreDataManager.shared.saveList(list: monthFirst)
        CoreDataManager.shared.saveList(list: monthSecond)
        CoreDataManager.shared.saveList(list: monthThird)
     
        createDefaultArray()
      //  CoreDataManager.shared.deleteAllEntities()
    }
    
    private func createDefaultArray() {
        var finalArray: [SectionModel] = []
        let list = GroceryListsModel(id: topCellID, dateOfCreation: Date(), name: "k",
                                     color: 0, isFavorite: false, products: [], typeOfSorting: 0)
        let topSection = SectionModel(id: 0, cellType: .topMenu, sectionType: .empty, lists: [list])
        var favoriteSection = SectionModel(id: 1, cellType: .usual, sectionType: .favorite, lists: [])
        var todaySection = SectionModel(id: 2, cellType: .instruction, sectionType: .today, lists: [])
        var weekSection = SectionModel(id: 3, cellType: .empty, sectionType: .week, lists: [])
        var monthSection = SectionModel(id: 4, cellType: .empty, sectionType: .month, lists: [])
     
        transformedModels?.filter({ $0.isFavorite == true }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ favoriteSection.lists.append($0) })

        transformedModels?.filter({ Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ todaySection.lists.append($0) })
       
        transformedModels?.filter({ isDateInWeek(date: $0.dateOfCreation) && !Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ weekSection.lists.append($0) })
      
        transformedModels?.filter({ !isDateInWeek(date: $0.dateOfCreation) && !Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).forEach({ monthSection.lists.append($0) })
        
        let sections = [favoriteSection, todaySection, weekSection, monthSection]
        finalArray.append(topSection)
        sections.filter({ $0.lists != [] }).forEach({ finalArray.append($0) })
        
        dataSourceArray = finalArray
    }
    
    func isDateInWeek(date: Date) -> Bool {
        Calendar.current.isDate(Date(), equalTo: date, toGranularity: .weekOfYear)
    }
    
}
