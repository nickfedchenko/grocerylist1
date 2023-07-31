//
//  RecipeSearchView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.06.2023.
//

import UIKit

final class RecipeSearchView: UIView {

    private let whiteView = UIView()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = R.color.mediumGray()
        label.text = R.string.localizable.searchByNameOrIngredient()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let searchImageView = UIImageView(image: R.image.searchButtonImage()?
        .withTintColor(R.color.mediumGray() ?? .black))
    private let filterImageView = UIImageView(image: R.image.searchEditFilters())

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        whiteView.backgroundColor = .white
        whiteView.layer.cornerRadius = 8
        whiteView.layer.cornerCurve = .continuous
        whiteView.addCustomShadow(color: UIColor(hex: "484848"),
                                  offset: .init(width: 0, height: 1))
        
        self.addSubviews([whiteView])
        whiteView.addSubviews([placeholderLabel, searchImageView, filterImageView])
        
        whiteView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }
        
        searchImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.leading.equalTo(searchImageView.snp.trailing)
            $0.trailing.equalTo(filterImageView.snp.leading).offset(-8)
            $0.top.equalToSuperview().offset(10)
        }
        
        filterImageView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview()
            $0.height.width.equalTo(40)
        }
    }
}
