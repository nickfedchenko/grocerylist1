//
//  SearchInRecipeViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.03.2023.
//

import Foundation

final class SearchInRecipeViewModel {
    
    weak var router: RootRouter?
    var updateData: (() -> Void)?
    var recipesCount: Int {
        guard editableRecipes.isEmpty else {
            return editableRecipes.count + (isSearchAllRecipe ? 0 : 1)
        }
        return 0
    }
    var isSearchAllRecipe: Bool {
        section == nil
    }
    
    private(set) var placeholder = ""
    private var section: RecipeSectionsModel?
    private var recipes: [ShortRecipeModel] = []
    private var searchText = ""
    private var editableRecipes: [ShortRecipeModel] = [] {
        didSet { updateData?() }
    }
    
    init(section: RecipeSectionsModel?) {
        guard let section else {
            searchAllRecipe()
            return
        }
        self.section = section
        self.placeholder = section.sectionType.title
        recipes = section.recipes
    }
    
    func search(text: String?) {
        editableRecipes.removeAll()
        
        var filteredRecipes: [ShortRecipeModel] = []
        var filteredRecipesWithIngredient: [ShortRecipeModel] = []
        guard let text = text?.lowercased().trimmingCharacters(in: .whitespaces),
              text.count >= 3 else {
            searchText = ""
            editableRecipes = filteredRecipes
            return
        }
        
        filteredRecipes = recipes.filter { $0.title.smartContains(text) }
        recipes.forEach { recipe in
            if recipe.ingredients?.contains(where: { $0.product.title.smartContains(text) }) ?? false {
                filteredRecipesWithIngredient.append(recipe)
            }
        }
        searchText = text
        filteredRecipesWithIngredient.removeAll { recipe in
            filteredRecipes.contains { $0.id == recipe.id }
        }
        editableRecipes = filteredRecipes + filteredRecipesWithIngredient
    }
    
    func getRecipe(by index: Int) -> ShortRecipeModel? {
        editableRecipes[safe: index]
    }
    
    func searchAllRecipe() {
        section = nil
        placeholder = R.string.localizable.allRecipes()
        getAllRecipe()
        search(text: searchText)
    }
    
    func showRecipe(_ recipe: ShortRecipeModel) {
        guard let dbRecipe = CoreDataManager.shared.getRecipe(by: recipe.id),
              let recipe = Recipe(from: dbRecipe) else {
            return
        }
        router?.goToRecipe(recipe: recipe)
    }
    
    private func getAllRecipe() {
        guard let dbRecipes = CoreDataManager.shared.getAllRecipes() else { return }
        recipes = dbRecipes.compactMap { ShortRecipeModel(withIngredients: $0) }
    }
}
