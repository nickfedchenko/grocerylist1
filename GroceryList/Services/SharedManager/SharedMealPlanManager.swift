//
//  SharedMealPlanManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.10.2023.
//

import Foundation
import Kingfisher

class SharedMealPlanManager {
    
    static let shared = SharedMealPlanManager()
    weak var router: RootRouter?
    var sharedMealPlanUsers: [String: [User]] = [:]
    var allUsers: [User] {
        sharedMealPlanUsers.flatMap { $1 }
    }
    
    private let network = NetworkEngine()
    private var tokens: [String] {
        get { UserDefaultsManager.shared.mealPlanUserTokens ?? [] }
        set { UserDefaultsManager.shared.mealPlanUserTokens = newValue }
    }
    
    private init() { }
    
    /// делимся ссылкой на мил план
    func shareMealPlan(mealPlans: MealList, compl: ((String) -> Void)?) {
        guard let user = UserAccountManager.shared.getUser() else {
            return
        }
        
        network.shareMealPlan(userToken: user.token, mealList: mealPlans) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                let deepLinkToken = response.url
                compl?(deepLinkToken)
                self?.fetchMyMealPlans()
            }
        }
    }

    /// получаем токен и обрабатываем событие
    func gottenDeeplinkToken(token: String) {
        tokens.append(token)
        if let user = UserAccountManager.shared.getUser() {
            connectToMealPlan(userToken: user.token, token: token)
        } else {
            router?.goToSharingPopUp()
        }
    }

    func connectToListAfterRegistration() {
        if let user = UserAccountManager.shared.getUser() {
            fetchMyMealPlans()
            tokens.forEach {
                connectToMealPlan(userToken: user.token, token: $0)
            }
        }
    }
    
    /// получаем список листов на которые подписаны
    func fetchMyMealPlans() {
        guard let user = UserAccountManager.shared.getUser() else {
            return
        }
        network.fetchMyMealPlans(userToken: user.token) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                self.transformSharedModelsToLocal(response: response)
            }
        }
    }

    /// сохранение листа из сокета
    func saveListFromSocket(response: SocketMealPlanResponse) {
        if !response.listUsers.contains(where: { $0.token == UserAccountManager.shared.getUser()?.token }) {
            CoreDataManager.shared.removeSharedMealPlan(by: response.listId, isOwner: false)
            CoreDataManager.shared.removeSharedMealPlanNote(by: response.listId, isOwner: false)
            CoreDataManager.shared.removeMealListSharedInfo(mealListId: response.listId)
            sharedMealPlanUsers.removeValue(forKey: response.listId)
            NotificationCenter.default.post(name: .sharedMealPlanDownloadedAndSaved, object: nil)
            return
        }
        
        appendToUsersDict(id: response.listId, users: response.listUsers)
        response.mealList.forEach { mealList in
            saveMealList(mealList: mealList, mealListId: response.listId)
        }
        NotificationCenter.default.post(name: .sharedMealPlanDownloadedAndSaved, object: nil)
    }
    
    /// удаление листа из сокета
    func deleteListFromSocket(response: SocketDeleteResponse) {
        CoreDataManager.shared.removeSharedMealPlan(by: response.listId)
        NotificationCenter.default.post(name: .sharedMealPlanDownloadedAndSaved, object: nil)
    }
    
    ///  обновление Meal plan-а
    func updateMealPlan(mealPlans: MealList) {
        guard let user = UserAccountManager.shared.getUser(),
              CoreDataManager.shared.getMealListSharedInfo() != nil else {
            return
        }

        network.updateMealPlan(userToken: user.token,
                               mealList: mealPlans) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let result):
                print(result)
            }
        }
    }

    /// подписываемся на лист
    private func connectToMealPlan(userToken: String, token: String) {
        network.mealPlanRelease(userToken: userToken, sharingToken: token) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                print(result)
                DispatchQueue.main.async { [weak self] in
                    self?.fetchMyMealPlans()
                }
            }
        }
    }
    
    /// отписка юзера от мил плана
    func mealPlanUserDelete(user: User, completion: @escaping ShareSuccessResult) {
        let listIds = sharedMealPlanUsers.compactMap { id, users in
            return users.contains { $0 == user } ? id : nil
        }
        listIds.forEach { mealListId in
            network.mealPlanUserDelete(userToken: user.token, mealListId: mealListId) { result in
                completion(result)
            }
        }
    }
    
    private func transformSharedModelsToLocal(response: FetchMyMealPlansResponse) {
        response.items.forEach { sharedModel in
            appendToUsersDict(id: sharedModel.mealListId, users: sharedModel.users)
            let date = sharedModel.createdAt.toDate()?.onlyDate
            CoreDataManager.shared.saveMealListSharedInfo(mealListId: sharedModel.mealListId,
                                                          createdAt: date ?? Date(),
                                                          isOwner: sharedModel.isOwner)
            sharedModel.mealLists.forEach { mealList in
                saveMealList(mealList: mealList, mealListId: sharedModel.mealListId)
            }
        }

        NotificationCenter.default.post(name: .sharedMealPlanDownloadedAndSaved, object: nil)
    }
    
    private func saveMealList(mealList: MealList, mealListId: String) {
        var mealLists: [MealPlan] = []
        var notes: [MealPlanNote] = []
        
        mealList.plans.forEach { sharedMealPlan in
            var recipe = Recipe(sharedRecipe: sharedMealPlan.recipe)
            if let dbRecipe = CoreDataManager.shared.getRecipe(by: sharedMealPlan.recipe.id) {
                recipe.dishWeightType = dbRecipe.dishWeightType < 0 ? nil : Int(dbRecipe.dishWeightType)
                recipe.countries = (try? JSONDecoder().decode([String].self, from: dbRecipe.countries ?? Data())) ?? []
                recipe.isDraft = dbRecipe.isDraft
                recipe.isDefaultRecipe = dbRecipe.isDefaultRecipe
                recipe = updatedIngredients(recipe: recipe, dbRecipe: dbRecipe)
            }
            CoreDataManager.shared.saveRecipes(recipes: [recipe])
            
            var mealPlan = MealPlan(sharedModel: sharedMealPlan)
            let dbMealPlan = CoreDataManager.shared.getMealPlan(id: sharedMealPlan.id)
            mealPlan.label = dbMealPlan?.label
            mealPlan.destinationListId = dbMealPlan?.destinationListId
            mealPlan.index = Int(dbMealPlan?.index ?? 0)
            mealPlan.isOwner = dbMealPlan?.isOwner ?? false
            mealPlan.sharedId = mealListId
            mealLists.append(mealPlan)
        }
        
        mealList.notes.forEach { sharedMealPlanNote in
            let dbNote = CoreDataManager.shared.getMealPlanNote(id: sharedMealPlanNote.id)
            var note = MealPlanNote(sharedModel: sharedMealPlanNote)
            note.label = dbNote?.label
            note.index = Int(dbNote?.index ?? 0)
            note.isOwner = dbNote?.isOwner ?? false
            note.sharedId = mealListId
            notes.append(note)
        }
        
        CoreDataManager.shared.removeSharedMealPlan(by: mealListId)
        CoreDataManager.shared.removeSharedMealPlanNote(by: mealListId)
        
        mealLists.forEach { mealPlan in
            CoreDataManager.shared.saveMealPlan(mealPlan)
        }
        
        notes.forEach { note in
            CoreDataManager.shared.saveMealPlanNote(note)
        }
    }

    private func updatedIngredients(recipe: Recipe, dbRecipe: DBRecipe) -> Recipe {
        let dbIngredients = (try? JSONDecoder().decode([Ingredient].self, from: dbRecipe.ingredients ?? Data())) ?? []
        guard !dbIngredients.isEmpty else {
            return recipe
        }
        var recipe = recipe
        dbIngredients.forEach { dbIngredient in
            if let index = recipe.ingredients.firstIndex(where: { $0.id == dbIngredient.id }) {
                recipe.ingredients[index].product.localImage = dbIngredient.product.localImage
            }
        }
        return recipe
    }
    
    private func appendToUsersDict(id: String, users: [User]) {
        sharedMealPlanUsers[id] = users
        DispatchQueue.global().async {
            users.forEach {
                if let stringUrl = $0.avatar,
                   let url = URL(string: stringUrl) {
                    _ = Kingfisher.ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                }
            }
        }
    }
}
