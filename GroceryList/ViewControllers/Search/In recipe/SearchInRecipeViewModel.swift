//
//  SearchInRecipeViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.03.2023.
//

import UIKit

final class SearchInRecipeViewModel {
    
    weak var router: RootRouter?
    var updateData: (() -> Void)?
    var updateFilter: (() -> Void)?
    var recipesCount: Int {
        guard editableRecipes.isEmpty else {
            return editableRecipes.count + (isSearchAllRecipe ? 0 : 1)
        }
        return 0
    }
    var isSearchAllRecipe: Bool {
        section == nil
    }
    var theme: Theme {
        guard let colorIndex = section?.color else {
            return ColorManager.shared.getColorForRecipe()
        }
        return ColorManager.shared.getGradient(index: colorIndex)
    }
    
    private(set) var recipeTags: [RecipeTag] = []
    private(set) var placeholder = ""
    private(set) var section: RecipeSectionsModel?

    private var allRecipes: [RecipeForSearchModel] = []
    private var filterRecipes: [RecipeForSearchModel] = []
    private var searchText = ""
    private var editableRecipes: [RecipeForSearchModel] = [] {
        didSet { updateData?() }
    }
    private var filters: [Filter] = [] {
        didSet { appendFilters() }
    }
    
    init(section: RecipeSectionsModel?) {
        guard let section else {
            DispatchQueue.global().async {
                self.searchAllRecipe()
            }
            return
        }
        self.section = section
        self.placeholder = section.sectionType.title
        allRecipes = section.recipes.map({ RecipeForSearchModel(shortRecipeModel: $0) })
        filterRecipes = allRecipes
        editableRecipes = allRecipes
    }
    
    func search(text: String?) {
        editableRecipes.removeAll()
        
        var filteredRecipes: [RecipeForSearchModel] = []
        var filteredRecipesWithIngredient: [RecipeForSearchModel] = []
        guard let text = text?.lowercased().trimmingCharacters(in: .whitespaces),
              text.count >= 3 else {
            searchText = ""
            editableRecipes = allRecipes
            return
        }
        
        filteredRecipes = filterRecipes.filter { $0.title.smartContains(text) }
        filterRecipes.forEach { recipe in
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
    
    func getRecipe(by index: Int) -> RecipeForSearchModel? {
        editableRecipes[safe: index]
    }
    
    func searchAllRecipe() {
        section = nil
        placeholder = R.string.localizable.allRecipes()
        getAllRecipe()
        search(text: searchText)
        filterRecipes = allRecipes
        editableRecipes = allRecipes
    }
    
    func showRecipe(_ recipe: RecipeForSearchModel) {
        guard let dbRecipe = CoreDataManager.shared.getRecipe(by: recipe.id),
              let recipe = Recipe(from: dbRecipe) else {
            return
        }
        router?.goToRecipe(recipe: recipe, sectionColor: nil, fromSearch: true)
    }
    
    func showFilter() -> UIViewController {
        let viewModel = RecipeFilterViewModel(theme: isSearchAllRecipe ? nil : theme)
        viewModel.isAllRecipe = isSearchAllRecipe
        viewModel.selectedFilters = { [weak self] filters in
            self?.filters = filters
            self?.recipeTags = filters.flatMap({ $0.tags })
            self?.updateFilter?()
        }
        return RecipeFilterViewController(viewModel: viewModel)
    }
    
    func removeTag(recipeTag: String) {
        guard let recipeTag = recipeTags.first(where: { $0.title == recipeTag }),
            let filterIndex = filters.firstIndex(where: { $0.filter == recipeTag.filter }) else {
            return
        }
        recipeTags.removeAll { $0.id == recipeTag.id }
        filters[filterIndex].tags.removeAll { $0.id == recipeTag.id }
        
        appendFilters()
    }
    
    private func appendFilters() {
        var filterRecipe: [RecipeForSearchModel] = allRecipes
        
        for filter in filters {
            guard !filter.tags.isEmpty else {
                continue
            }
            switch filter.filter {
            case .exception:
                filterRecipe = filterRecipe.filter { recipe in
                    !recipe.exceptionTags.contains(where: { recipeTag in
                        filter.tags.contains { recipeTag.id == $0.id }
                    })
                }
            case .diet:
                filterRecipe = filterRecipe.filter { recipe in
                    recipe.dietTags.contains(where: { recipeTag in
                        filter.tags.contains { recipeTag.id == $0.id }
                    })
                }
            case .typeOfDish:
                filterRecipe = filterRecipe.filter { recipe in
                    recipe.dishTypeTags.contains(where: { recipeTag in
                        filter.tags.contains { recipeTag.id == $0.id }
                    })
                }
            case .cookingMethod:
                filterRecipe = filterRecipe.filter { recipe in
                    recipe.processingTypeTags.contains(where: { recipeTag in
                        filter.tags.contains { recipeTag.id == $0.id }
                    })
                }
            case .caloriesPerServing:
                let tag = filter.tags as? [CaloriesPerServingFilter]
                let minValue = Double(tag?.compactMap({ $0.minMaxValue.min }).min() ?? 0)
                let maxValue = Double(tag?.compactMap({ $0.minMaxValue.max }).max() ?? 0)
                filterRecipe = filterRecipe.filter {
                    let kcal = $0.values?.serving?.kcal ?? 0
                    return minValue <= kcal && maxValue >= kcal
                }
            case .cookingTime:
                let tag = filter.tags as? [CookingTimeFilter]
                let maxTime = Int32(tag?.compactMap({ $0.maxTime }).max() ?? 0)
                filterRecipe = filterRecipe.filter { $0.time <= maxTime }
            case .quantityOfIngredients:
                let tag = filter.tags as? [QuantityOfIngredientsFilter]
                let maxIngredients = tag?.compactMap({ $0.maxIngredients }).max() ?? 0
                filterRecipe = filterRecipe.filter { ($0.ingredients?.count ?? 0) <= maxIngredients }
            }
        }
        
        self.filterRecipes = filterRecipe
        editableRecipes = filterRecipes
        updateData?()
    }
    
    private func getAllRecipe() {
        guard let dbRecipes = CoreDataManager.shared.getAllRecipes() else { return }
        allRecipes = dbRecipes.compactMap { dbRecipe in
            RecipeForSearchModel(dbModel: dbRecipe,
                                 isFavorite: UserDefaultsManager.favoritesRecipeIds.contains(where: { $0 == dbRecipe.id }))
        }
    }
}
