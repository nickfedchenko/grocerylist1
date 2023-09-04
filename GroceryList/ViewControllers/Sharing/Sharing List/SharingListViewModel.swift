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
    
    private var sharedUsers: [User] = []
    private var network: NetworkEngine
    
    init(network: NetworkEngine, users: [User]) {
        self.network = network
        sharedUsers = users
        sharedUsers.removeAll(where: { $0.token == UserAccountManager.shared.getUser()?.token })
    }
    
    func shareListTapped() {
        if let listToShareModel {
            shareGrocery(listToShareModel: listToShareModel)
            return
        }
        if let pantryToShareModel {
            sharePantry(pantryToShareModel: pantryToShareModel)
            return
        }
    }
    
    func showCustomReview() {
        router?.goReviewController()
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
        router?.goToStopSharingPopUp(user: user, listToShareModel: listToShareModel,
                                     pantryToShareModel: pantryToShareModel, updateUI: { [weak self] isStop in
            guard isStop else { return }
            guard let self else { return }
            self.deleteUserGrocery(user: user, index: index)
            self.deleteUserPantry(user: user, index: index)
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
    
    private func shareGrocery(listToShareModel: GroceryListsModel) {
        idsOfChangedLists.insert(listToShareModel.id)
        AmplitudeManager.shared.logEvent(.sendInvite)
        SharedListManager.shared.shareGroceryList(listModel: listToShareModel) { [weak self] deepLink in
            DispatchQueue.main.async {
                self?.delegate?.openShareController(with: deepLink)
            }
        }
    }
    
    private func sharePantry(pantryToShareModel: PantryModel) {
        SharedPantryManager.shared.sharePantry(pantry: pantryToShareModel) { [weak self] deepLink in
            DispatchQueue.main.async {
                self?.delegate?.openShareController(with: deepLink)
            }
        }
    }
}
