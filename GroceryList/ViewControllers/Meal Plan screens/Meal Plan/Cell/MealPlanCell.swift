//
//  MealPlanCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 12.09.2023.
//

import UIKit

protocol MealPlanCellDelegate: AnyObject {
    func moveCell(gesture: UILongPressGestureRecognizer)
}

class MealPlanCell: RecipeListCell {

    weak var mealPlanDelegate: MealPlanCellDelegate?
    
    let mealPlanLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 12).font
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contextMenuButton.setImage(R.image.chevronMealPlan(), for: .normal)
        
        makeConstraints()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnMoveButton))
        containerView.addGestureRecognizer(longPressGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateAllConstraints()
    }
    
    func configureMealPlanLabel(text: String, color: UIColor) {
        mealPlanLabel.text = text
        mealPlanLabel.textColor = color
    }
    
    func configureWithoutRecipe() {
        
        containerView.backgroundColor = .clear
        containerView.snp.updateConstraints {
            $0.height.equalTo(0)
            $0.bottom.equalToSuperview().offset(0)
        }
        
        mainImage.snp.updateConstraints { make in
            make.top.leading.equalToSuperview().offset(0)
            make.height.equalTo(0)
        }
        
        contextMenuButton.snp.updateConstraints { make in
            make.width.height.equalTo(0)
        }
        
        favoriteImage.snp.updateConstraints {
            $0.height.equalTo(0)
        }
        
        timeBadgeView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(0)
            $0.height.equalTo(0)
        }
        
        kcalBadgeView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(0)
            $0.height.equalTo(0)
        }
    }
    
    @objc
    private func longPressOnMoveButton(_ gesture: UILongPressGestureRecognizer) {
        mealPlanDelegate?.moveCell(gesture: gesture)
    }
    
    private func updateAllConstraints() {
        
        containerView.backgroundColor = .white
        containerView.snp.updateConstraints {
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        mainImage.snp.updateConstraints { make in
            make.top.leading.equalToSuperview().offset(1)
            make.height.equalTo(62)
        }
        
        contextMenuButton.snp.updateConstraints { make in
            make.width.height.equalTo(40)
        }
        
        favoriteImage.snp.updateConstraints {
            $0.height.equalTo(20)
        }

        timeBadgeView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.height.equalTo(20)
        }
        
        kcalBadgeView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.height.equalTo(20)
        }
    }
    
    private func makeConstraints() {
        containerView.snp.removeConstraints()
        containerView.addSubview(mealPlanLabel)
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        mealPlanLabel.snp.makeConstraints {
            $0.leading.equalTo(kcalBadgeView.snp.trailing).offset(6)
            $0.bottom.equalTo(kcalLabel)
        }
    }
}
