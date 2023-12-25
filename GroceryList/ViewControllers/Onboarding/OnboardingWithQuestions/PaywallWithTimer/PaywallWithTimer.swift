//
//  PaywallWithTimer.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 25.12.2023.
//

import UIKit

class PaywallWithTimer: UIViewController {
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCallbacks()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        configureView()
        addSubViews()
        setupConstraints()
    }
    
    private func configureCallbacks() {

    }
    
    private func configureView() {
        view.backgroundColor = .blue
    }
    
    private func addSubViews() {

    }

}

// MARK: - Constraints
extension PaywallWithTimer {
    private func setupConstraints() {
  
    }
}
