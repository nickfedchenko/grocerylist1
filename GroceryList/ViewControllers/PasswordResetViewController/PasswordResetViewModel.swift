//
//  PasswordResetViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.02.2023.
//

import Foundation

protocol PasswordResetViewModelDelegate: AnyObject {
    func setupTextfieldText(text: String)
    func applySecondState()
    func dismissController()
}

class PasswordResetViewModel {
    weak var delegate: PasswordResetViewModelDelegate?
    weak var router: RootRouter?

    var email: String = "" {
        didSet {
            delegate?.setupTextfieldText(text: email)
        }
    }
    private var network: NetworkEngine
    private var isFirstState: Bool = true
    
    init(network: NetworkEngine) {
        self.network = network
    }
    
    func closeButtonPressed() {
        delegate?.dismissController()
    }
    
    func resetButtonPressed(text: String) {
        if isFirstState {
            resetPassword(text: text)
            isFirstState = false
        } else {
            delegate?.dismissController()
        }
 
    }
    
    private func resetPassword(text: String) {
        NetworkEngine().passwordReset(email: text) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print(response)
            }
        }
        applySecondState()
    }
    
    private func applySecondState() {
        delegate?.applySecondState()
    }
}
