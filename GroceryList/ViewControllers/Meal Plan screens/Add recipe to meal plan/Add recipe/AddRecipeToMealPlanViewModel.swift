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
    var addedToCart: (() -> Void)?
    var selectedDate: ((Date) -> Void)?
    var mealPlan: MealPlan? {
        didSet { setMealPlan() }
    }
    
    var updatedSharingPlan: (() -> Void)?
    
    private var allMealPlans: [MealPlan] = []
    private let colorManager = ColorManager.shared
    private(set) var labels: [MealPlanLabel] = []
    private(set) var mealPlanDate: Date
    private var destinationListId: UUID?
    private var mealPlanLabel: MealPlanLabel? {
        didSet { selectedLabel() }
    }
    private var isContinueAddToCart = false
    private var ingredientsPhoto: [Data?] = []
    private var changedForSharing = false
    
    init(recipe: Recipe, mealPlanDate: Date) {
        self.mealPlanDate = mealPlanDate
        mealPlanLabel = MealPlanLabel(defaultLabel: .none)
        destinationListId = UserDefaultsManager.shared.defaultDestinationListId
        
        super.init(recipe: recipe, sectionColor: ColorManager.shared.colorMealPlan)
        
        getMealPlansFromStorage()
        getLabelsFromStorage()
    }
    
    func getListName() -> String? {
        guard let listId = destinationListId,
              let dbList = CoreDataManager.shared.getList(list: listId.uuidString),
              let list = GroceryListsModel(from: dbList) else {
            UserDefaultsManager.shared.defaultDestinationListId = nil
            destinationListId = nil
            return nil
        }
        return list.name
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        let mealPlansByDate = allMealPlans.filter { $0.date.onlyDate == date.onlyDate }
        let labels = mealPlansByDate.compactMap {
            if let labelId = $0.label,
               let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString) {
                return MealPlanLabel(dbModel: dbLabel)
            } else {
                return MealPlanLabel(defaultLabel: .none)
            }
        }
        let colorNumbers = labels.compactMap { $0.color }
        return colorNumbers.map { colorManager.getLabelColor(index: $0) }
    }
    
    func saveMealPlan(date: Date) {
        mealPlanDate = date
        
        let label = mealPlanLabel
        let newMealPlan: MealPlan
        if var mealPlan {
            let changedDate = mealPlan.date != date
            let changedLabel = mealPlan.label != label?.id
            changedForSharing = changedDate || changedLabel
            mealPlan.date = date
            mealPlan.label = label?.id
            mealPlan.destinationListId = destinationListId
            mealPlan = ifNeedUpdatedSharedMealPlan(mealPlan: mealPlan)
            newMealPlan = mealPlan
        } else {
            changedForSharing = true
            newMealPlan = MealPlan(recipeId: recipe.id, date: date,
                                   label: label?.id,
                                   destinationListId: destinationListId)
        }
        
        CoreDataManager.shared.saveMealPlan(newMealPlan)
        CloudManager.shared.saveCloudData(mealPlan: newMealPlan)
        selectedDate?(date)
        if changedForSharing {
            updatedSharingPlan?()
        }
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
        
        if let dbList = CoreDataManager.shared.getList(list: destinationListId.uuidString),
           var list = GroceryListsModel(from: dbList),
            list.products.isEmpty {
            list.typeOfSorting = SortingType.recipe.rawValue
            CoreDataManager.shared.saveList(list: list)
        }
        
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
                                  fromMealPlan: mealPlan?.id)
            CoreDataManager.shared.createProduct(product: product)
        })
        addedToCart?()
    }
    
    func selectLabel(index: Int) {
        guard let selectedLabel = labels[safe: index] else {
            return
        }
        
        mealPlanLabel = selectedLabel
    }
    
    func showLabels() {
        router?.goToMealPlanLabels(label: mealPlanLabel, isDisplayState: false,
                                   updateUI: { [weak self] selectedLabel in
            self?.mealPlanLabel = selectedLabel
            self?.getLabelsFromStorage()
            self?.updateLabels?()
        })
    }
    
    private func setMealPlan() {
        guard let mealPlan else {
            return
        }
        
        destinationListId = mealPlan.destinationListId
        if let labelId = mealPlan.label,
           let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString) {
            mealPlanLabel = MealPlanLabel(dbModel: dbLabel)
        } else {
            mealPlanLabel = nil
        }
    }
    
    private func selectedLabel() {
        for (index, label) in labels.enumerated() {
            labels[index].isSelected = label.id == mealPlanLabel?.id
        }
        updateLabels?()
    }
    
    private func ifNeedUpdatedSharedMealPlan(mealPlan: MealPlan) -> MealPlan {
        guard UserAccountManager.shared.getUser() != nil,
              let mealPlansSharedInfo = CoreDataManager.shared.getMealListSharedInfo(),
              let sharedInfo = mealPlansSharedInfo.first(where: { mealPlan.sharedId == $0.mealListId }) else {
            return mealPlan
        }
        var updatedMealPlan = mealPlan
        if let createdAt = sharedInfo.createdAt, updatedMealPlan.date < createdAt {
            updatedMealPlan.sharedId = ""
        }
        return updatedMealPlan
    }
    
    private func getMealPlansFromStorage() {
        allMealPlans = CoreDataManager.shared.getAllMealPlans()?.map({ MealPlan(dbModel: $0) }) ?? []
    }
    
    private func getLabelsFromStorage() {
        labels = CoreDataManager.shared.getAllLabels()?.map({
            var label = MealPlanLabel(dbModel: $0)
            label.isSelected = label.id == mealPlanLabel?.id
            return label
        }) ?? []
    }
}

extension AddRecipeToMealPlanViewModel: DestinationListDelegate {
    func selectedListId(_ listId: UUID) {
        UserDefaultsManager.shared.defaultDestinationListId = listId
        destinationListId = listId
        if isContinueAddToCart {
            addToCart(photo: ingredientsPhoto)
        }
        updateDestinationList?()
    }
}
