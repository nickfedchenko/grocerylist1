//
//  SelectCategoryViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import SnapKit
import UIKit

class SelectCategoryViewController: UIViewController {
    
    var viewModel: SelectCategoryViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupController()
    }
    
    deinit {
        print("create new list deinited")
    }
    
    private func setupController() {
        
    }
    
    // MARK: - UI
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        
    }
}

extension SelectCategoryViewController: SelectCategoryViewModelDelegate {

}
