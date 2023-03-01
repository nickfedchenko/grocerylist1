//
//  CreateNewRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.03.2023.
//

import UIKit

class CreateNewRecipeViewController: UIViewController {
    
    var viewModel: CreateNewRecipeViewModel?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    private lazy var navigationView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.greenArrowBack(), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = UIColor(hex: "#1A645A")
        label.text = R.string.localizable.recipes()
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.backgroundColor = UIColor(hex: "#E5F5F3")
        makeConstraints()
    }
    
    @objc
    private func backButtonTapped() {
        viewModel?.back()
    }
    
    private func makeConstraints() {
        self.view.addSubviews([scrollView, navigationView])
        self.scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        navigationView.addSubviews([backButton, backLabel])
        
        navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(40)
        }
        
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navigationView.snp.bottom)
            $0.width.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        backLabel.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
        }
        
    }
}
