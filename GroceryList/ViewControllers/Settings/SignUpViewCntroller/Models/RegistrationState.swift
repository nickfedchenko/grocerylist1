//
//  RegistrationState.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.02.2023.
//

import Foundation

enum RegistrationState {
    case signUp
    case signIn
    
    func getTitle() -> String {
        switch self {
        case .signUp:
            return R.string.localizable.singUp()
        case .signIn:
            return R.string.localizable.singIn()
        }
    }
    
    func getHaveAccountTitle() -> String {
        switch self {
        case .signUp:
            return R.string.localizable.iHaveAccount()
        case .signIn:
            return R.string.localizable.iDontHaveAccount()
        }
    }
    
    func isTermsHidden() -> Bool {
        switch self {
        case .signUp:
            return false
        case .signIn:
            return true
        }
    }
}
