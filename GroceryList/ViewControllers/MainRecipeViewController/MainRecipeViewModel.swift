//
//  MainRecipeViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import Foundation

final class MainRecipeViewModel {
    
    weak var router: RootRouter?
    
    var reloadRecipes: (() -> Void)?
    var updateRecipeLoaded: (() -> Void)?
    
    private var dataSource: MainRecipeDataSourceProtocol
    private var colorManager = ColorManager()
    private let groupForSavingSharedUser = DispatchGroup()
    private var startTime: Date?
    
    init(dataSource: MainRecipeDataSourceProtocol) {
        self.dataSource = dataSource
        self.dataSource.recipeUpdate = { [weak self] in
            self?.updateRecipeLoaded?()
        }
    }
    
    var numberOfSections: Int {
        dataSource.recipesSections.count
    }
    
    var defaultRecipeCount: Int {
        dataSource.recipeCount
    }
    
    func ifNeedActivity() -> Bool {
        return (CoreDataManager.shared.getAllRecipes()?.count ?? 0) <= 0
    }
    
    func getShortRecipeModel(for indexPath: IndexPath) -> ShortRecipeModel? {
        let model = dataSource.recipesSections[safe: indexPath.section]?.recipes[safe: indexPath.item]
        return model
    }
    
    func getRecipeSectionsModel(for index: Int) -> RecipeSectionsModel? {
        let model = dataSource.recipesSections[safe: index]
        return model
    }
    
    func recipeCount(for section: Int) -> Int {
        let count = dataSource.recipesSections[section].recipes.count
        let maxCount = dataSource.recipeCount
        return count < maxCount ? count : maxCount
    }
    
    func updateRecipesSection() {
        dataSource.makeRecipesSections()
    }
    
    func updateFavorites() {
        dataSource.updateFavoritesSection()
    }
    
    func updateCustomSection() {
        dataSource.updateCustomSection()
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.updateRecipesSection()
            self.reloadRecipes?()
        }
    }
    
    // routing
    func showCustomRecipe(recipe: Recipe) {
        DispatchQueue.main.async {
            self.router?.goToRecipe(recipe: recipe)
        }
    }
    
    func showRecipe(by indexPath: IndexPath) {
        let recipeId = dataSource.recipesSections[indexPath.section].recipes[indexPath.item].id
        guard let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId),
              var model = Recipe(from: dbRecipe) else {
            return
        }
        router?.goToRecipe(recipe: model)
    }
}
