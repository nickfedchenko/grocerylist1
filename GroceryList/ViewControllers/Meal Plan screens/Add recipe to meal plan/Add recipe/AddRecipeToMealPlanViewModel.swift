//
//  AddRecipeToMealPlanViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.09.2023.
//

import UIKit

class AddRecipeToMealPlanViewModel: RecipeScreenViewModel {
    
    var updateDestinationList: (() -> Void)?
    var updateLabels: (() -> Void)?
    var mealPlan: MealPlan? {
        didSet { setMealPlan() }
    }
    
    private var allMealPlans: [MealPlan] = []
    private let colorManager = ColorManager.shared
    private(set) var labels: [MealPlanLabel] = []
    private var mealPlanDate = Date()
    private var destinationListId: UUID?
    private var mealPlanLabel: MealPlanLabel? {
        didSet { selectedLabel() }
    }
    private var isContinueSaving = false
    private var isContinueAddToCart = false
    private var ingredientsPhoto: [Data?] = []
    
    init(recipe: Recipe) {
        super.init(recipe: recipe, sectionColor: ColorManager.shared.colorMealPlan)
        
        destinationListId = UserDefaultsManager.shared.defaultDestinationListId
        mealPlanLabel = MealPlanLabel(defaultLabel: .none)
        
        setDefaultLabels()
        getMealPlans()
    }
    
    func getListName() -> String? {
        guard let listId = destinationListId,
              let dbList = CoreDataManager.shared.getList(list: listId.uuidString),
              let list = GroceryListsModel(from: dbList) else {
            return nil
        }
        return list.name
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        let mealPlansByDate = allMealPlans.filter { $0.date.onlyDate == date.onlyDate }
        let colorNumbers = mealPlansByDate.compactMap { $0.label?.color }
        return colorNumbers.map { colorManager.getLabelColor(index: $0) }
    }
    
    func saveMealPlan(date: Date) {
        mealPlanDate = date
        
        guard let destinationListId else {
            showDestinationLabel()
            isContinueSaving = true
            return
        }
        
        mealPlan = MealPlan(recipeId: recipe.id, date: date,
                            label: mealPlanLabel ?? MealPlanLabel(defaultLabel: .none),
                            destinationListId: destinationListId)
        
        router?.dismissAddRecipeToMealPlan()
    }
    
    func showDestinationLabel() {
        router?.goToDestinationList(delegate: self)
    }
    
    func addToCart(photo: [Data?]) {
        ingredientsPhoto = photo
        guard let destinationListId else {
            showDestinationLabel()
            isContinueAddToCart = true
            return
        }
        
        let recipeTitle = recipe.title
        recipe.ingredients.enumerated().forEach({ index, ingredient in
            let netProduct = ingredient.product
            let product = Product(listId: destinationListId,
                                  name: netProduct.title,
                                  isPurchased: false,
                                  dateOfCreation: Date(),
                                  category: netProduct.marketCategory?.title ?? "",
                                  isFavorite: false,
                                  imageData: photo[index],
                                  description: "",
                                  fromRecipeTitle: recipeTitle)
            CoreDataManager.shared.createProduct(product: product)
        })
    }
    
    func selectLabel(index: Int) {
        guard let selectedLabel = labels[safe: index] else {
            return
        }
        
        mealPlanLabel = selectedLabel
    }
    
    func showLabels() {
        router?.goToMealPlanLabels()
    }
    
    private func setMealPlan() {
        guard let mealPlan else {
            return
        }
        
        destinationListId = mealPlan.destinationListId
        mealPlanLabel = mealPlan.label
    }
    
    private func selectedLabel() {
        for (index, label) in labels.enumerated() {
            labels[index].isSelected = label.id == mealPlanLabel?.id
        }
        updateLabels?()
    }
    
    private func getMealPlans() {
        let allDBRecipes = CoreDataManager.shared.getAllRecipes() ?? []
        let recipes = allDBRecipes.compactMap { Recipe(from: $0) }
        
        let dates = [Date().after(dayCount: -2), Date().after(dayCount: -2),
                     Date().after(dayCount: -2), Date().after(dayCount: -2),
                     Date().after(dayCount: -2), Date().after(dayCount: -2), Date(),
                     Date().after(dayCount: 3), Date().after(dayCount: 3), Date().after(dayCount: 3)]
        
        dates.forEach {
            if let recipe = recipes.randomElement(),
               let label = labels.randomElement() {
                allMealPlans.append(MealPlan(recipeId: recipe.id, date: $0, label: label))
            }
        }
    }
    
    private func setDefaultLabels() {
        DefaultLabel.allCases.forEach {
            labels.append(MealPlanLabel(defaultLabel: $0))
        }
    }
}

extension AddRecipeToMealPlanViewModel: DestinationListDelegate {
    func selectedListId(_ listId: UUID) {
        UserDefaultsManager.shared.defaultDestinationListId = listId
        destinationListId = listId
        if isContinueSaving {
            saveMealPlan(date: mealPlanDate)
        }
        if isContinueAddToCart {
            addToCart(photo: ingredientsPhoto)
        }
        updateDestinationList?()
    }
}
