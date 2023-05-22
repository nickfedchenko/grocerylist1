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
    func updateFavoritesSection()
    func updateCustomSection()
}

class MainRecipeDataSource: MainRecipeDataSourceProtocol {
    
    var recipeUpdate: (() -> Void)?
    var recipesSections: [RecipeSectionsModel] = []
    var recipeCount: Int { 12 }

    init() {
        makeRecipesSections()
        addObserver()
        
        // дефолтные коллекции
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
        updateFavoritesSection()
        updateCustomSection()
    }
    
    func updateFavoritesSection() {
        guard UserDefaultsManager.favoritesRecipeIds.count > 0 else {
            return
        }
        guard let allRecipes: [DBRecipe] = CoreDataManager.shared.getAllRecipes() else { return }
        let domainFavorites = allRecipes.filter { UserDefaultsManager.favoritesRecipeIds.contains(Int($0.id)) }
        let favorites = domainFavorites.compactMap { ShortRecipeModel(withCollection: $0) }
        let favoritesSection = RecipeSectionsModel(cellType: .recipePreview, sectionType: .favorites, recipes: favorites)

        guard let index = recipesSections.firstIndex(where: { $0.sectionType == .favorites }) else {
            if !favorites.isEmpty {
                recipesSections.insert(favoritesSection, at: 0)
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

