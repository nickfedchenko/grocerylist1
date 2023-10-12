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
    
    private lazy var descriptionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var descriptionRecipeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 15).font
        label.textColor = .black
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
        
        self.layoutIfNeeded()
    }
    
    func updateTitle() {
        descriptionTitleLabel.font = UIFont.SFProRounded.bold(size: 18).font
        descriptionTitleLabel.textColor = R.color.darkGray()
        
        descriptionRecipeLabel.setMaximumLineHeight(value: 20)
        descriptionRecipeLabel.textColor = UIColor(hex: "514631")
        
        descriptionTitleLabel.snp.removeConstraints()
        descriptionTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(40)
        }
        
        descriptionView.snp.updateConstraints {
            $0.top.equalTo(descriptionTitleLabel.snp.bottom).offset(0)
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([descriptionTitleLabel, descriptionView])
        descriptionView.addSubview(descriptionRecipeLabel)
        
        descriptionTitleLabel.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        descriptionView.snp.makeConstraints {
            $0.top.equalTo(descriptionTitleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        descriptionRecipeLabel.setContentHuggingPriority(.init(1000), for: .vertical)
        descriptionRecipeLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        descriptionRecipeLabel.snp.makeConstraints {
            $0.horizontalEdges.verticalEdges.equalToSuperview().inset(8)
        }
    }
}
