//
//  SharingListViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.02.2023.
//

import UIKit

struct SharedFriend {
    var photo: UIImage?
    var name: String?
}

protocol SharingListViewModelDelegate: AnyObject {
    func openShareController(with urlToShare: String)
}

final class SharingListViewModel {
    
    weak var router: RootRouter?
    weak var delegate: SharingListViewModelDelegate?
    var necessaryHeight: Double {
        sharedFriends.isEmpty ? 0 : Double(sharedFriends.count * 56 + 32)
    }
    
    var sharedFriendsIsEmpty: Bool {
        sharedFriends.isEmpty
    }
    
    var listToShareModel: GroceryListsModel
    
    private var sharedFriends: [SharedFriend] = []
    private var network: NetworkEngine
    
    init(network: NetworkEngine, listToShare: GroceryListsModel) {
        self.network = network
        self.listToShareModel = listToShare
        print(listToShare)
    }
    
    func shareListTapped() {
        guard let user = UserAccountManager.shared.getUser() else { return }
      
        network.shareGroceryList(userToken: user.token,
                                         listId: nil, listModel: listToShareModel) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                DispatchQueue.main.async { [weak self] in
                    self?.getUrlAndOpenShareController(response: result)
                }
            }
        }
    }
    
    private func getUrlAndOpenShareController(response: ShareGroceryListResponse) {
        let listId = response.groceryListId
        print(listId)
        print(response.sharingToken)
        let start = "groceryList://share?token=" + response.sharingToken
        delegate?.openShareController(with: start)
    }

    func getSection() -> Int {
        return sharedFriendsIsEmpty ? 2 : 3
    }
    
    func getNumberOfRows(inSection: Int) -> Int {
        guard sharedFriendsIsEmpty else {
            return inSection == 1 ? sharedFriends.count : 1
        }
        return 1
    }
    
    func getPhoto(by index: Int) -> UIImage {
        return sharedFriends[safe: index]?.photo ?? UIImage()
    }
    
    func getName(by index: Int) -> String {
        return sharedFriends[safe: index]?.name ?? "-"
    }
}
