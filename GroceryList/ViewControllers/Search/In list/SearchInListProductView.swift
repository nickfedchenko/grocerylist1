//
//  SearchInListProductView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.03.2023.
//

import UIKit

final class SearchInListProductView: UIView {
    
    var updatePurchaseStatusAction: ((Product) -> Void)?
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.emptyCheckmark()
        return imageView
    }()
    
    private let whiteCheckmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.whiteCheckmark()
        return imageView
    }()
    
    private lazy var productTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        return label
    }()
    
    private lazy var recipeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 14).font
        label.textColor = recipeColor
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        return label
    }()
    
    private let recipeColor = UIColor(hex: "#58B368")
    private var textColor: UIColor?
    private var isRecipe = false
    private var product: Product
    
    init(product: Product) {
        self.product = product
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configuration(textColor: UIColor?) {
        self.textColor = textColor
        isRecipe = product.fromRecipeTitle != nil
        productTitleLabel.text = product.name
        descriptionLabel.text = product.description
        recipeLabel.text = isRecipe ? R.string.localizable.recipe() : ""
        updatePurchaseStatus(purchaseStatus: product.isPurchased)
    }
    
    private func setup() {
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(tapOnView)

        makeConstraints()
    }
    
    @objc
    private func viewTapped() {
        updatePurchaseStatusAction?(product)
    }
    
    private func updatePurchaseStatus(purchaseStatus: Bool) {
        checkmarkImageView.image = purchaseStatus ? getImageWithColor(color: textColor)
                                                  : R.image.emptyCheckmark()
        
        if isRecipe, !purchaseStatus {
            checkmarkImageView.image = R.image.emptyCheckmark()?.withTintColor(recipeColor)
        }
        
        productTitleLabel.textColor = purchaseStatus ? textColor : .black
        descriptionLabel.textColor = purchaseStatus ? textColor : .black
        recipeLabel.textColor = purchaseStatus ? textColor : recipeColor
    }
    
    private func getImageWithColor(color: UIColor?) -> UIImage? {
        let size = CGSize(width: 28, height: 28)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let color = color else { return nil }
        color.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = image else { return nil }
        return image.rounded(radius: 100)
    }
    
    private func makeConstraints() {
        self.addSubviews([checkmarkImageView, whiteCheckmarkImage,
                           productTitleLabel, recipeLabel, descriptionLabel])
        
        checkmarkImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(32)
        }
        
        whiteCheckmarkImage.snp.makeConstraints {
            $0.centerY.centerX.equalTo(checkmarkImageView)
            $0.width.height.equalTo(17)
        }
        
        productTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkmarkImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-8)
            $0.top.equalToSuperview().offset(7)
            $0.height.equalTo(17)
        }
        
        recipeLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        recipeLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        recipeLabel.snp.makeConstraints {
            $0.leading.equalTo(checkmarkImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(descriptionLabel.snp.leading)
            $0.top.equalTo(productTitleLabel.snp.bottom).offset(2)
            $0.height.equalTo(17)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.top.equalTo(productTitleLabel.snp.bottom).offset(2)
            $0.height.equalTo(17)
        }
    }
}
