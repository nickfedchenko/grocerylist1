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
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setColor(_ theme: Theme) {
        iconImageView.image = R.image.menuFolderBig()?.withTintColor(theme.medium)
        titleLabel.textColor = theme.dark
        self.backgroundColor = theme.light.withAlphaComponent(0.95)
    }
    
    private func setupSubviews() {
        self.addSubviews([iconImageView, titleLabel])

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.bottom.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing)
        }
    }
}
