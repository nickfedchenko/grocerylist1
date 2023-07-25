//
//  RecipesGroupHeader.swift
//  CalorieTracker
//
//  Created by Vladimir Banushkin on 04.08.2022.
//

import UIKit

protocol RecipesFolderHeaderDelegate: AnyObject {
    func headerTapped(at index: Int)
}

class RecipesFolderHeader: UICollectionReusableView {
    
    weak var delegate: RecipesFolderHeaderDelegate?
    var sectionIndex: Int = -1
    
    private let folderIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.folderIcon()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let folderTitleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 16)
        label.textColor = UIColor(hex: "0C695E")
        label.text = ["Breakfast", "Lunch", "Dinner"].randomElement()
        label.numberOfLines = 2
        return label
    }()
    
    private let recipesCountLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 16)
        label.textColor = UIColor(hex: "7A948F")
        label.text = ["128", "280", "175"].randomElement()
        return label
    }()
    
    private let chevronIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.chevronRight()
        imageView.contentMode = .center
        return imageView
    }()
    
    func configure(with sectionModel: RecipeSectionsModel, at sectionIndex: Int,
                   color: Theme) {
        recipesCountLabel.text = String(sectionModel.recipes.count)
        folderTitleLabel.text = sectionModel.sectionType.title
        self.sectionIndex = sectionIndex
        
        folderIcon.image = R.image.folderIcon()?.withTintColor(color.medium)
        folderTitleLabel.textColor = color.dark
        recipesCountLabel.textColor = color.medium
        chevronIcon.image = R.image.chevronRight()?.withTintColor(color.dark)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupActions() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerTapped)))
    }
    
    @objc
    private func headerTapped() {
        delegate?.headerTapped(at: sectionIndex)
    }
    
    private func setupSubviews() {
        [folderIcon, folderTitleLabel, recipesCountLabel, chevronIcon].forEach {
            addSubview($0)
        }
        
        folderIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        folderTitleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(folderIcon.snp.trailing).offset(6)
            make.trailing.equalTo(recipesCountLabel.snp.leading).inset(-8)
            make.height.greaterThanOrEqualTo(40)
        }
        
        chevronIcon.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        recipesCountLabel.setContentHuggingPriority(.init(999), for: .horizontal)
        recipesCountLabel.setContentCompressionResistancePriority(.init(999), for: .horizontal)
        recipesCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(chevronIcon)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(chevronIcon.snp.leading).inset(-8)
        }
    }
}
