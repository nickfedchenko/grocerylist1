//
//  SharingListViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.02.2023.
//

import UIKit

struct SharedUser {
    let id: Int
    var photo: UIImage
    var name: String?
}

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
    
    var listToShareModel: GroceryListsModel
    
    private var sharedUsers: [User] = []
    private var network: NetworkEngine
    
    init(network: NetworkEngine, listToShare: GroceryListsModel, users: [User]) {
        self.network = network
        self.listToShareModel = listToShare
        sharedUsers = users
        print(listToShare)
        sharedUsers.removeAll(where: { $0.token == UserAccountManager.shared.getUser()?.token })
    }
    
    func shareListTapped() {
        SharedListManager.shared.shareGroceryList(listModel: listToShareModel) { [weak self] deepLink in
            DispatchQueue.main.async {
                self?.delegate?.openShareController(with: deepLink)
            }
        }
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
      //  return sharedUsers[safe: index]?.photo ?? UIImage()
    }
    
    func getName(by index: Int) -> String {
        guard let user = sharedUsers[safe: index] else {
            return "-"
        }
        return user.username ?? user.email
    }
}
