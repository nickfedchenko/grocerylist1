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
    var recipeUpdate: (() -> Void)? { get set }
    var setOfModelsToUpdate: Set<GroceryListsModel> { get set }
    @discardableResult func updateListOfModels() -> Set<GroceryListsModel>
    func deleteList(with model: GroceryListsModel) -> Set<GroceryListsModel>
    func addOrDeleteFromFavorite(with model: GroceryListsModel) -> Set<GroceryListsModel>
    var recipesSections: [RecipeSectionsModel] { get set }
    var recipeCount: Int { get }
    func makeRecipesSections()
    func updateFavoritesSection()
    func updateCustomSection()
}

class MainScreenDataManager: DataSourceProtocol {
    
    var dataChangedCallBack: (() -> Void)?
    var recipeUpdate: (() -> Void)?
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
        
        // заполнение дефолтных секций
        if !UserDefaultsManager.isFillingDefaultCollection {
            let breakfast = CollectionModel(id: AdditionalTag.EatingTime.breakfast.rawValue,
                                            index: 0,
                                            title: RecipeSectionsModel.RecipeSectionType.breakfast.title,
                                            isDefault: true)
            let lunch = CollectionModel(id: AdditionalTag.EatingTime.lunch.rawValue,
                                        index: 1,
                                        title: RecipeSectionsModel.RecipeSectionType.lunch.title,
                                        isDefault: true)
            let dinner = CollectionModel(id: AdditionalTag.EatingTime.dinner.rawValue,
                                         index: 2,
                                         title: RecipeSectionsModel.RecipeSectionType.dinner.title,
                                         isDefault: true)
            let snack = CollectionModel(id: AdditionalTag.EatingTime.snack.rawValue,
                                        index: 3,
                                        title: RecipeSectionsModel.RecipeSectionType.snacks.title,
                                        isDefault: true)
            let miscellaneous = CollectionModel(id: UUID().integer, index: 4,
                                                title: R.string.localizable.miscellaneous(),
                                                isDefault: false)
            UserDefaultsManager.miscellaneousCollectionId = miscellaneous.id
            CoreDataManager.shared.saveCollection(collections: [breakfast, lunch, dinner, snack, miscellaneous])
            UserDefaultsManager.isFillingDefaultCollection = true
        }

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
        DispatchQueue.main.async { [weak self] in
            self?.makeRecipesSections()
            self?.recipeUpdate?()
        }
      
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
        recipesSections = [.init(cellType: .topMenuCell, sectionType: .none, recipes: [])]
        updateFavoritesSection()
        updateCustomSection()
    }
    
    func updateFavoritesSection() {
        guard let allRecipes: [DBRecipe] = CoreDataManager.shared.getAllRecipes() else { return }
        let domainFavorites = allRecipes.filter { UserDefaultsManager.favoritesRecipeIds.contains(Int($0.id)) }
        let favorites = domainFavorites.compactMap { ShortRecipeModel(withCollection: $0) }
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
    
    func updateCustomSection() {
        guard let allCollection = CoreDataManager.shared.getAllCollection(),
              let allRecipes = CoreDataManager.shared.getAllRecipes() else { return }
        
        let customCollection = allCollection.compactMap { CollectionModel(from: $0) }
        let plainRecipes = allRecipes.compactMap { ShortRecipeModel(withCollection: $0) }
        
        customCollection.forEach { collection in
            let recipes = plainRecipes.filter {
                $0.localCollection?.contains(where: { collection.id == $0.id }) ?? false
            }
            let customSection = RecipeSectionsModel(cellType: .recipePreview,
                                                    sectionType: .custom(collection.title),
                                                    recipes: recipes.shuffled())

            guard let index = recipesSections.firstIndex(where: { $0.sectionType == .custom(collection.title) }) else {
                recipesSections.append(customSection)
                return
            }
            recipesSections[index] = customSection
        }
        
        updateMiscellaneousSection()
    }
    
    func updateMiscellaneousSection() {
        guard let miscellaneousIndex = recipesSections.firstIndex(where: {
            $0.sectionType == .custom(R.string.localizable.miscellaneous())
        }) else {
            return
        }
        
        if recipesSections[miscellaneousIndex].recipes.isEmpty {
            recipesSections.remove(at: miscellaneousIndex)
        }
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
