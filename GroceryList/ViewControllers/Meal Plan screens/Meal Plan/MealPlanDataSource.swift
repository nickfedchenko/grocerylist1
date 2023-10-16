//
//  MealPlanDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.09.2023.
//

import Foundation

class MealPlanDataSource {
    
    enum SortType {
        case month
        case week
    }
    
    var reloadData: (() -> Void)?
    
    private var mealPlan: [MealPlan] = []
    private var note: [MealPlanNote] = []
    private var weekSection: [MealPlanSection] = []
    
    private var sortType: SortType {
        UserDefaultsManager.shared.selectedMonthOrWeek == 0 ? .month : .week
    }
    
    private(set) var section: [MealPlanSection] = []
    private(set) var isEditMode = false
    private(set) var editMealPlan: [MealPlan] = []
    private let network = NetworkEngine()
    init() {
        getMealPlansFromStorage()
        setDefaultLabels()
    }
    
    func getMealPlans(by date: Date) -> [MealPlanSection] {
        guard sortType == .month else {
            section = getMealPlanForWeekState(date: date)
            return section
        }
        
        let mealPlansByDate = mealPlan.filter { $0.date.onlyDate == date.onlyDate }
        let noteByDate = note.filter { $0.date.onlyDate == date.onlyDate }
        let cellModel = mapMealPlanToCellModel(date: date, mealPlan: mealPlansByDate, note: noteByDate, sortType: .month)
        section = [MealPlanSection(sectionType: .month, date: date, mealPlans: cellModel)]
        return section
    }
    
    func getMealPlan(by indexPath: IndexPath) -> MealPlan? {
        section[safe: indexPath.section]?.mealPlans[safe: indexPath.row]?.mealPlan
    }
    
    func getNote(by indexPath: IndexPath) -> MealPlanNote? {
        section[safe: indexPath.section]?.mealPlans[safe: indexPath.row]?.note
    }
    
    func getRecipe(by date: Date, for index: IndexPath) -> ShortRecipeModel? {
        guard let recipeId = getMealPlan(by: date, for: index)?.recipeId,
              let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId) else {
            return nil
        }
        let isFavorite = UserDefaultsManager.shared.favoritesRecipeIds.contains(recipeId)
        return ShortRecipeModel(withCollection: dbRecipe, isFavorite: isFavorite)
    }
    
    func getLabel(by date: Date, for index: IndexPath, type: MealPlanCellType) -> MealPlanLabel? {
        let section = getMealPlans(by: date)
        let item = section[safe: index.section]?.mealPlans[safe: index.row]
        let itemWithLabel: ItemWithLabelProtocol?
        if type == .plan {
            itemWithLabel = item?.mealPlan
        } else if type == .note {
            itemWithLabel = item?.note
        } else {
            return nil
        }
        
        guard let labelId = itemWithLabel?.label,
              let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString) else {
            return nil
        }
        return MealPlanLabel(dbModel: dbLabel)
    }
    
    func getNote(by date: Date, for index: IndexPath) -> MealPlanNote? {
        let section = getMealPlans(by: date)
        return section[safe: index.section]?.mealPlans[safe: index.row]?.note
    }
    
    func getLabelForNote(by date: Date, for index: IndexPath) -> MealPlanLabel? {
        guard let labelId = getNote(by: date, for: index)?.label,
              let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString) else {
            return nil
        }
        return MealPlanLabel(dbModel: dbLabel)
    }
    
    func getLabelColors(by date: Date) -> [Int] {
        let mealPlansByDate: [ItemWithLabelProtocol] = mealPlan.filter { $0.date.onlyDate == date.onlyDate }
        let noteByDate: [ItemWithLabelProtocol] = note.filter { $0.date.onlyDate == date.onlyDate }
        var allLabels: [ItemWithLabelProtocol] = mealPlansByDate + noteByDate
        allLabels.sort { $0.index < $1.index }
        let labels = allLabels.compactMap {
            if let labelId = $0.label,
               let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString) {
                return MealPlanLabel(dbModel: dbLabel)
            } else {
                return MealPlanLabel(defaultLabel: .none)
            }
        }
        
        return labels.compactMap { $0.color }
    }
    
    func updateIndexAfterMove(cellModels: [MealPlanCellModel]) {
        for (newIndex, model) in cellModels.enumerated() {
            if var plan = model.mealPlan {
                plan.index = newIndex
                CoreDataManager.shared.saveMealPlan(plan)
                CloudManager.shared.saveCloudData(mealPlan: plan)
            }
            if var note = model.note {
                note.index = newIndex
                CoreDataManager.shared.saveMealPlanNote(note)
                CloudManager.shared.saveCloudData(mealPlanNote: note)
            }
        }
    }
    
    func updateEditMode(isEdit: Bool) {
        isEditMode = isEdit
    }
    
    func updateEditMealPlan(_ mealPlanCellModel: MealPlanCellModel) {
        guard let mealPlan = mealPlanCellModel.mealPlan else {
            return
        }
        if editMealPlan.contains(where: { $0.id == mealPlan.id }) {
            editMealPlan.removeAll { $0.id == mealPlan.id }
            return
        }
        editMealPlan.append(mealPlan)
    }
    
    func isSelectedMealPlanForEditing(_ mealPlan: MealPlan) -> Bool {
        return editMealPlan.contains(where: { $0.id == mealPlan.id })
    }
    
    func addEditAllMealPlans() {
        editMealPlan.removeAll()
        editMealPlan = mealPlan
    }
    
    func copyEditMealPlans(date: Date) {
        editMealPlan.forEach {
            let updatePlan = MealPlan(copy: $0, date: date)
            CoreDataManager.shared.saveMealPlan(updatePlan)
            CloudManager.shared.saveCloudData(mealPlan: updatePlan)
        }
    }
    
    func deleteEditMealPlans() {
        editMealPlan.forEach {
            delete(mealPlan: $0)
        }
        editMealPlan.removeAll()
    }
    
    func delete(mealPlan: MealPlan) {
        CoreDataManager.shared.deleteMealPlan(by: mealPlan.id)
        CloudManager.shared.delete(recordType: .mealPlan, recordID: mealPlan.recordId)
        reloadData?()
    }
    
    func resetEditMealPlans() {
        editMealPlan.removeAll()
    }
    
    func getMealPlansFromStorage() {
        mealPlan = CoreDataManager.shared.getAllMealPlans()?.map({ MealPlan(dbModel: $0) }) ?? []
        note = CoreDataManager.shared.getMealPlanNotes()?.map({ MealPlanNote(dbModel: $0) }) ?? []
        
        DispatchQueue.main.async {
            var section: [MealPlanSection] = []
            let dates = Date().after(dayCount: -365).getDates(by: Date().after(dayCount: 365))
            dates.forEach { date in
                let type: MealPlanSectionType
                type = date.onlyDate == date.startOfWeek.onlyDate ? .weekStart : .week
                var mealPlansByDate = self.mealPlan.filter { $0.date.onlyDate == date.onlyDate }
                let noteByDate = self.note.filter { $0.date.onlyDate == date.onlyDate }
                if mealPlansByDate.isEmpty {
                    mealPlansByDate.append(MealPlan(date: date))
                }
                let cellModel = self.mapMealPlanToCellModel(date: date, mealPlan: mealPlansByDate,
                                                            note: noteByDate, sortType: .week)
                section.append(MealPlanSection(sectionType: type, date: date, mealPlans: cellModel))
            }
            self.weekSection = section
            if self.sortType == .week {
                self.reloadData?()
            }
        }
    }
    
    func getMealPlanForSharing(date: Date, mealListId: String, completion: @escaping ((MealList) -> Void)) {
        let mealPlansByDate = self.mealPlan.filter { $0.date.onlyDate >= date.onlyDate }
        
        let notesByDate = self.note.filter { $0.date.onlyDate >= date.onlyDate }
        let noteForSharing = notesByDate.compactMap {
            SharedNote(note: $0)
        }
        
        getSharedMealPlan(mealPlansByDate: mealPlansByDate) { mealPlanForSharing in
            let mealList = MealList(mealListId: mealListId, startDate: date.onlyDate.toString(),
                                    plans: mealPlanForSharing, notes: noteForSharing)
            completion(mealList)
        }
    }
    
    private func getSharedMealPlan(mealPlansByDate: [MealPlan], completion: @escaping (([SharedMealPlan]) -> Void)) {
        let imageGroup = DispatchGroup()
        var mealPlanForSharing = Set<SharedMealPlan>()
        var updatedRecipe = Set<Recipe>()
        
        mealPlansByDate.forEach { mealPlan in
            if let dbRecipe = CoreDataManager.shared.getRecipe(by: mealPlan.recipeId),
               var localRecipe = Recipe(from: dbRecipe) {
                
                let ifNeededUploadImage = self.ifNeededUploadImage(recipe: localRecipe)
                if URL(string: localRecipe.photo) == nil, let localImage = localRecipe.localImage {
                    imageGroup.enter()
                    uploadImage(imageData: localImage) { uploadImageResponse in
                        imageGroup.leave()
                        localRecipe.photo = uploadImageResponse.data.url
                        updatedRecipe.insert(localRecipe)
                        mealPlanForSharing.insert(SharedMealPlan(id: mealPlan.id.uuidString, date: mealPlan.date.toString(),
                                                                 recipe: RecipeForSharing(fromRecipe: localRecipe)))
                    }
                }
                for (index, ingredient) in localRecipe.ingredients.enumerated() {
                    if URL(string: ingredient.product.photo) == nil, let localImage = ingredient.product.localImage {
                        imageGroup.enter()
                        uploadImage(imageData: localImage) { uploadImageResponse in
                            imageGroup.leave()
                            localRecipe.ingredients[index].product.photo = uploadImageResponse.data.url
                            updatedRecipe.insert(localRecipe)
                            mealPlanForSharing.insert(SharedMealPlan(id: mealPlan.id.uuidString, date: mealPlan.date.toString(),
                                                                     recipe: RecipeForSharing(fromRecipe: localRecipe)))
                        }
                    }
                }
                
                if !ifNeededUploadImage {
                    mealPlanForSharing.insert(SharedMealPlan(id: mealPlan.id.uuidString, date: mealPlan.date.toString(),
                                                             recipe: RecipeForSharing(fromRecipe: localRecipe)))
                }
            }
        }
        
        imageGroup.notify(queue: .main) {
            CoreDataManager.shared.saveRecipes(recipes: Array(updatedRecipe))
            completion(Array(mealPlanForSharing))
        }
    }
    
    private func ifNeededUploadImage(recipe: Recipe) -> Bool {
        if URL(string: recipe.photo) == nil,
           recipe.localImage != nil {
            return true
        }
        
        for ingredient in recipe.ingredients {
            if URL(string: ingredient.product.photo) == nil,
                ingredient.product.localImage != nil {
                return true
            }
        }
        
        return false
    }
    
    private func uploadImage(imageData: Data, completion: @escaping ((UploadImageResponse) -> Void)) {
        network.uploadImage(imageData: imageData) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let success):
                completion(success)
            }
        }
    }
    
    private func getMealPlan(by date: Date, for index: IndexPath) -> MealPlan? {
        let section = getMealPlans(by: date)
        return section[safe: index.section]?.mealPlans[safe: index.row]?.mealPlan
    }
    
    private func getMealPlanForWeekState(date: Date) -> [MealPlanSection] {
        guard weekSection.isEmpty else {
            return weekSection.filter { $0.date.onlyDate >= date.onlyDate }
        }
        
        var section: [MealPlanSection] = []
        
        let dates = date.getDates(by: date.after(dayCount: 50))
        dates.forEach { date in
            let type: MealPlanSectionType
            type = date.onlyDate == date.startOfWeek.onlyDate ? .weekStart : .week
            var mealPlansByDate = mealPlan.filter { $0.date.onlyDate == date.onlyDate }
            let noteByDate = note.filter { $0.date.onlyDate == date.onlyDate }
            if mealPlansByDate.isEmpty {
                mealPlansByDate.append(MealPlan(date: date))
            }
            let cellModel = mapMealPlanToCellModel(date: date, mealPlan: mealPlansByDate, note: noteByDate, sortType: .week)
            section.append(MealPlanSection(sectionType: type, date: date, mealPlans: cellModel))
        }
        return section
    }
    
    private func mapMealPlanToCellModel(date: Date, mealPlan: [MealPlan], note: [MealPlanNote], sortType: SortType) -> [MealPlanCellModel] {
        var cellModels: [MealPlanCellModel] = []
        guard sortType == .month else {
            cellModels = mealPlan.map {
                MealPlanCellModel(type: .plan, date: date, index: $0.index, mealPlan: $0,
                                  isEdit: isEditMode, isSelectedEditMode: isSelectedMealPlanForEditing($0))
            }
            note.forEach {
                cellModels.append(MealPlanCellModel(type: .note, date: date, index: $0.index, note: $0))
            }
            
            cellModels.sort { $0.index < $1.index }
            return cellModels
        }
        
        if mealPlan.isEmpty {
            cellModels = [MealPlanCellModel(type: .planEmpty, date: date, index: -100)]
        } else {
            cellModels = mealPlan.map {
                MealPlanCellModel(type: .plan, date: date, index: $0.index, mealPlan: $0,
                                  isEdit: isEditMode, isSelectedEditMode: isSelectedMealPlanForEditing($0))
            }
        }
        
        if note.isEmpty {
            cellModels.append(MealPlanCellModel(type: .noteEmpty, date: date, index: 100))
        } else {
            note.forEach {
                cellModels.append(MealPlanCellModel(type: .note, date: date, index: $0.index, note: $0))
            }
            cellModels.append(MealPlanCellModel(type: .noteFilled, date: date, index: 100))
        }
        cellModels.sort { $0.index < $1.index }
        return cellModels
    }
    
    private func setDefaultLabels() {
        guard !UserDefaultsManager.shared.isFillingDefaultLabels else {
            return
        }
        var labels: [MealPlanLabel] = []
        DefaultLabel.allCases.forEach {
            labels.append(MealPlanLabel(defaultLabel: $0))
        }
        CoreDataManager.shared.saveLabel(labels)
        labels.forEach {
            CloudManager.shared.saveCloudData(mealPlanLabel: $0)
        }
        UserDefaultsManager.shared.isFillingDefaultLabels = true
    }
}

enum DefaultLabel: Int, CaseIterable {
    case none
    case breakfast
    case lunch
    case dinner
    case snack
    
    var id: UUID {
        self.rawValue.asUUID
    }
    
    var title: String {
        switch self {
        case .none:         return "DefaultLabel_none"
        case .breakfast:    return "DefaultLabel_breakfast"
        case .lunch:        return "DefaultLabel_lunch"
        case .dinner:       return "DefaultLabel_dinner"
        case .snack:        return "DefaultLabel_snack"
        }
    }
    
    var color: Int {
        switch self {
        case .none:         return 0
        case .breakfast:    return 7
        case .lunch:        return 4
        case .dinner:       return 9
        case .snack:        return 1
        }
    }
}
