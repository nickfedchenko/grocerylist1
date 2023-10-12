//
//  MealPlanRecipeView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.09.2023.
//

import UIKit

class MealPlanRecipeView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(8)
        view.addShadow(color: .init(hex: "858585"), opacity: 0.15,
                             radius: 6, offset: .init(width: 0, height: 4))
        return view
    }()
    
    private let mainImage: UIImageView = {
        let image = UIImageView()
        image.setCornerRadius(7)
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .white
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextSemibold(size: 16)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 12).font
        label.textColor = .white
        return label
    }()
    
    private let kcalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 12).font
        return label
    }()
    
    private let timeImage = UIImageView(image: R.image.recipeTimeIcon())
    private let kcalImage = UIImageView(image: R.image.recipeKcalIcon())
    private let favoriteImage = UIImageView(image: R.image.recipeFavoriteIcon())
    
    private let timeBadgeView = UIView()
    private let kcalBadgeView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [timeBadgeView, kcalBadgeView].forEach {
            $0.setCornerRadius(4)
        }
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawInlinedStroke()
    }
    
    func configureColor(theme: Theme) {
        timeBadgeView.backgroundColor = theme.medium
        kcalBadgeView.backgroundColor = theme.light
        
        kcalLabel.textColor = theme.dark
        kcalImage.image = R.image.recipeKcalIcon()?.withTintColor(theme.medium)
    }
    
    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.title
        let time = recipe.cookingTime ?? -1
        timeLabel.text = time < 0 ? "--" : "\(time)"
        favoriteImage.isHidden = !UserDefaultsManager.shared.favoritesRecipeIds.contains(recipe.id)
        
        if let kcal = recipe.values?.serving?.kcal ?? recipe.values?.dish?.kcal {
            kcalBadgeView.isHidden = false
            kcalLabel.text = "\(Int(kcal))"
        } else {
            kcalBadgeView.isHidden = true
        }

        if let url = URL(string: recipe.photo) {
            mainImage.kf.setImage(with: url)
            return
        }
        if let imageData = recipe.localImage,
           let image = UIImage(data: imageData) {
            mainImage.image = image
        }
    }
    
    func setupSubviews() {
        self.addSubview(containerView)
        containerView.addSubviews([titleLabel, mainImage])
        containerView.addSubviews([timeBadgeView, kcalBadgeView, favoriteImage])
        timeBadgeView.addSubviews([timeLabel, timeImage])
        kcalBadgeView.addSubviews([kcalImage, kcalLabel])
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainImage.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(1)
            make.bottom.equalToSuperview().offset(-1)
            make.width.equalTo(93)
            make.height.equalTo(62)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(timeBadgeView.snp.bottom)
            make.leading.equalTo(mainImage.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }
        
        favoriteImage.snp.makeConstraints {
            $0.top.equalTo(mainImage).offset(3)
            $0.trailing.equalTo(mainImage).offset(-3)
            $0.height.equalTo(20)
        }
        
        badgeMakeConstraints()
    }
    
    func badgeMakeConstraints() {
        timeBadgeView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalTo(mainImage.snp.trailing).offset(8)
            $0.height.equalTo(20)
        }
        
        kcalBadgeView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalTo(timeBadgeView.snp.trailing).offset(4)
            $0.height.equalTo(20)
        }
        
        timeImage.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(2)
            $0.height.width.equalTo(16)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(timeImage.snp.trailing)
            $0.bottom.equalTo(timeImage)
            $0.trailing.equalToSuperview().offset(-4)
        }
        
        kcalImage.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(2)
            $0.height.width.equalTo(16)
        }
        
        kcalLabel.snp.makeConstraints {
            $0.leading.equalTo(kcalImage.snp.trailing)
            $0.bottom.equalTo(kcalImage)
            $0.trailing.equalToSuperview().offset(-4)
        }
    }
        
    private func drawInlinedStroke() {
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.borderWidth = 1
    }

}
