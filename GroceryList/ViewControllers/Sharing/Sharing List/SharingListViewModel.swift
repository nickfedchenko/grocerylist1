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
