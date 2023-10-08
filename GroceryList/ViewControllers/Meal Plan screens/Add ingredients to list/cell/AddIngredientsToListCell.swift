//
//  AddIngredientsToListCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.10.2023.
//

import UIKit

class AddIngredientsToListCell: UICollectionViewCell {
    
    var tapInStockCross: (() -> Void)?
    
    var info: Data? {
        productImageView.image?.pngData()
    }
    
    private lazy var contentViews: ViewWithOverriddenPoint = {
        let view = ViewWithOverriddenPoint()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.addShadow(color: UIColor(hex: "#858585"), radius: 6, offset: CGSize(width: 0, height: 4))
        return view
    }()
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.addShadow(color: UIColor(hex: "#484848"), radius: 1, offset: CGSize(width: 0, height: 0.5))
        return view
    }()
    
    private lazy var stateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.mealPlanAddIngredientsUnselected()
        return imageView
    }()
    
    private lazy var whiteCheckmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.whiteCheckmark()
        return imageView
    }()
    
    private lazy var productTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var productDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 13).font
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.setCornerRadius(4)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()

    private let foundInPantryView = FoundInPantryView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
        makeConstraints()
        
        foundInPantryView.tapCross = { [weak self] in
            self?.tapInStockCross?()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productTitleLabel.text = ""
        productDescriptionLabel.text = ""
        foundInPantryView.isHidden = true
        
        productImageView.snp.updateConstraints { $0.width.equalTo(40) }
        contentViews.snp.updateConstraints { $0.top.equalToSuperview().offset(0) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView?.backgroundColor = .clear
        self.selectedBackgroundView?.backgroundColor = .clear
    }
    
    func configure(ingredient: Ingredient, serving: String, state: IngredientState) {
        productTitleLabel.text = ingredient.product.title
        if let description = ingredient.description {
            productDescriptionLabel.text = description + ", " + serving
        } else {
            productDescriptionLabel.text = serving
        }
        setupImage(imageData: ingredient.product.localImage,
                   imageURL: ingredient.product.photo)
        stateImageView.image = state.image
        whiteCheckmarkImageView.isHidden = state != .inStock
        
        stackView.removeAllArrangedSubviews()
        stackView.addArrangedSubview(productTitleLabel)
        if !(productDescriptionLabel.text?.isEmpty ?? true) {
            stackView.addArrangedSubview(productDescriptionLabel)
        }
    }
    
    func configureInStock(isVisible: Bool, color: UIColor?) {
        foundInPantryView.isHidden = !isVisible
        guard isVisible else {
            return
        }
        stateImageView.image = stateImageView.image?.withTintColor(color ?? .black)
        foundInPantryView.configureColor(color)
        contentViews.snp.updateConstraints {
            $0.top.equalToSuperview().offset(22)
        }
    }
    
    private func setupImage(imageData: Data?, imageURL: String?) {
        productImageView.image = nil
        if let imageData {
            productImageView.image = UIImage(data: imageData)
            return
        }
        if let url = imageURL {
            productImageView.kf.setImage(with: URL(string: url), placeholder: nil,
                                         options: nil, completionHandler: nil)
            return
        }
        
        if productImageView.image == nil {
            productImageView.snp.updateConstraints {
                $0.width.equalTo(0)
            }
        }
    }

    private func makeConstraints() {
        contentView.addSubviews([shadowView, contentViews])
        contentViews.addSubviews([stackView, productImageView, stateImageView, foundInPantryView])
        stateImageView.addSubview(whiteCheckmarkImageView)
        
        shadowView.snp.makeConstraints {
            $0.edges.equalTo(contentViews)
        }
        
        contentViews.snp.makeConstraints {
            $0.top.equalToSuperview().offset(0)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(4)
        }
        
        stateImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(4)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        whiteCheckmarkImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        
        stackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(6)
            $0.leading.equalTo(stateImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(productImageView.snp.leading).offset(-8)
        }
        
        productImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-4)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        foundInPantryView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(-18)
            $0.height.equalTo(24)
            $0.width.greaterThanOrEqualTo(210)
        }
    }
}

private extension IngredientState {
    var image: UIImage? {
        switch self {
        case .unselect:     return R.image.mealPlanAddIngredientsUnselected()
        case .select:       return R.image.mealPlanAddIngredientsSelected()
        case .purchase:     return R.image.mealPlanAddIngredientsPurchased()
        case .inStock:      return R.image.mealPlanAddIngredientsStock()
        }
    }
}
