//
//  AccountViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.02.2023.
//

import Foundation

protocol AccountViewModelDelegate: AnyObject {
    func showLogOut()
    func showDeleteAccount()
}

class AccountViewModel {
    weak var delegate: AccountViewModelDelegate?
    weak var router: RootRouter?
    
    private var network: NetworkEngine
    
    init(network: NetworkEngine) {
        self.network = network
    }
    
    func backButtonPressed() {
        router?.pop()
    }
    
    func deleteAccountPressed() {
        delegate?.showDeleteAccount()
    }
    
    func logOutPressed() {
        delegate?.showLogOut()
    }
    
    func logOutInPopupPressed() {
        UserAccountManager.shared.deleteUser()
        CoreDataManager.shared.removeSharedLists()
        router?.popToRoot()
    }
    
    func deleteInPopupPressed() {
        guard let user = UserAccountManager.shared.getUser() else { return }
        let userToken = user.token
        network.deleteUser(userToken: userToken) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print(response)
            }
        }
        UserAccountManager.shared.deleteUser()
        CoreDataManager.shared.removeSharedLists()
        router?.popToRoot()
    }
}
