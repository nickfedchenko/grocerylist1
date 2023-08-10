//
//  RecipeDescriptionView.swift
//  ActionExtension
//
//  Created by Хандымаа Чульдум on 02.08.2023.
//

import UIKit

class RecipeDescriptionView: UIView {

    private lazy var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProRoundedBold(size: 18)
        label.textColor = R.color.primaryDark()
        label.text = "Description".localized
        return label
    }()
    
    private lazy var descriptionRecipeLabel: UILabel = {
        let label = PaddingLabel(withInsets: 8, 8, 8, 8)
        label.font = UIFont.SFPro.medium(size: 15).font
        label.textColor = .black
        label.backgroundColor = .white
        label.layer.cornerRadius = 8
        label.layer.cornerCurve = .continuous
        label.clipsToBounds = true
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        descriptionRecipeLabel.isHidden = true
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(description: String) {
        descriptionRecipeLabel.isHidden = false
        descriptionRecipeLabel.text = description
    }
    
    private func makeConstraints() {
        self.addSubviews([descriptionTitleLabel, descriptionRecipeLabel])
        
        descriptionTitleLabel.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        descriptionRecipeLabel.setContentHuggingPriority(.init(1000), for: .vertical)
        descriptionRecipeLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        descriptionRecipeLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTitleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
