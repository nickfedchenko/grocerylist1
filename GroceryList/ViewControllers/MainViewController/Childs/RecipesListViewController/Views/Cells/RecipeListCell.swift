//
//  RecipeListCell.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 06.12.2022.
//

import UIKit

protocol RecipeListCellDelegate: AnyObject {
    func didTapToButProductsAtRecipe(at index: Int)
}

final class RecipeListCell: UICollectionViewCell {
    static let identifier = String(describing: RecipeListCell.self)
    var selectedIndex = -1
    weak var delegate: RecipeListCellDelegate?
    	
    private let mainImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 8
        image.layer.cornerCurve = .continuous
        image.layer.maskedCorners = [.layerMinXMinYCorner]
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .white
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextSemibold(size: 16)
        label.textColor = UIColor(hex: "192621")
        label.textAlignment = .left
        label.numberOfLines = 2
        label.text = "Air fryer bacon"
        return label
    }()
    
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.addToCart(), for: .normal)
        button.setImage(R.image.addToCartFilled(), for: .selected
        )
        button.tintColor = UIColor(hex: "1A645A")
        return button
    }()
    
    func configure(with recipe: ShortRecipeModel) {
        titleLabel.text = recipe.title
        if let url = URL(string: recipe.photo) {
            mainImage.kf.setImage(with: url)
            return
        }
        if let imageData = recipe.localImage,
           let image = UIImage(data: imageData) {
            mainImage.image = image
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawInlinedStroke()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if addToCartButton.frame.contains(point) {
            return addToCartButton
        } else {
            return super.hitTest(point, with: event)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImage.image = nil
    }
    
    private func setupActions() {
        addToCartButton.addAction(
            UIAction { [weak self] _ in
                UIView.animate(withDuration: 0.1) {
                    self?.addToCartButton.alpha = 0.5
                } completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        self?.addToCartButton.alpha = 1
                    }
                }
                self?.addToCartButtonTapped()
            },
            for: .touchUpInside
        )
    }
    
    private func setupSubviews() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.layer.cornerCurve = .continuous
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 3
        self.layer.masksToBounds = false
        [titleLabel, mainImage, addToCartButton].forEach {
            contentView.addSubview($0)
        }
        
        mainImage.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(96)
            make.height.equalTo(64)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(mainImage.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(48)
        }
        addToCartButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
        }
    }
    
    func drawInlinedStroke() {
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 1
    }
    
    func addToCartButtonTapped() {
        delegate?.didTapToButProductsAtRecipe(at: selectedIndex)
    }
    
    func setSuccessfullyAddedIngredients(isSuccess: Bool) {
        addToCartButton.isSelected = isSuccess
        addToCartButton.isUserInteractionEnabled = !isSuccess
    }
}
