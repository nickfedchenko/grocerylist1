//
//  StopSharingPopUpViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 04.09.2023.
//

import UIKit

class StopSharingPopUpViewController: UIViewController {

    private let viewModel: StopSharingViewModel
    
    private let pantryView = PantryView()
    private let groceryView = GroceryView()
    private let popUpView = StopSharingPopUpView()
    
    init(viewModel: StopSharingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
        makeConstraints()
        setupPopUpView()
        
        if let grocery = viewModel.listToShareModel {
            groceryView.configureList(grocery)
            pantryView.isHidden = true
        } else if let pantry = viewModel.getPantry() {
            pantryView.configure(pantry)
            groceryView.isHidden = true
        }
    }
    
    private func setupPopUpView() {
        popUpView.configureUser(viewModel.user)
        
        popUpView.stopSharing = { [weak self] in
            self?.viewModel.stopSharing()
            self?.dismiss(animated: true)
        }
        
        popUpView.cancel = { [weak self] in
            self?.viewModel.cancel()
            self?.dismiss(animated: true)
        }
    }

    private func makeConstraints() {
        self.view.addSubviews([popUpView, pantryView, groceryView])

        pantryView.snp.makeConstraints {
            $0.leading.trailing.equalTo(popUpView)
            $0.height.equalTo(96)
            $0.bottom.equalTo(popUpView.snp.top).offset(20)
        }

        groceryView.snp.makeConstraints {
            $0.leading.trailing.equalTo(popUpView)
            $0.height.equalTo(72)
            $0.bottom.equalTo(popUpView.snp.top).offset(12)
        }

        popUpView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(210)
        }
    }
}
