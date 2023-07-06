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

final class RecipeMainImageView: UIView {
    
    weak var delegate: RecipeMainImageViewDelegate?
    
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
    
    private let addToFavoritesButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.addToFavUnselectedNew(), for: .normal)
        button.setImage(R.image.addToFavSelectedNew(), for: .selected)
        button.tintColor = .clear
        return button
    }()
    
    private let shareRecipeButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.shareIconNew(), for: .normal)
        return button
    }()
    
    private let kcalView = RecipeKcalView()
    private let cookingTimeBadge = CookingTimeBadge()
    lazy var promptingView = UIView()
    
    let anotherShadowLayer: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        isUserInteractionEnabled = true
        promptingView.isHidden = true
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
        cookingTimeBadge.setCookingTime(time: recipe.cookingTime)
        if let imageUrl = URL(string: recipe.photo) {
            mainImage.kf.setImage(with: imageUrl)
            return
        }
        if let imageData = recipe.localImage,
           let image = UIImage(data: imageData) {
            mainImage.image = image
        }
    }
    
    func setupKcal(value: Value?) {
        guard let value else {
            kcalView.isHidden = true
            kcalView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            return
        }
        
        kcalView.setKcalValue(value: value)
    }
    
    func showPromptingView() {
        let favoriteLabel = UILabel()
        let shareLabel = UILabel()
        let favoriteImage = UIImageView(image: R.image.promptingFavorites())
        let shareImage = UIImageView(image: R.image.promptingShare())
        [favoriteLabel, shareLabel].forEach {
            $0.textColor = UIColor(hex: "#2E2E2E")
            $0.font = UIFont.SFPro.semibold(size: 16).font
            $0.textAlignment = .center
        }
        favoriteLabel.text = R.string.localizable.addRecipesToFavorites()
        shareLabel.text = R.string.localizable.shareRecipes()

        promptingView.isHidden = false
        promptingView.backgroundColor = .black.withAlphaComponent(0.2)
        promptingView.addSubviews([favoriteImage, shareImage])
        favoriteImage.addSubview(favoriteLabel)
        shareImage.addSubview(shareLabel)
        
        favoriteImage.snp.makeConstraints {
            $0.bottom.equalTo(addToFavoritesButton.snp.top).offset(-3)
            $0.leading.equalTo(addToFavoritesButton).offset(-7)
            $0.width.equalTo(303)
            $0.height.equalTo(66)
        }
        
        shareImage.snp.makeConstraints {
            $0.trailing.equalTo(shareRecipeButton.snp.leading).offset(-6)
            $0.centerY.equalTo(shareRecipeButton)
            $0.width.equalTo(217)
            $0.height.equalTo(46)
        }
        
        favoriteLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(22)
        }
        
        shareLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(22)
        }
    }
    
    private func setupSubviews() {
        self.addSubview(contentView)
        contentView.addSubviews([mainImage, kcalView])
        mainImage.addSubviews([cookingTimeBadge, promptingView, addToFavoritesButton, shareRecipeButton])
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(244)
        }
        
        kcalView.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(64)
        }
        
        promptingView.snp.makeConstraints { make in
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
        guard let time = time, time > 0 else {
            timerCountLabel.text = "--"
            return
        }
        timerCountLabel.text = String(time) + " " + R.string.localizable.min()
    }
    
    private func setupAppearance() {
        backgroundColor = .black.withAlphaComponent(0.6)
        clipsToBounds = true
        layer.cornerRadius = 4
        layer.cornerCurve = .continuous
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
