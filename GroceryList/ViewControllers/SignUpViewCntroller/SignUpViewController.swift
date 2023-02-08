//
//  SignUpViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.02.2023.
//

import UIKit

class SignUpViewController: UIViewController {
    
    var viewModel: SignUpViewModel?
    
    // MARK: - Lifecycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        setupNavigationBar(titleText: "fdfdf")
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    deinit {
        print("SignUpViewController deinited")
    }
    
    
}

extension SignUpViewController: SignUpViewModelDelegate {

}
