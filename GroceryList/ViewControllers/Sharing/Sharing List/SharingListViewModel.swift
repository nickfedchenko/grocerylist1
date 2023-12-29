//
//  SharingListViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.02.2023.
//

import UIKit

protocol SharingListViewModelDelegate: AnyObject {
    func openShareController(with urlToShare: String)
}

final class SharingListViewModel {
    
    enum State {
        case grocery
        case pantry
        case mealPlan
    }
    
    weak var router: RootRouter?
    weak var delegate: SharingListViewModelDelegate?
    var updateUsers: (() -> Void)?
    
    var necessaryHeight: Double {
        sharedUsers.isEmpty ? 0 : Double(sharedUsers.count * 56 + 32)
    }
    
    var sharedFriendsIsEmpty: Bool {
        sharedUsers.isEmpty
    }
    
    var listToShareModel: GroceryListsModel?
    var pantryToShareModel: PantryModel?
    var mealPlansToShare: MealList?
    
    private var sharedUsers: [User] = []
    private var network: NetworkEngine
    private let state: State
    private var gotShareLink = false
    
    init(network: NetworkEngine, state: State, users: [User]) {
        self.network = network
        self.state = state
        sharedUsers = users
        sharedUsers.removeAll(where: { $0.token == UserAccountManager.shared.getUser()?.token })
    }
    
    func shareListTapped() {
        switch state {
        case .grocery:
            if let listToShareModel {
                shareGrocery(listToShareModel: listToShareModel)
                return
            }
        case .pantry:
            if let pantryToShareModel {
                sharePantry(pantryToShareModel: pantryToShareModel)
                return
            }
        case .mealPlan:
            if let mealPlansToShare {
                shareMealPlan(mealPlansToShare: mealPlansToShare)
                return
            }
        }
    }
    
    func showCustomReview() {
        guard gotShareLink else {
            return
        }
        RateUsReachability.shared.listShared(router: router)
    }
    
    func getSection() -> Int {
        return sharedFriendsIsEmpty ? 2 : 3
    }
    
    func getNumberOfRows(inSection: Int) -> Int {
        guard sharedFriendsIsEmpty else {
            return inSection == 1 ? sharedUsers.count : 1
        }
        return 1
    }
    
    func getPhoto(by index: Int) -> String? {
        return sharedUsers[index].avatar
    }
    
    func getName(by index: Int) -> String {
        guard let user = sharedUsers[safe: index] else {
            return "-"
        }
        return user.username ?? user.email
    }
    
    func showStopSharingPopUp(by index: Int) {
        let user = sharedUsers[index]
        router?.goToStopSharingPopUp(user: user, state: state, listToShareModel: listToShareModel,
                                     pantryToShareModel: pantryToShareModel, updateUI: { [weak self] isStop in
            guard isStop, let self else { return }
            switch self.state {
            case .grocery:
                self.deleteUserGrocery(user: user, index: index)
            case .pantry:
                self.deleteUserPantry(user: user, index: index)
            case .mealPlan:
                self.deleteUserMealPlan(user: user, index: index)
            }
        })
    }
    
    private func deleteUserGrocery(user: User, index: Int) {
        guard let grocery = listToShareModel else {
            return
        }
        self.network.groceryListUserDelete(userToken: user.token,
                                           listId: grocery.sharedId) {  result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                guard result.error else {
                    self.sharedUsers.remove(at: index)
                    self.updateUsers?()
                    return
                }
                print(result)
                guard let messages = result.messages.first else {
                    return
                }
                if messages == "Owner can not delete yourself" {
                    self.router?.showAlertVC(title: "", message: R.string.localizable.youCannotRemoveOwner())
                } else {
                    self.router?.showAlertVC(title: "Error", message: messages)
                }
            }
        }
    }
    
    private func deleteUserPantry(user: User, index: Int) {
        guard let pantry = pantryToShareModel else {
            return
        }
        self.network.pantryListUserDelete(userToken: user.token,
                                          pantryId: pantry.sharedId) {  result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                guard result.error else {
                    self.sharedUsers.remove(at: index)
                    self.updateUsers?()
                    return
                }
                print(result)
                guard let messages = result.messages.first else {
                    return
                }
                if messages == "Owner can not delete yourself" {
                    self.router?.showAlertVC(title: "", message: R.string.localizable.youCannotRemoveOwner())
                } else {
                    self.router?.showAlertVC(title: "Error", message: messages)
                }
            }
        }
    }
    
    private func deleteUserMealPlan(user: User, index: Int) {
        guard CoreDataManager.shared.getMealListSharedInfo() != nil else {
            return
        }
        
        SharedMealPlanManager.shared.mealPlanUserDelete(user: user) { result in
            switch result {
            case .failure(let error):
                print(error)
                self.router?.showAlertVC(title: R.string.localizable.error(), message: "")
            case .success(let result):
                guard result.error else {
                    self.sharedUsers.remove(at: index)
                    self.updateUsers?()
                    return
                }
                print(result)
                guard let messages = result.messages.first else {
                    return
                }
                if messages == "Owner can not delete yourself" {
                    self.router?.showAlertVC(title: "", message: R.string.localizable.youCannotRemoveOwner())
                } else {
                    self.router?.showAlertVC(title: R.string.localizable.error(), message: messages)
                }
            }
        }
    }
    
    private func shareGrocery(listToShareModel: GroceryListsModel) {
        idsOfChangedLists.insert(listToShareModel.id)
        AmplitudeManager.shared.logEvent(.sendInvite)
        SharedListManager.shared.shareGroceryList(listModel: listToShareModel) { [weak self] deepLink in
            self?.gotShareLink = true
            DispatchQueue.main.async {
                self?.delegate?.openShareController(with: deepLink)
            }
        }
    }
    
    private func sharePantry(pantryToShareModel: PantryModel) {
        SharedPantryManager.shared.sharePantry(pantry: pantryToShareModel) { [weak self] deepLink in
            self?.gotShareLink = true
            DispatchQueue.main.async {
                self?.delegate?.openShareController(with: deepLink)
            }
        }
    }
    
    private func shareMealPlan(mealPlansToShare: MealList) {
        SharedMealPlanManager.shared.shareMealPlan(mealPlans: mealPlansToShare) { [weak self] deepLink in
            self?.gotShareLink = true
            DispatchQueue.main.async {
                self?.delegate?.openShareController(with: deepLink)
            }
        }
    }
}
