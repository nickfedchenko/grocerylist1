//
//  AddIngredientsToListViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 29.09.2023.
//

import UIKit

class AddIngredientsToListViewModel {
    
    weak var router: RootRouter?
    var reloadData: (() -> Void)?
    var updateDestinationList: (() -> Void)?
    var getImageData: ((IngredientForMealPlan) -> (Data?))?
    
    private let startDate: Date
    private var selectedDate: [Date]
    private let mealPlans: [MealPlan]
    
    private let colorManager = ColorManager.shared
    private var isMetricSystem = UserDefaultsManager.shared.isMetricSystem
    private var itemsInStock: [Stock] = []
    private(set) var addIngredientsType: AddIngredientsToListType = .recipe
    private var selectedList: UUID?
    private var selectedIngredients: [IngredientForMealPlan] = []
    private var recipes: [ShortRecipeForMealPlan] = []
    private let imageView = UIImageView()
    
    init(date: Date) {
        startDate = date
        
        selectedDate = date.getDates(by: date.after(dayCount: 6))
        mealPlans = CoreDataManager.shared.getAllMealPlans()?.map({ MealPlan(dbModel: $0) }) ?? []
        getItemsInStock()
        getRecipes()
        setDestinationListId()
    }
    
    func dates() -> String {
        selectedDate.sort(by: <)
        for (index, date) in selectedDate.enumerated() where index < selectedDate.count - 1 {
            let nextDate = date.nextDay
            if !selectedDate.contains(nextDate) {
                return R.string.localizable.customDates()
            }
        }
        return getDatesString()
    }
    
    func getSelectedDates() -> [Date] {
        selectedDate
    }
    
    func updateSelectedDates(dates: [Date]) {
        selectedDate = dates
        getRecipes()
        setDestinationListId()
        reloadData?()
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        let mealPlansByDate = mealPlans.filter { $0.date.onlyDate == date.onlyDate }
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
    
    func getDestinationListTitle() -> String {
        guard let selectedList,
              let dbList = CoreDataManager.shared.getList(list: selectedList.uuidString) else {
            return R.string.localizable.variousLists()
        }
        return dbList.name ?? ""
    }
    
    func setSortType(type: AddIngredientsToListType ) {
        addIngredientsType = type
        
        reloadData?()
    }
    
    func addAllToList() {
        selectedIngredients = recipes.flatMap { $0.ingredients }
        
        getRecipes()
        reloadData?()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.save()
        }
    }
    
    func save() {
        for ingredientForMealPlan in selectedIngredients {
            let destinationList: UUID
            if let selectedList {
                destinationList = selectedList
            } else if let listId = ingredientForMealPlan.listId {
                destinationList = listId
            } else {
                break
            }

            let netProduct = ingredientForMealPlan.ingredient.product
            let product = Product(listId: destinationList,
                                  name: netProduct.title,
                                  isPurchased: false,
                                  dateOfCreation: Date(),
                                  category: netProduct.marketCategory?.title ?? "",
                                  isFavorite: false,
                                  imageData: getImageData?(ingredientForMealPlan),
                                  description: "",
                                  fromMealPlan: ingredientForMealPlan.mealPlanId)
            CoreDataManager.shared.createProduct(product: product)
        }
        router?.dismissCurrentController()
    }
    
    func getSections() -> [AddIngredientsToListHeaderModel] {
        var headers: [AddIngredientsToListHeaderModel] = []
        guard addIngredientsType == .recipe else {
            let categories = sortByCategories()
            categories.forEach { category in
                let headerModel = AddIngredientsToListHeaderModel(
                    title: category.title,
                    date: Date(),
                    type: addIngredientsType,
                    products: category.ingredients
                )
                headers.append(headerModel)
            }
            return headers
        }
        recipes.forEach { recipe in
            let headerModel = AddIngredientsToListHeaderModel(
                title: recipe.title,
                date: recipe.mealPlanDate,
                type: addIngredientsType,
                products: recipe.ingredients
            )
            headers.append(headerModel)
        }
        return headers
    }

    func unit(unitID: Int?) -> UnitSystem? {
        guard let unitID = unitID,
              let shouldSelectUnit: RecipeScreenViewModel.RecipeUnit = .init(rawValue: unitID) else {
            return nil
        }
        switch shouldSelectUnit {
        case .gram, .ozz:
            return isMetricSystem ? .gram : .ozz
        case .millilitre:
            return isMetricSystem ? .mililiter : .fluidOz
        }
    }
    
    func convertValue(unitID: Int?) -> Double {
        guard let unitID = unitID,
              let shouldSelectUnit: RecipeScreenViewModel.RecipeUnit = .init(rawValue: unitID) else {
            return 0
        }
        switch shouldSelectUnit {
        case .gram:
            return isMetricSystem ? 1 : UnitSystem.gram.convertValue
        case .ozz:
            return isMetricSystem ? UnitSystem.ozz.convertValue : 1
        case .millilitre:
            return isMetricSystem ? 1 : UnitSystem.mililiter.convertValue
        }
    }
    
    func getPantryColor(ingredient: IngredientForMealPlan) -> UIColor? {
        guard let stockId = ingredient.stocksId,
              let dbStock = CoreDataManager.shared.getStock(by: stockId),
              let dbPantry = dbStock.pantry else {
            return nil
        }
        
        return colorManager.getGradient(index: Int(dbPantry.color)).medium
    }
    
    func updateState(indexPath: IndexPath) {
        guard let ingredient = recipes[safe: indexPath.section]?.ingredients[safe: indexPath.row] else {
            return
        }
        
        let state: IngredientState = ingredient.state == .unselect ? .select : .unselect
        recipes[indexPath.section].ingredients[indexPath.row].state = state
        let updatedIngredient = recipes[indexPath.section].ingredients[indexPath.row]

        if state == .unselect {
            selectedIngredients.removeAll { updatedIngredient.ingredient.id == $0.ingredient.id }
        } else {
            selectedIngredients.append(updatedIngredient)
        }
        reloadData?()
    }
    
    func removeInStockInfo(ingredient: IngredientForMealPlan) {
        guard let itemInStockId = ingredient.stocksId else {
            return
        }
        itemsInStock.removeAll { $0.id == itemInStockId }
        getRecipes()
        reloadData?()
    }
    
    func showDestinationLabel() {
        router?.goToDestinationList(delegate: self)
    }
    
    private func getItemsInStock() {
        let dbStocks = CoreDataManager.shared.getAllStock()?.filter({ $0.isAvailability }) ?? []
        itemsInStock = dbStocks.map({ Stock(dbModel: $0) })
    }
    
    private func getRecipes() {
        recipes.removeAll()
        for date in selectedDate {
            let plans = mealPlans.filter { $0.date.onlyDate == date.onlyDate }
            for plan in plans {
                guard let dbRecipe = CoreDataManager.shared.getRecipe(by: plan.recipeId) else {
                    break
                }
                
                let ingredients = getIngredients(plan: plan, dbRecipe: dbRecipe)
                recipes.append(ShortRecipeForMealPlan(mealPlanDate: date,
                                                      id: Int(dbRecipe.id),
                                                      title: dbRecipe.title ?? "",
                                                      createdAt: dbRecipe.createdAt ?? Date(),
                                                      ingredients: ingredients))
            }
        }
    }
    
    private func getIngredients(plan: MealPlan, dbRecipe: DBRecipe) -> [IngredientForMealPlan] {
        var ingredients: [IngredientForMealPlan] = []
        let dbIngredients = (try? JSONDecoder().decode([Ingredient].self, from: dbRecipe.ingredients ?? Data())) ?? []
        dbIngredients.forEach { dbIngredient in
            var stocksId: UUID?
            var state: IngredientState = .unselect
            let purchasedProducts = getPurchasedProducts(plan: plan)
            
            itemsInStock.forEach { stock in
                if stock.name.lowercased() == dbIngredient.product.title.lowercased() {
                    state = .inStock
                    stocksId = stock.id
                }
            }
            
            if purchasedProducts.contains(where: { $0.name.lowercased() == dbIngredient.product.title.lowercased() }) {
                state = .purchase
            }
            
            if selectedIngredients.contains(where: { $0.ingredient.id == dbIngredient.id }) {
                state = .select
            }
            
            ingredients.append(IngredientForMealPlan(ingredient: dbIngredient,
                                                     state: state,
                                                     mealPlanId: plan.id,
                                                     stocksId: stocksId,
                                                     listId: plan.destinationListId,
                                                     recipeTitle: dbRecipe.title ?? ""))
        }
        return ingredients
    }
    
    private func getPurchasedProducts(plan: MealPlan) -> [Product] {
        var purchasedProducts: [Product] = []
        if let destinationListId = plan.destinationListId?.uuidString,
           let dbList = CoreDataManager.shared.getList(list: destinationListId),
           let list = GroceryListsModel(from: dbList) {
            purchasedProducts = list.products.filter { $0.isPurchased }
        }
        return purchasedProducts
    }
    
    private func getDatesString() -> String {
        let startDate = selectedDate.min() ?? Date()
        let endDate = selectedDate.max() ?? Date()
        
        let startMonth = startDate.getStringDate(format: "MMM")
        let endMonth = endDate.getStringDate(format: "MMM")
        let startYear = startDate.getStringDate(format: "yyyy")
        let endYear = endDate.getStringDate(format: "yyyy")
        let startDay = startDate.getStringDate(format: "d")
        let endDay = endDate.getStringDate(format: "d")
        
        if startMonth == endMonth && startYear == endYear {
            return startMonth + " " + startDay + " - " + endDay + ", " + startYear
        }
        
        if startMonth != endMonth && startYear == endYear {
            let start = startMonth + " " + startDay
            let end = endMonth + " " + endDay
            return start + " - " + end + ", " + startYear
        }
        
        if startMonth == endMonth && startYear != endYear {
            let start = startMonth + " " + startDay + " " + startYear
            let end = endMonth + " " + endDay + " " + endYear
            return start + " - " + end
        }
        return startMonth + " " + startDay + " - " + endDay + ", " + startYear
    }
    
    private func setDestinationListId() {
        var plans: [MealPlan] = []
        for date in selectedDate {
            plans.append(contentsOf: mealPlans.filter { $0.date.onlyDate == date.onlyDate })
        }
        let listIds = plans.compactMap { $0.destinationListId }
        let uniqueListIds = Array(Set(listIds))
        selectedList = uniqueListIds.count == 1 ? uniqueListIds.first : nil
    }
    
    private func sortByCategories() -> [ShortRecipeForMealPlan] {
        let allIngredients = recipes.flatMap { $0.ingredients }
        let ingredientsByCategory = Dictionary(grouping: allIngredients, by: \.ingredient.product.marketCategory?.title)
        let sortCategory = ingredientsByCategory.sorted { $0.key ?? "" < $1.key ?? "" }
        return sortCategory.map {
            ShortRecipeForMealPlan(mealPlanDate: Date(),
                                   id: -1,
                                   title: $0.key ?? "",
                                   createdAt: Date(),
                                   ingredients: $0.value)
        }
    }
}

extension AddIngredientsToListViewModel: DestinationListDelegate {
    func selectedListId(_ listId: UUID) {
        selectedList = listId
        updateDestinationList?()
    }
}
