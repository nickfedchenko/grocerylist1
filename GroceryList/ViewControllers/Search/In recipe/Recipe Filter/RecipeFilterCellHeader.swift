//
//  RecipeFilterCellHeader.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.07.2023.
//

import UIKit

class RecipeFilterCellHeader: UICollectionReusableView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 16).font
        label.textColor = R.color.darkGray()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, color: Theme) {
        titleLabel.text = title.uppercased()
        titleLabel.textColor = color.dark
    }

    private func setupSubviews() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview()
            make.height.equalTo(24)
        }
    }
}
