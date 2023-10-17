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
    
    private let mealPlanLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 12).font
        return label
    }()
    
    private let editImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.mealplanEdit_Off()
        imageView.isHidden = true
        return imageView
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
        
        editImageView.isHidden = true
        contextMenuButton.setImage(R.image.chevronMealPlan(), for: .normal)
        contextMenuButton.tintColor = nil
        
        mealPlanLabel.snp.remakeConstraints {
            $0.leading.equalTo(kcalBadgeView.snp.trailing).offset(6)
            $0.bottom.equalTo(kcalLabel)
        }
    }
    
    override func configure(with recipe: ShortRecipeModel) {
        super.configure(with: recipe)

        if let kcal = recipe.values?.serving?.kcal ?? recipe.values?.dish?.kcal {
            mealPlanLabel.snp.remakeConstraints {
                $0.leading.equalTo(kcalBadgeView.snp.trailing).offset(6)
                $0.bottom.equalTo(kcalLabel)
            }
        } else {
            mealPlanLabel.snp.remakeConstraints {
                $0.leading.equalTo(timeBadgeView.snp.trailing).offset(6)
                $0.bottom.equalTo(kcalLabel)
            }
        }
    }
    
    func configureMealPlanLabel(text: String, color: UIColor) {
        mealPlanLabel.text = text
        mealPlanLabel.textColor = color
    }
    
    func configureEditMode(isEdit: Bool, isSelect: Bool) {
        guard isEdit else {
            return
        }
        
        contextMenuButton.setImage(R.image.rearrange(), for: .normal)
        contextMenuButton.tintColor = R.color.edit()
        
        editImageView.isHidden = false
        editImageView.image = isSelect ? R.image.mealplanEdit_On() : R.image.mealplanEdit_Off()
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
        containerView.addSubviews([mealPlanLabel, editImageView])
        
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
        
        editImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(3)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(36)
        }
    }
}
