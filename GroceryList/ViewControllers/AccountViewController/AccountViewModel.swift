//
//  AccountViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.02.2023.
//

import Foundation

protocol AccountViewModelDelegate: AnyObject {
    func showLogOut()
}

class AccountViewModel {
    weak var delegate: AccountViewModelDelegate?
    weak var router: RootRouter?
    
    func backButtonPressed() {
        router?.pop()
    }
    
    func deleteAccountPressed() {
        print("deleteAccountPressed")
    }
    
    func logOutPressed() {
        delegate?.showLogOut()
    }
    
    func logOutInPopupPressed() {
        UserAccountManager.shared.deleteUser()
        router?.popToRoot()
    }
}
