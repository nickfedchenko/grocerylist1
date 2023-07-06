//
//  RecipeListCell.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 06.12.2022.
//

import UIKit

protocol RecipeListCellDelegate: AnyObject {
    func contextMenuTapped(at index: Int, point: CGPoint, cell: RecipeListCell)
}

class RecipeListCell: UICollectionViewCell {

    weak var delegate: RecipeListCellDelegate?
    
    var selectedIndex = -1

    let mainImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 7
        image.layer.cornerCurve = .continuous
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .white
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextSemibold(size: 16)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 12).font
        label.textColor = .white
        return label
    }()
    
    let kcalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 12).font
        return label
    }()
    
    let timeImage = UIImageView(image: R.image.recipeTimeIcon())
    let kcalImage = UIImageView(image: R.image.recipeKcalIcon())
    let favoriteImage = UIImageView(image: R.image.recipeFavoriteIcon())
    
    let timeBadgeView = UIView()
    let kcalBadgeView = UIView()
    
    let contextMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.pantry_context_menu(), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 3
        self.layer.masksToBounds = false
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.layer.cornerCurve = .continuous

        [timeBadgeView, kcalBadgeView].forEach {
            $0.layer.cornerRadius = 4
            $0.layer.cornerCurve = .continuous
        }
        
        setupSubviews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if contextMenuButton.frame.contains(point) {
            return contextMenuButton
        } else {
            return super.hitTest(point, with: event)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImage.image = nil
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
        
        contextMenuButton.tintColor = theme.dark
    }
    
    func configure(with recipe: ShortRecipeModel) {
        titleLabel.text = recipe.title
        timeLabel.text = "\(recipe.time)"
        favoriteImage.isHidden = !recipe.isFavorite
        
        if let kcal = recipe.values?.dish?.kcal {
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
    
    func setSuccessfullyAddedIngredients(isSuccess: Bool) {
        contextMenuButton.isSelected = isSuccess
        contextMenuButton.isUserInteractionEnabled = !isSuccess
    }
    
    private func setupActions() {
        contextMenuButton.addAction(
            UIAction { [weak self] _ in
                guard let self else {
                    return
                }
                UIView.animate(withDuration: 0.1) {
                    self.contextMenuButton.alpha = 0.5
                } completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        self.contextMenuButton.alpha = 1
                    }
                }
                self.delegate?.contextMenuTapped(at: self.selectedIndex,
                                                 point: contextMenuButton.center, cell: self)
            },
            for: .touchUpInside
        )
    }
    
    func setupSubviews() {
        contentView.addSubviews([titleLabel, mainImage, contextMenuButton])
        contentView.addSubviews([timeBadgeView, kcalBadgeView, favoriteImage])
        timeBadgeView.addSubviews([timeLabel, timeImage])
        kcalBadgeView.addSubviews([kcalImage, kcalLabel])
        
        mainImage.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(1)
            make.bottom.equalToSuperview().offset(-1)
            make.width.equalTo(93)
            make.height.equalTo(62)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(timeBadgeView.snp.bottom).offset(4)
            make.leading.equalTo(mainImage.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(64)
            make.bottom.equalToSuperview().offset(-4)
            make.height.equalTo(32)
        }
        
        contextMenuButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
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
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 1
    }
}
