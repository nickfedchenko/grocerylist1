//
//  AllRecipesCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.03.2023.
//

import UIKit

final class AllRecipesCell: UICollectionViewCell {
    
    var searchAllRecipe: (() -> Void)?
    
    private lazy var allRecipeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#F2FAF9")
        button.setTitle("Search in all recipes", for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 16).font
        button.setTitleColor(R.color.primaryDark(), for: .normal)
        button.addTarget(self, action: #selector(allRecipeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        self.layer.masksToBounds = false

        setupShadowView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(theme: Theme?) {
        allRecipeButton.backgroundColor = .white
        allRecipeButton.setTitleColor(theme?.dark, for: .normal)
    }
    
    @objc
    private func allRecipeButtonTapped() {
        searchAllRecipe?()
    }
    
    private func setupShadowView() {
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.backgroundColor = .white
            shadowView.layer.cornerRadius = 8
        }
        shadowOneView.addCustomShadow(color: UIColor(hex: "#484848"),
                                      opacity: 0.15,
                                      radius: 1,
                                      offset: .init(width: 0, height: 0.5))
        shadowTwoView.addCustomShadow(color: UIColor(hex: "#858585"),
                                      opacity: 0.1,
                                      radius: 6,
                                      offset: .init(width: 0, height: 6))
    }
    
    private func makeConstraints() {
        self.addSubviews([shadowOneView, shadowTwoView, allRecipeButton])
        
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalTo(allRecipeButton) }
        }
        
        allRecipeButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
    }
}
