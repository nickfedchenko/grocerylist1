//
//  CreateNewRecipeTitleView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.03.2023.
//

import UIKit

final class CreateNewRecipeTitleView: UIView {
    
    var requiredHeight: Int {
        26 + 24 + 8 + 24
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = UIColor(hex: "#1A645A")
        label.text = R.string.localizable.recipeCreation()
        return label
    }()
    
    private lazy var stepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = UIColor(hex: "#1A645A")
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
        guard let title else {
            return
        }
        titleLabel.text = title
    }
    
    func setStep(_ step: String) {
        stepLabel.text = step
    }
    
    private func setup() {
        self.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, stepLabel])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.top.equalToSuperview().offset(26)
            $0.height.equalTo(24)
        }
        
        stepLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(24)
        }
    }
}
