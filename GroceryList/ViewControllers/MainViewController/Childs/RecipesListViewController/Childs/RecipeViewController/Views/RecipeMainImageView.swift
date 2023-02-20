//
//  RecipeMainImageView.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 11.12.2022.
//

import UIKit

protocol RecipeMainImageViewDelegate: AnyObject {
    func addToFavoritesTapped()
    func shareButtonTapped()
}

final class CookingTimeBadge: UIView {
    private let timerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.timerIcon()
        return imageView
    }()
    
    private let timerCountLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextMedium(size: 15)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCookingTime(time: Int?) {
        guard let time = time else { return }
        timerCountLabel.text = String(time) + " " + R.string.localizable.min()
    }
    
    private func setupAppearance() {
        backgroundColor = UIColor(hex: "547771").withAlphaComponent(0.8)
        clipsToBounds = true
        layer.cornerRadius = 4
    }
    
    private func setupSubviews() {
        addSubviews([timerImage, timerCountLabel])
        timerImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(6)
            make.height.equalTo(20)
            make.width.equalTo(21)
        }
        
        timerCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
            make.leading.equalTo(timerImage.snp.trailing).offset(8)
        }
    }
}

final class RecipeMainImageView: UIView {
    
    weak var delegate: RecipeMainImageViewDelegate?
    
    private var isFirstDraw = true
    
    let mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let addToFavoritesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.addToFavUnselected(), for: .normal)
        button.setImage(R.image.addToFavSelected(), for: .selected)
        button.tintColor = .clear
        return button
    }()
    
    private let cookingTimeBadge = CookingTimeBadge()
    
    private let shareRecipeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.shareIcon(), for: .normal)
        return button
    }()
    
    let anotherShadowLayer: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        isUserInteractionEnabled = true
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupAppearance()
    }
    
    func setIsFavorite(shouldSetFavorite: Bool) {
        addToFavoritesButton.isSelected = shouldSetFavorite
    }
    
    func setupFor(recipe: Recipe) {
        if let imageUrl = URL(string: recipe.photo) {
            mainImage.kf.setImage(with: imageUrl)
        }
        cookingTimeBadge.setCookingTime(time: recipe.cookingTime)
    }
    
    private func setupSubviews() {
        addSubview(mainImage)
        mainImage.addSubview(addToFavoritesButton)
        mainImage.addSubview(cookingTimeBadge)
        mainImage.addSubview(shareRecipeButton)
        
        mainImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addToFavoritesButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().inset(12)
        }
        
        cookingTimeBadge.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
            make.height.equalTo(32)
        }
        
        shareRecipeButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(12)
            make.width.height.equalTo(32)
        }
    }
    
    private func setupActions() {
        addToFavoritesButton.addTarget(self, action: #selector(addToFavoritesTapped(sender:)), for: .touchUpInside)
        shareRecipeButton.addTarget(self, action: #selector(shareButtonTapped(sender:)), for: .touchUpInside)
    }
    
    @objc
    private func addToFavoritesTapped(sender: UIButton) {
        sender.animateByScaleTransform()
        sender.isSelected.toggle()
        delegate?.addToFavoritesTapped()
    }
    
    @objc
    private func shareButtonTapped(sender: UIButton) {
        sender.animateByScaleTransform()
        delegate?.shareButtonTapped()
    }
    
    private func setupAppearance() {
        guard isFirstDraw else { return }
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.shadowPath = path
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.03
        layer.shadowRadius = 8
        anotherShadowLayer.path = path
        anotherShadowLayer.shadowPath = path
        anotherShadowLayer.shadowOffset = CGSize(width: 0, height: 1)
        anotherShadowLayer.shadowColor = UIColor.black.cgColor
        anotherShadowLayer.shadowOpacity = 0.03
        anotherShadowLayer.shadowRadius = 16
        layer.insertSublayer(anotherShadowLayer, at: 0)
        isFirstDraw.toggle()
    }
}
