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
        
        updateOldCollectionIfNeeded()
        createDefaultsCollection()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(receptsLoaded),
                                               name: .recieptsDownladedAnsSaved, object: nil)
    }
    
    @objc
    private func receptsLoaded() {
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
        guard let allDBCollection = CoreDataManager.shared.getAllCollection(),
              let allDBRecipes = CoreDataManager.shared.getAllRecipes() else {
            return
        }
        
        let favoritesID = UserDefaultsManager.favoritesRecipeIds
        
        let collection = allDBCollection.compactMap {
            CollectionModel(from: $0)
        }
        
        let recipes = allDBRecipes.compactMap {
            let isFavorite = favoritesID.contains(Int($0.id))
            return ShortRecipeModel(withCollection: $0, isFavorite: isFavorite)
        }
        
        collection.forEach { collection in
            let recipes = recipes.filter {
                $0.localCollection?.contains(where: { collection.id == $0.id }) ?? false
            }
            
            let recipesShuffled = recipes.shuffled()
            let imageUrl = recipesShuffled.first?.photo
            var defaultImage: UIImage?
            if imageUrl == nil {
                defaultImage = R.image.defaultRecipeImage()
            }
            let customSection = RecipeSectionsModel(collectionId: collection.id,
                                                    cellType: .recipePreview,
                                                    sectionType: .custom(collection.title.localized),
                                                    recipes: recipesShuffled,
                                                    color: collection.color,
                                                    imageUrl: imageUrl,
                                                    localImage: collection.localImage ?? defaultImage?.pngData())
            
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
    
    private func createDefaultsCollection() {
        if !UserDefaultsManager.isFillingDefaultCollection {
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
            
            UserDefaultsManager.isFillingDefaultCollection = true
        }
    }
    
    private func updateOldCollectionIfNeeded() {
        let collections = CoreDataManager.shared.getAllCollection() ?? []
        guard UserDefaultsManager.isFillingDefaultCollection && !collections.isEmpty else {
            return
        }
        
        guard !UserDefaultsManager.isFillingDefaultTechnicalCollection else {
            return
        }
        
        CoreDataManager.shared.deleteCollection(by: UserDefaultsManager.miscellaneousCollectionId)
        
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
        
        guard let favoriteDBCollection = CoreDataManager.shared.getCollection(by: EatingTime.favorites.rawValue),
              let allRecipes: [DBRecipe] = CoreDataManager.shared.getAllRecipes() else {
            UserDefaultsManager.isFillingDefaultTechnicalCollection = true
            return
        }
        let domainFavorites = allRecipes.filter {
            UserDefaultsManager.favoritesRecipeIds.contains(Int($0.id))
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
        
        UserDefaultsManager.isFillingDefaultTechnicalCollection = true
    }
    
    private func createTechnicalCollection() {
        
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
    }
}
