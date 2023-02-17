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

final class SharingListViewModel {
    
    weak var router: RootRouter?
    
    private var sharedFriends: [SharedFriend] = []
    
    var necessaryHeight: Double {
        sharedFriends.isEmpty ? 0 : Double(sharedFriends.count * 56 + 32)
    }
    
    var sharedFriendsIsEmpty: Bool {
        sharedFriends.isEmpty
    }
    
    var shareURL: String {
        // TODO: поменять url
        "http://www.codingexplorer.com/"
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
