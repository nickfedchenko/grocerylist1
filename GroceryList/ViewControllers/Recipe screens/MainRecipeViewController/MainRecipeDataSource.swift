//
//  MainRecipeDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import UIKit

protocol MainRecipeDataSourceProtocol {
    var recipeUpdate: (() -> Void)? { get set }
    var recipesSections: [RecipeSectionsModel] { get set }
    var recipeCount: Int { get }
    func makeRecipesSections()
    func updateSection()
}

class MainRecipeDataSource: MainRecipeDataSourceProtocol {
    
    var recipeUpdate: (() -> Void)?
    var recipesSections: [RecipeSectionsModel] = []
    var recipeCount: Int { 12 }

    init() {
        makeRecipesSections()
        addObserver()
        
        removeDefaultsCollection()
        createTechnicalCollection()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(recipesLoaded),
                                               name: .recipesDownloadedAndSaved, object: nil)
    }
    
    @objc
    private func recipesLoaded() {
        DispatchQueue.main.async { [weak self] in
            self?.makeRecipesSections()
            self?.recipeUpdate?()
        }
    }
    
    func makeRecipesSections() {
        recipesSections = []
        
        updateSection()
    }
    
    func updateSection() {
        guard var allDBCollection = CoreDataManager.shared.getAllCollection(),
              let allDBRecipes = CoreDataManager.shared.getAllRecipes() else {
            return
        }
        
        let favoritesID = UserDefaultsManager.shared.favoritesRecipeIds
        allDBCollection.removeAll { $0.isDelete == true }
        var collections = allDBCollection.compactMap { CollectionModel(from: $0) }
        var recipes = allDBRecipes.compactMap {
            let isFavorite = favoritesID.contains(Int($0.id))
            return ShortRecipeModel(withCollection: $0, isFavorite: isFavorite)
        }

        collections.removeAll { collection in
            if collection.isDefault {
                let isTechnicalCollection = EatingTime.getTechnicalCollection.contains { $0.rawValue == collection.id }
                return isTechnicalCollection ? false : collection.dishes?.count ?? 0 < 10
            } else {
                return false
            }
        }
        
        collections.forEach { collection in
            var collectionRecipes: [ShortRecipeModel]
            
            if collection.id == EatingTime.favorites.rawValue {
                collectionRecipes = favoritesID.compactMap { recipeId in
                    recipes.first { $0.id == recipeId }
                }
            } else {
                collectionRecipes = collection.dishes?.compactMap { recipeId in
                    recipes.first { $0.id == recipeId }
                } ?? []
            }
            collectionRecipes.sort { $0.createdAt > $1.createdAt }
            let image = getFirstPhoto(recipes: collectionRecipes)
            let customSection = RecipeSectionsModel(collectionId: collection.id,
                                                    cellType: .recipePreview,
                                                    sectionType: .custom(collection.title.localized),
                                                    recipes: collectionRecipes,
                                                    color: collection.color ?? 0,
                                                    imageUrl: image.url,
                                                    localImage: collection.localImage ?? image.data)
            guard let index = recipesSections.firstIndex(where: {
                $0.sectionType == .custom(collection.title.localized)
            }) else {
                recipesSections.append(customSection)
                return
            }
            recipesSections[index] = customSection
        }
        
        visibleTechnicalCollection()
    }
    
    private func getFirstPhoto(recipes: [ShortRecipeModel]) -> (url: String?, data: Data?) {
        for recipe in recipes {
            if let imageData = recipe.localImage {
                return (nil, imageData)
            } else if let url = URL(string: recipe.photo) {
                return (recipe.photo, nil)
            }
        }
        return (nil, R.image.defaultRecipeImage()?.pngData())
    }
    
    private func visibleTechnicalCollection() {
        EatingTime.getTechnicalCollection.forEach { collection in
            guard let technicalCollectionIndex = recipesSections.firstIndex(where: {
                $0.collectionId == collection.rawValue
            }) else {
                return
            }
            
            if recipesSections[technicalCollectionIndex].recipes.isEmpty {
                recipesSections.remove(at: technicalCollectionIndex)
            }
        }
    }
    
    private func removeDefaultsCollection() {
        EatingTime.defaults.forEach {
            CoreDataManager.shared.deleteCollection(by: $0.rawValue)
        }
    }
    
    private func createDefaultsCollection() {
        if !UserDefaultsManager.shared.isFillingDefaultCollection {
            let breakfast = CollectionModel(
                id: EatingTime.breakfast.rawValue,
                index: 0,
                title: RecipeSectionsModel.RecipeSectionType.breakfast.title,
                color: EatingTime.breakfast.color,
                isDefault: true)
            let lunch = CollectionModel(
                id: EatingTime.lunch.rawValue,
                index: 1,
                title: RecipeSectionsModel.RecipeSectionType.lunch.title,
                color: EatingTime.lunch.color,
                isDefault: true)
            let dinner = CollectionModel(
                id: EatingTime.dinner.rawValue,
                index: 2,
                title: RecipeSectionsModel.RecipeSectionType.dinner.title,
                color: EatingTime.dinner.color,
                isDefault: true)
            let snack = CollectionModel(
                id: EatingTime.snack.rawValue,
                index: 3,
                title: RecipeSectionsModel.RecipeSectionType.snacks.title,
                color: EatingTime.snack.color,
                isDefault: true)

            CoreDataManager.shared.saveCollection(collections: [breakfast, lunch, dinner, snack])
            
            createTechnicalCollection()
            
            UserDefaultsManager.shared.isFillingDefaultCollection = true
        }
    }
    
    private func updateOldCollectionIfNeeded() {
        let collections = CoreDataManager.shared.getAllCollection() ?? []
        guard UserDefaultsManager.shared.isFillingDefaultCollection && !collections.isEmpty else {
            return
        }
        
        guard !UserDefaultsManager.shared.isFillingDefaultTechnicalCollection else {
            return
        }
        
        CoreDataManager.shared.deleteCollection(by: UserDefaultsManager.shared.miscellaneousCollectionId)
        
        collections.forEach({ dbCollection in
            EatingTime.allCases.forEach { defaultCollection in
                if dbCollection.id == defaultCollection.rawValue {
                    var collection = CollectionModel(from: dbCollection)
                    collection.color = defaultCollection.color
                    collection.title = RecipeSectionsModel.RecipeSectionType.getCorrectTitle(id: defaultCollection.rawValue)
                    CoreDataManager.shared.saveCollection(collections: [collection])
                }
            }
        })
        
        createTechnicalCollection()
        updateFavoritesCollection()
    }
    
    private func createTechnicalCollection() {
        if !UserDefaultsManager.shared.isFillingDefaultCollection {
            let iWillCookIt = CollectionModel(
                id: EatingTime.willCook.rawValue,
                index: EatingTime.willCook.rawValue,
                title: RecipeSectionsModel.RecipeSectionType.willCook.title,
                color: EatingTime.willCook.color,
                isDefault: true)
            let drafts = CollectionModel(
                id: EatingTime.drafts.rawValue,
                index: EatingTime.drafts.rawValue,
                title: RecipeSectionsModel.RecipeSectionType.drafts.title,
                color: EatingTime.drafts.color,
                isDefault: true)
            let favorites = CollectionModel(
                id: EatingTime.favorites.rawValue,
                index: EatingTime.favorites.rawValue,
                title: RecipeSectionsModel.RecipeSectionType.favorites.title,
                color: EatingTime.favorites.color,
                isDefault: true)
            let inbox = CollectionModel(
                id: EatingTime.inbox.rawValue,
                index: EatingTime.inbox.rawValue,
                title: RecipeSectionsModel.RecipeSectionType.inbox.title,
                color: EatingTime.inbox.color,
                isDefault: true)
            
            CoreDataManager.shared.saveCollection(collections: [iWillCookIt, drafts, favorites, inbox])
            UserDefaultsManager.shared.isFillingDefaultCollection = true
        }
    }
    
    private func updateFavoritesCollection() {
        guard let favoriteDBCollection = CoreDataManager.shared.getCollection(by: EatingTime.favorites.rawValue),
              let allRecipes: [DBRecipe] = CoreDataManager.shared.getAllRecipes() else {
            UserDefaultsManager.shared.isFillingDefaultTechnicalCollection = true
            return
        }
        let domainFavorites = allRecipes.filter {
            UserDefaultsManager.shared.favoritesRecipeIds.contains(Int($0.id))
        }
        let favorites = domainFavorites.compactMap {
            ShortRecipeModel(withCollection: $0, isFavorite: true)
        }
        let favoriteCollection = CollectionModel(from: favoriteDBCollection)
        domainFavorites.forEach {
            if var recipe = Recipe(from: $0) {
                if var localCollection = recipe.localCollection {
                    localCollection.append(favoriteCollection)
                    recipe.localCollection = localCollection
                } else {
                    recipe.localCollection = [favoriteCollection]
                }
                
                CoreDataManager.shared.saveRecipes(recipes: [recipe])
            }
        }
        
        UserDefaultsManager.shared.isFillingDefaultTechnicalCollection = true
    }
}
