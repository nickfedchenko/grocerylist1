//
//  ProductsViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import SnapKit
import UIKit

class ProductsViewController: UIViewController {
    
    var viewModel: ProductsViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupController()
    }
    
    private func setupController() {
        nameOfListLabel.text = viewModel?.getNameOfList()
        view.backgroundColor = viewModel?.getColorForBackground()
        addItemView.backgroundColor = viewModel?.getAddItemViewColor()
        nameOfListLabel.textColor = viewModel?.getAddItemViewColor()
    }
    
    deinit {
        print("ProductView deinited")
    }
    
    @objc
    private func arrowBackButtonPressed() {
        viewModel?.goBackButtonPressed()
    }
    
    @objc
    private func contextMenuButtonPressed() {
        
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
    
    private let nameOfListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        return label
    }()
    
    private lazy var contextMenuButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(contextMenuButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "contextMenu"), for: .normal)
        return button
    }()
    
    private let addItemView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 32
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner]
        return view
    }()
    
    private let plusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "whitePlusImage")
        return imageView
    }()
    
    private let addItemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = .white
        label.text = "AddItem".localized
        return label
    }()
    
    // MARK: - Constraints

    private func setupConstraints() {
        view.addSubviews([navigationView, addItemView])
        navigationView.addSubviews([arrowBackButton, nameOfListLabel, contextMenuButton])
        addItemView.addSubviews([plusImage, addItemLabel])
        
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
        
        nameOfListLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        contextMenuButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(26)
            make.width.equalTo(28)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        addItemView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(82)
            make.width.equalTo(207)
        }
        
        plusImage.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
        }
        
        addItemLabel.snp.makeConstraints { make in
            make.left.equalTo(plusImage.snp.right).inset(-16)
            make.centerY.equalTo(plusImage)
        }
    }
}
