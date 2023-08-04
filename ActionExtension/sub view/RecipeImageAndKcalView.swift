//
//  RecipeImageAndKcalView.swift
//  ActionExtension
//
//  Created by Хандымаа Чульдум on 02.08.2023.
//

import Kingfisher
import UIKit

class RecipeImageAndKcalView: UIView {
    
    private var isFirstDraw = true
    
    private let contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    let mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private let kcalView = RecipeKcalView()
    private let cookingTimeBadge = CookingTimeBadge()
    
    let anotherShadowLayer: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(recipe: WebRecipe) {
        cookingTimeBadge.setCookingTime(time: recipe.cookTime)
        if let image = recipe.image,
           let imageUrl = URL(string: image) {
            mainImage.kf.setImage(with: imageUrl)
        }
        
        guard recipe.kcal != nil && recipe.carbohydrates != nil &&
              recipe.protein != nil && recipe.fat != nil else {
            kcalView.isHidden = true
            kcalView.snp.remakeConstraints {
                $0.top.equalTo(mainImage.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(0)
            }
            self.updateConstraints()
            return
        }
        
        let value = Value(kcal: optionalIntCovertToDouble(intValue: recipe.kcal),
                          netCarbs: optionalIntCovertToDouble(intValue: recipe.carbohydrates),
                          proteins: optionalIntCovertToDouble(intValue: recipe.protein),
                          fats: optionalIntCovertToDouble(intValue: recipe.fat))
        
        kcalView.setKcalValue(value: value)
    }
    
    private func optionalIntCovertToDouble(intValue: Int?) -> Double? {
        if let intValue {
            return Double(intValue)
        }
        return nil
    }
    
    private func makeConstraints() {
        self.addSubview(contentView)
        contentView.addSubviews([mainImage, kcalView])
        mainImage.addSubviews([cookingTimeBadge])
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mainImage.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(244)
        }
        
        kcalView.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(64)
        }

        cookingTimeBadge.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(32)
        }
    }
}
