//
//  ColdStartDataSource.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

protocol DataSourceProtocol {
    var imageHeight: ImageHeight { get set }
    var dataSourceArray: [SectionModel] { get set }
    var dataChangedCallBack: (() -> Void)? { get set }
    var setOfModelsToUpdate: Set<GroceryListsModel> { get set }
    @discardableResult func updateListOfModels() -> Set<GroceryListsModel>
    func deleteList(with model: GroceryListsModel) -> Set<GroceryListsModel>
    func addOrDeleteFromFavorite(with model: GroceryListsModel) -> Set<GroceryListsModel>
    var recipesSections: [RecipeSectionsModel] { get set }
    var recipeCount: Int { get }
    func makeRecipesSections()
    func updateFavoritesSection()
}

class MainScreenDataManager: DataSourceProtocol {
    
    var dataChangedCallBack: (() -> Void)?
    var setOfModelsToUpdate: Set<GroceryListsModel> = []
    var recipesSections: [RecipeSectionsModel] = []
    
    var recipeCount: Int { 12 }
    
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
    private let topCellID = UUID()
    
    private var coreDataModels: [DBGroceryListModel] {
        guard let models = CoreDataManager.shared.getAllLists() else { return [] }
        return models
    }
    
    init() {
        modelTransformer = DomainModelsToLocalTransformer()
        createWorkingArray()
        makeRecipesSections()
        addObserver()
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
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(recieptsLoaded),
            name: .recieptsDownladedAnsSaved,
            object: nil
        )
    }
    
    @objc
    private func recieptsLoaded() {
        makeRecipesSections()
    }
    
    private func createWorkingArray() {
        if coldStartState == .initial {
            CoreDataManager.shared.saveList(list: GroceryListsModel(dateOfCreation: Date(), name: "Supermarket".localized, color: 0, isFavorite: true, products: [], typeOfSorting: 0))
            coldStartState = .firstItemAdded
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
        let list = GroceryListsModel(id: topCellID, dateOfCreation: Date(), name: "k",
                                     color: 0, isFavorite: false, products: [], typeOfSorting: 0)
        let topSection = SectionModel(id: 0, cellType: .topMenu, sectionType: .empty, lists: [list])
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

        // сортировка всеъ моделек и раскидывание по секциям
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
      
      
        let sections: [SectionModel] = [topSection, favoriteSection, todaySection, weekSection, monthSection]
        
        // защита от краша при наличии пустой секции
        sections.filter({ $0.lists != [] }).forEach({ finalArray.append($0) })
        
        dataSourceArray = finalArray
    }
    
    func isDateInWeek(date: Date) -> Bool {
        Calendar.current.isDate(Date(), equalTo: date, toGranularity: .weekOfYear)
    }
    
    /// MARK: - Recipes part
    
    func makeRecipesSections() {
        guard let  allRecipes: [DBRecipe] = CoreDataManager.shared.getAllRecipes() else { return }
        let plainRecipes = allRecipes.compactMap { Recipe(from: $0) }
        let breakfastRecipes = plainRecipes.filter { $0.eatingTags.contains(where: { $0.eatingType == .breakfast } )}
        let lunchRecipes = plainRecipes.filter { $0.eatingTags.contains(where: { $0.eatingType == .lunch } )}
        let dinnerRecipes = plainRecipes.filter { $0.eatingTags.contains(where: { $0.eatingType == .dinner } )}
        let snacksRecipes = plainRecipes.filter { $0.eatingTags.contains(where: { $0.eatingType == .snack } )}
        recipesSections = [
            .init(cellType: .topMenuCell, sectionType: .none, recipes: []),
            .init(cellType: .recipePreview, sectionType: .breakfast, recipes: breakfastRecipes.shuffled()),
            .init(cellType: .recipePreview, sectionType: .lunch, recipes: lunchRecipes.shuffled()),
            .init(cellType: .recipePreview, sectionType: .dinner, recipes: dinnerRecipes.shuffled()),
            .init(cellType: .recipePreview, sectionType: .snacks, recipes: snacksRecipes.shuffled())
        ]
        updateFavoritesSection()
    }
    
    func updateFavoritesSection() {
        guard let allRecipes: [DBRecipe] = CoreDataManager.shared.getAllRecipes() else { return }
        let plainRecipes = allRecipes.compactMap { Recipe(from: $0) }
        let favorites = plainRecipes.filter { UserDefaultsManager.favoritesRecipeIds.contains($0.id) }
        let favoritesSection = RecipeSectionsModel(cellType: .recipePreview, sectionType: .favorites, recipes: favorites)
        
        guard let index = recipesSections.firstIndex(where: { $0.sectionType == .favorites }) else {
            if !favorites.isEmpty {
                recipesSections.insert(favoritesSection, at: 1)
            }
            return
        }
        if favorites.isEmpty {
            recipesSections.remove(at: index)
            return
        }
        
        recipesSections[index] = favoritesSection
    }
}

enum ColdStartState: Int {
    case initial
    case firstItemAdded
    case coldStartFinished
}


enum ImageHeight {
    case empty
    case min
    case middle
}
