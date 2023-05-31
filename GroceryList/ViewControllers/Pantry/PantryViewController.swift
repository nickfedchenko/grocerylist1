//
//  PantryViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.05.2023.
//

import UIKit

final class PantryViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    private var viewModel: PantryViewModel
    
    init(viewModel: PantryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = R.color.background()
    }
    
}
