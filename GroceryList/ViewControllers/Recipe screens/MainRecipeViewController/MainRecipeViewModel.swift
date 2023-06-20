//
//  MainRecipeViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import UIKit

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
        let model = dataSource.recipesSections[safe: indexPath.section]?.recipes[safe: indexPath.item - 1]
        return model
    }
    
    func getRecipeSectionsModel(for index: Int) -> RecipeSectionsModel? {
        let model = dataSource.recipesSections[safe: index]
        return model
    }
    
    func recipeCount(for section: Int) -> Int {
        var count = dataSource.recipesSections[section].recipes.count
        if count >= 1 {
            count += 1
        }
        let maxCount = dataSource.recipeCount
        return count < maxCount ? count : maxCount
    }
    
    func collectionColor(for index: Int) -> Theme {
        let color = dataSource.recipesSections[safe: index]?.color ?? 0
        return colorManager.getGradient(index: color)
    }
    
    func collectionImage(for indexPath: IndexPath) -> (url: String, data: Data?) {
        let url = dataSource.recipesSections[safe: indexPath.item]?.imageUrl ?? ""
        let data = dataSource.recipesSections[safe: indexPath.item]?.localImage
        return (url, data)
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
        guard let recipeId = dataSource.recipesSections[safe: indexPath.section]?
                                       .recipes[safe: indexPath.item - 1]?.id,
              let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId),
              let model = Recipe(from: dbRecipe) else {
            return
        }
        router?.goToRecipe(recipe: model)
    }
    
    func tappedAddItem() {
        router?.goCreateNewList(compl: { [weak self] model, _  in
            self?.router?.goProductsVC(model: model, compl: { })
        })
    }
    
    func showSearch() {
        router?.goToSearchInRecipe()
    }
}
