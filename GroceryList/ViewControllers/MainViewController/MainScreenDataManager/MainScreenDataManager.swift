//
//  ColdStartDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

class MainScreenDataManager {
    
    init() {
        createWorkingArray()
    }
    
    private let topCellID = UUID()
    var dataChangedCallBack: (() -> Void)?
    var setOfModelsToUpdate: Set<GroceryListsModel> = []
    private var coreDataModles = CoreDataManager.shared.getAllLists()
    
    // ячейки для холодного старта
    let instruction = GroceryListsModel(dateOfCreation: Date(), color: 0, products: [], typeOfSorting: 0)
    let todayFirst = GroceryListsModel(dateOfCreation: Date(), color: 0, products: [], typeOfSorting: 0)
    let todaySecond = GroceryListsModel(dateOfCreation: Date(), color: 1, products: [], typeOfSorting: 0)
    let todayThird = GroceryListsModel(dateOfCreation: Date(), color: 2, products: [], typeOfSorting: 0)
    let weekFirst = GroceryListsModel(dateOfCreation: Date(), color: 0, products: [], typeOfSorting: 0)
    let weekSecond = GroceryListsModel(dateOfCreation: Date(), color: 1, products: [], typeOfSorting: 0)
    let weekThird = GroceryListsModel(dateOfCreation: Date(), color: 2, products: [], typeOfSorting: 0)
    let monthFirst = GroceryListsModel(dateOfCreation: Date(), color: 0, products: [], typeOfSorting: 0)
    let monthSecond = GroceryListsModel(dateOfCreation: Date(), color: 1, products: [], typeOfSorting: 0)
    let monthThird = GroceryListsModel(dateOfCreation: Date(), color: 2, products: [], typeOfSorting: 0)
    
    lazy var coldStartModels = [instruction, todayFirst, todaySecond, todayThird, weekFirst, weekSecond, weekThird, monthFirst, monthSecond, monthThird]
    
    private var coldStartState: ColdStartState {
        get {
           return ColdStartState(rawValue: UserDefaultsManager.coldStartState) ?? .initial
        }
        
        set {
            UserDefaultsManager.coldStartState = newValue.rawValue
        }
    }
    
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
        if coldStartState == .firstItemAdded { coldStartState = .coldStartFinished }
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
        if coldStartState == .firstItemAdded { coldStartState = .coldStartFinished }
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
        
        // фильтрация пустых ячеек чтобы не словить краш т,к их нет в кор дате
        coldStartModels.forEach({ if setOfModelsToUpdate.contains($0) { setOfModelsToUpdate.remove($0) }})
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
        if coldStartState == .initial {
            CoreDataManager.shared.saveList(list: GroceryListsModel(dateOfCreation: Date(), name: "Supermarket".localized, color: 0, isFavorite: true, products: [], typeOfSorting: 0))
            coldStartState = .firstItemAdded
        }
        createDefaultArray()
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
        
        // поведение при холодном старте
        if  coldStartState == .firstItemAdded {
            todaySection = SectionModel(id: 2, cellType: .instruction, sectionType: .today, lists: [instruction])
        }
        
        if coldStartState == .coldStartFinished {
            todaySection = SectionModel(id: 2, cellType: .usual, sectionType: .today, lists: [])
        }

        // сортировка всеъ моделек и раскидывание по секциям
        transformedModels?.filter({ $0.isFavorite == true }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ favoriteSection.lists.append($0) })

        transformedModels?.filter({ Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ todaySection.lists.append($0) })
       
        transformedModels?.filter({ isDateInWeek(date: $0.dateOfCreation) && !Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ weekSection.lists.append($0) })
      
        transformedModels?.filter({ !isDateInWeek(date: $0.dateOfCreation) && !Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).forEach({ monthSection.lists.append($0) })
        
       
        // проверка на пустые секции - если такие есть то автоматом заполняются шаблонными ячейками
        let emptyTodaySection = SectionModel(id: 2, cellType: .empty, sectionType: .today, lists: [todayFirst, todaySecond, todayThird])
        let emptyWeekSection = SectionModel(id: 3, cellType: .empty, sectionType: .week, lists: [weekFirst, weekSecond, weekThird])
        let emptyMonthSection = SectionModel(id: 4, cellType: .empty, sectionType: .month, lists: [monthFirst, monthSecond, monthThird])
    
        if todaySection.lists.isEmpty { todaySection = emptyTodaySection}
        if weekSection.lists.isEmpty { weekSection = emptyWeekSection }
        if monthSection.lists.isEmpty { monthSection = emptyMonthSection }
        
        let sections = [favoriteSection, todaySection, weekSection, monthSection]
        finalArray.append(topSection)
      
        // защита от краша при наличии пустой секции
        sections.filter({ $0.lists != [] }).forEach({ finalArray.append($0) })
        
        dataSourceArray = finalArray
    }
    
    func isDateInWeek(date: Date) -> Bool {
        Calendar.current.isDate(Date(), equalTo: date, toGranularity: .weekOfYear)
    }
}

enum ColdStartState: Int {
    case initial
    case firstItemAdded
    case coldStartFinished
}
