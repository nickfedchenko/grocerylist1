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
   //     self.navigationController?.navigationBar.barStyle = .default
        setupConstraints()
        setupController()
    }
    
    deinit {
        print("select category deinited ")
    }
    
    private func setupController() {
        view.backgroundColor = viewModel?.getBackgroundColor()
        titleCenterLabel.textColor = viewModel?.getForegroundColor()
    }
    
    @objc
    private func arrowBackButtonPressed() {
        
    }
    
    @objc
    private func addButtonPressed() {
        
    }
    
    // MARK: - UI
    
    private let navigationView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var arrowBackButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(arrowBackButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "greenArrowBack"), for: .normal)
        return button
    }()
    
    private let titleCenterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.text = "SelectCategory".localized
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "greenPlus"), for: .normal)
        return button
    }()
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        view.addSubviews([navigationView])
        navigationView.addSubviews([arrowBackButton, titleCenterLabel, addButton])
        
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.right.left.equalToSuperview()
            make.height.equalTo(66)
        }
        
        arrowBackButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalToSuperview()
            make.width.equalTo(17)
            make.height.equalTo(24)
        }
        
        titleCenterLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(26)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
}

extension SelectCategoryViewController: SelectCategoryViewModelDelegate {

}
