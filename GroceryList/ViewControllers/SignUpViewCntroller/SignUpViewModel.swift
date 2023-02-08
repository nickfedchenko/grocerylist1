//
//  SignUpViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.02.2023.
//

import Foundation

protocol SignUpViewModelDelegate: AnyObject {

}

class SignUpViewModel {
    weak var delegate: SignUpViewModelDelegate?
    weak var router: RootRouter?
}
