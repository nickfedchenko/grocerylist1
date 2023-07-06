//
//  CreateNewRecipeTitleView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.03.2023.
//

import UIKit

final class CreateNewRecipeTitleView: UIView {
    
    var requiredHeight: Int {
        10 + 40 + 8 + 29
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.heavy(size: 32).font
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.recipeCreation()
        return label
    }()
    
    private lazy var stepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 24).font
        label.textColor = R.color.primaryDark()
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setRecipe(title: String?) {
        titleLabel.text = title
    }
    
    func setStep(_ step: String) {
        stepLabel.text = step
    }
    
    private func setup() {
        self.backgroundColor = R.color.background()?.withAlphaComponent(0.9)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, stepLabel])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.top.equalToSuperview().offset(10)
            $0.height.equalTo(40)
        }
        
        stepLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(29)
        }
    }
}
