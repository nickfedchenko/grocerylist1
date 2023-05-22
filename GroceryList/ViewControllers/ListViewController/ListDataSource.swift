//
//  ListDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import Foundation

protocol ListDataSourceProtocol {
    var imageHeight: ImageHeight { get set }
    var dataSourceArray: [SectionModel] { get set }
    var dataChangedCallBack: (() -> Void)? { get set }
    var recipeUpdate: (() -> Void)? { get set }
    var setOfModelsToUpdate: Set<GroceryListsModel> { get set }
    @discardableResult func updateListOfModels() -> Set<GroceryListsModel>
    func deleteList(with model: GroceryListsModel) -> Set<GroceryListsModel>
    func addOrDeleteFromFavorite(with model: GroceryListsModel) -> Set<GroceryListsModel>
}

final class ListDataSource: ListDataSourceProtocol {
    
    var dataChangedCallBack: (() -> Void)?
    var recipeUpdate: (() -> Void)?
    var setOfModelsToUpdate: Set<GroceryListsModel> = []

    var imageHeight: ImageHeight = .empty {
        didSet {
          print("image height is \(imageHeight)")
        }
    }
    
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
    
    var transformedModels: [GroceryListsModel]? {
        didSet {
            createWorkingArray()
        }
    }
    
    private var modelTransformer: DomainModelsToLocalTransformer
    
    private var coreDataModels: [DBGroceryListModel] {
        guard let models = CoreDataManager.shared.getAllLists() else { return [] }
        return models
    }
    
    init() {
        modelTransformer = DomainModelsToLocalTransformer()
        createWorkingArray()
    }
    
    func deleteList(with model: GroceryListsModel) -> Set<GroceryListsModel> {
        if coldStartState == .firstItemAdded { coldStartState = .coldStartFinished }
        if let index = transformedModels?.firstIndex(of: model ) {
            CoreDataManager.shared.removeList(model.id)
            transformedModels?.remove(at: index)
        }
        updateFirstAndLastModels()
        return setOfModelsToUpdate
    }
    
    @discardableResult
    func updateListOfModels() -> Set<GroceryListsModel> {
        updateFirstAndLastModels()
        transformedModels = coreDataModels.map({ modelTransformer.transformCoreDataModelToModel($0) })
        updateFirstAndLastModels()
        return setOfModelsToUpdate
    }
    
    func addOrDeleteFromFavorite(with model: GroceryListsModel) -> Set<GroceryListsModel> {
        if coldStartState == .firstItemAdded { coldStartState = .coldStartFinished }
        updateFirstAndLastModels()
        var newModel = model
        newModel.isFavorite = !newModel.isFavorite
        if let index = transformedModels?.firstIndex(of: model ) {
            transformedModels?.remove(at: index)
            transformedModels?.insert(newModel, at: 0)
            CoreDataManager.shared.saveList(list: newModel)
        }
        updateFirstAndLastModels()
        return setOfModelsToUpdate
    }
    
    func updateFirstAndLastModels() {
        dataSourceArray.forEach({
            guard let firstElement = $0.lists.first else { return }
            setOfModelsToUpdate.insert(firstElement)
            
            guard let lastElement = $0.lists.last else { return }
            setOfModelsToUpdate.insert(lastElement)
        })
    }

    private func createWorkingArray() {
        if coldStartState == .initial && !UserDefaultsManager.shouldShowOnboarding {
            let isAutomaticCategory = FeatureManager.shared.isActiveAutoCategory ?? true
            CoreDataManager.shared.saveList(list: GroceryListsModel(dateOfCreation: Date(), name: "Supermarket".localized, color: 0, isFavorite: true, products: [], isAutomaticCategory: isAutomaticCategory, typeOfSorting: 0))
            coldStartState = .firstItemAdded
            transformedModels = coreDataModels.map({ modelTransformer.transformCoreDataModelToModel($0) })
        }
        createDataSourceArray()
    }
    
    func createDataSourceArray() {
        
        // ячейки для холодного старта
        let instruction = GroceryListsModel(dateOfCreation: Date(), color: 0, products: [], typeOfSorting: 0)
        let todayFirst = GroceryListsModel(dateOfCreation: Date(), color: 2, products: [], typeOfSorting: 0)
        let weekFirst = GroceryListsModel(dateOfCreation: Date(), color: 0, products: [], typeOfSorting: 0)
        let weekSecond = GroceryListsModel(dateOfCreation: Date(), color: 1, products: [], typeOfSorting: 0)
        let monthFirst = GroceryListsModel(dateOfCreation: Date(), color: 0, products: [], typeOfSorting: 0)
        let monthSecond = GroceryListsModel(dateOfCreation: Date(), color: 1, products: [], typeOfSorting: 0)
        let monthThird = GroceryListsModel(dateOfCreation: Date(), color: 2, products: [], typeOfSorting: 0)
        
        
        // секции - у нас их ограниченое количество
        var finalArray: [SectionModel] = []
        var favoriteSection = SectionModel(id: 1, cellType: .usual, sectionType: .favorite, lists: [])
        var todaySection = SectionModel(id: 2, cellType: .usual, sectionType: .today, lists: [])
        var weekSection = SectionModel(id: 3, cellType: .usual, sectionType: .week, lists: [])
        var monthSection = SectionModel(id: 4, cellType: .usual, sectionType: .month, lists: [])
        
        // поведение при холодном старте
        if  coldStartState == .firstItemAdded {
            todaySection = SectionModel(id: 2, cellType: .instruction, sectionType: .today, lists: [instruction])
        }
        
        if coldStartState == .coldStartFinished {
            todaySection = SectionModel(id: 2, cellType: .usual, sectionType: .today, lists: [])
        }

        // сортировка всех моделек и раскидывание по секциям
        transformedModels?.filter({ $0.isFavorite == true }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ favoriteSection.lists.append($0) })

        transformedModels?.filter({ Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ todaySection.lists.append($0) })
       
        transformedModels?.filter({ isDateInWeek(date: $0.dateOfCreation) && !Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).sorted(by: { $0.dateOfCreation > $1.dateOfCreation }).forEach({ weekSection.lists.append($0) })
      
        transformedModels?.filter({ !isDateInWeek(date: $0.dateOfCreation) && !Calendar.current.isDateInToday($0.dateOfCreation) && !$0.isFavorite }).forEach({ monthSection.lists.append($0) })
        
       
        // проверка на пустые секции - если такие есть то автоматом заполняются шаблонными ячейками
        let emptyTodaySection = SectionModel(id: 2, cellType: .empty, sectionType: .today, lists: [todayFirst])
        let emptyWeekSection = SectionModel(id: 3, cellType: .empty, sectionType: .week, lists: [weekFirst, weekSecond])
        let emptyMonthSection = SectionModel(id: 4, cellType: .empty, sectionType: .month, lists: [monthFirst, monthSecond, monthThird])
    
        if !monthSection.lists.isEmpty { imageHeight = .empty }
        if !weekSection.lists.isEmpty  && monthSection.lists.isEmpty { imageHeight = .min }
        if weekSection.lists.isEmpty  && monthSection.lists.isEmpty { imageHeight = .middle }
        
        
        // если нижестоящая секция не пустая - то в секции ниже не добавляются пустые шаблоны
        if todaySection.lists.isEmpty && weekSection.lists.isEmpty && monthSection.lists.isEmpty { todaySection = emptyTodaySection }
        if weekSection.lists.isEmpty && monthSection.lists.isEmpty { weekSection = emptyWeekSection }
        if monthSection.lists.isEmpty { monthSection = emptyMonthSection }
      
      
        let sections: [SectionModel] = [favoriteSection, todaySection, weekSection, monthSection]
        
        // защита от краша при наличии пустой секции
        sections.filter({ $0.lists != [] }).forEach({ finalArray.append($0) })
        
        dataSourceArray = finalArray
    }
    
    func isDateInWeek(date: Date) -> Bool {
        Calendar.current.isDate(Date(), equalTo: date, toGranularity: .weekOfYear)
    }
}
