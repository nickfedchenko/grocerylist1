//
//  PantryListOptionViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.06.2023.
//

import UIKit

class PantryListOptionViewController: ProductsSettingsViewController {
    
    init(viewModel: PantryListOptionViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.delegate = self
    }

}
