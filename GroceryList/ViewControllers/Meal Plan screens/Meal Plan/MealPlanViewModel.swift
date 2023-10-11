//
//  MealPlanViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.09.2023.
//

import UIKit

class MealPlanViewModel {
    
    weak var router: RootRouter?
    var reloadData: (() -> Void)?
    var updateEditMode: (() -> Void)?
    var updateEditTabBar: (() -> Void)?
    
    private let dataSource: MealPlanDataSource
    private let colorManager = ColorManager.shared
    private var selectedDate = Date()
    
    var theme: Theme {
        colorManager.colorMealPlan
    }
    
    var isEditMode: Bool {
        dataSource.isEditMode
    }
    
    init(dataSource: MealPlanDataSource) {
        self.dataSource = dataSource
        
        dataSource.reloadData = { [weak self] in
            self?.reloadData?()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataSource),
                                               name: .cloudMealPlans, object: nil)
    }
    
    func getMealPlanSections(by date: Date) -> [MealPlanSection] {
        return dataSource.getMealPlans(by: date)
    }

    func isEmptySection(by date: Date) -> Bool {
        var planEmpty = true
        var noteEmpty = true
        let section = dataSource.getMealPlans(by: date)
        
        section.forEach { section in
            section.mealPlans.forEach {
                if $0.type == .plan {
                    planEmpty = false
                }
                if $0.type == .note {
                    noteEmpty = false
                }
            }
        }
        
        return planEmpty && noteEmpty
    }
    
    func getRecipe(by date: Date, for index: IndexPath) -> ShortRecipeModel? {
        return dataSource.getRecipe(by: date, for: index)
    }
    
    func getLabel(by date: Date, for index: IndexPath, type: MealPlanCellType) -> (text: String, color: UIColor) {
        guard let label = dataSource.getLabel(by: date, for: index, type: type) else {
            return ("", .clear)
        }
        let color = colorManager.getLabelColor(index: label.color)
        return (label.title, color)
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        let colorNumbers = dataSource.getLabelColors(by: date)
        return colorNumbers.map { colorManager.getLabelColor(index: $0) }
    }
    
    func getNote(by date: Date, for index: IndexPath) -> MealPlanNote? {
        return dataSource.getNote(by: date, for: index)
    }
    
    func updateIndexAfterMove(cellModels: [MealPlanCellModel]) {
        dataSource.updateIndexAfterMove(cellModels: cellModels)
        updateStorage()
    }
    
    func updateStorage() {
        dataSource.getMealPlansFromStorage()
        reloadData?()
    }
    
    func showSelectRecipeToMealPlan(selectedDate: Date) {
        router?.goToSelectRecipeToMealPlan(date: selectedDate, updateUI: { [weak self] in
            self?.updateStorage()
        })
    }
    
    func showAddRecipeToMealPlan(by index: IndexPath) {
        guard let mealPlan = dataSource.getMealPlan(by: index),
              let dbRecipe = CoreDataManager.shared.getRecipe(by: mealPlan.recipeId),
              let recipe = Recipe(from: dbRecipe) else {
            return
        }
        
        router?.goToRecipeFromMealPlan(recipe: recipe, mealPlan: mealPlan, updateUI: { [weak self] in
            self?.updateStorage()
        })
    }
    
    func showAddNoteToMealPlan(by date: Date, for index: IndexPath? = nil) {
        var note: MealPlanNote?
        if let index {
            note = dataSource.getNote(by: index)
        }
        
        router?.goToAddNoteToMealPlan(note: note, date: note?.date ?? date,
                                      updateUI: { [weak self] in
            self?.updateStorage()
        })
    }
    
    func showContextMenu(date: Date) {
        selectedDate = date
        let mealPlan = dataSource.sdsd(date: date)
        router?.goToMealPlanContextMenu(contextDelegate: self, mealPlan: mealPlan)
    }
    
    func editMode(isEdit: Bool) {
        dataSource.updateEditMode(isEdit: isEdit)
        reloadData?()
        updateEditMode?()
    }
    
    func updateEditMealPlan(_ mealPlan: MealPlanCellModel) {
        dataSource.updateEditMealPlan(mealPlan)
        reloadData?()
        updateEditTabBar?()
    }
    
    func editMealPlansCount() -> Int {
        dataSource.editMealPlan.count
    }
    
    func addAllMealPlansToEdit() {
        dataSource.addEditAllMealPlans()
        updateEditTabBar?()
    }
    
    func moveEditMeals() {
        deleteEditMealPlans()
    }
    
    func moveToCalendar(date: Date) {
        dataSource.copyEditMealPlans(date: date)
        
        moveEditMeals()
        resetEditProducts()
        updateStorage()
    }
    
    func showCalendar(currentDate: Date, isCopy: Bool) {
        router?.goToMealPlanCalendar(currentDate: currentDate,
                                     selectedDate: { [weak self] date in
            self?.dataSource.copyEditMealPlans(date: date)
            if !isCopy {
                self?.moveEditMeals()
            }
            self?.resetEditProducts()
            self?.updateStorage()
        })
    }
    
    func deleteEditMealPlans() {
        dataSource.deleteEditMealPlans()
        updateStorage()
        updateEditTabBar?()
    }
    
    func resetEditProducts() {
        dataSource.resetEditMealPlans()
        updateEditTabBar?()
    }
    
    private func showAddIngredientsToList() {
        router?.goToAddIngredientsToList(startDate: selectedDate)
    }
    
    private func sharingTapped() {
        guard UserAccountManager.shared.getUser() != nil else {
            router?.goToSharingPopUp()
            return
        }
        // TODO: отправка на бэк данных о расшаренном плане
//        let users = SharedListManager.shared.sharedListsUsers[model.sharedId] ?? []
//        var shareModel = model
//        if let dbModel = CoreDataManager.shared.getList(list: model.id.uuidString),
//            let model = GroceryListsModel(from: dbModel) {
//            shareModel = model
//        }
//        router?.goToSharingList(listToShare: shareModel, users: users)
    }
    
    private func showLabel() {
        router?.goToMealPlanLabels(label: nil, updateUI: { _ in })
    }
    
    private func sendToMealPlanByText() -> String {
        var list = ""
        let newLine = "\n"
        let date = selectedDate.getStringDate(format: "ddMMyyyy")
        list += date
        list += newLine + newLine
        let info = dataSource.getMealPlans(by: selectedDate)
        
        info.forEach { section in
            section.mealPlans.forEach { model in
                switch model.type {
                case .plan:
                    if let label = getLabelTitle(labelId: model.mealPlan?.label) {
                        list += label
                    }
                    list += getRecipeTitle(recipeId: model.mealPlan?.recipeId)
                case .note:
                    if let label = getLabelTitle(labelId: model.note?.label) {
                        list += label
                    }
                    list += getNoteTitle(note: model.note)
                default:
                    break
                }
                list += newLine
            }
        }
        
        return list
    }
    
    private func getLabelTitle(labelId: UUID?) -> String? {
        guard let labelId,
              let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString),
              let title = dbLabel.title else {
            return nil
        }
        return title.uppercased() + "\n"
    }
    
    private func getNoteTitle(note: MealPlanNote?) -> String {
        guard let note else {
            return ""
        }
        let newLine = "\n"
        var noteTitle = ""
        
        noteTitle += note.title
        noteTitle += newLine
        
        if let details = note.details {
            noteTitle += details
        }
        
        return noteTitle
    }
    
    private func getRecipeTitle(recipeId: Int?) -> String {
        guard let recipeId,
              let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId) else {
            return ""
        }
        let recipe = ShortRecipeModel(withIngredients: dbRecipe)
        let tab = "  • "
        let newLine = "\n"
        var recipeTitle = ""
        
        recipeTitle += recipe.title.uppercased()
        recipeTitle += newLine
        
        recipe.ingredients?.forEach({ ingredient in
            let title = ingredient.product.title
            recipeTitle += tab + title + newLine
        })
        
        return recipeTitle
    }
    
    @objc
    private func updateDataSource() {
        DispatchQueue.main.async {
            self.updateStorage()
        }
    }
}

extension MealPlanViewModel: MealPlanContextMenuViewDelegate {
    func selectedState(state: MealPlanContextMenuView.MainMenuState) {
        router?.dismissCurrentController()
        
        switch state {
        case .addToShoppingList:
            showAddIngredientsToList()
        case .moveCopyDelete:
            editMode(isEdit: true)
        case .editLabels:
            showLabel()
        case .share:
            sharingTapped()
        case .sendTo:
            router?.showActivityVC(image: [sendToMealPlanByText()])
        }
    }
}
