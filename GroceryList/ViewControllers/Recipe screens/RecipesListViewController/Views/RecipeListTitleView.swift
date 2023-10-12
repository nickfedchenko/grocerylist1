//
//  RecipeListTitleView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.06.2023.
//

import UIKit

class RecipeListTitleView: UIView {
    
    private let iconImageView = UIImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.heavy(size: 32).font
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
        
    var necessaryHeight: CGFloat {
        let titleHeight = 16 + titleLabel.intrinsicContentSize.height
        return titleHeight < 40 ? 40 : titleHeight
    }
    
    var maximumLineHeight: CGFloat = 32 {
        didSet { titleLabel.setMaximumLineHeight(value: maximumLineHeight) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title
        maximumLineHeight = 32
    }
    
    func setColor(_ theme: Theme) {
        iconImageView.image = R.image.menuFolderBig()?.withTintColor(theme.medium)
        titleLabel.textColor = theme.dark
        self.backgroundColor = theme.light.withAlphaComponent(0.95)
    }
    
    func setFont(font: UIFont) {
        titleLabel.font = font
    }
    
    private func setupSubviews() {
        self.addSubviews([iconImageView, titleLabel])

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(titleLabel)
            $0.height.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(iconImageView)
            $0.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
    }
}
