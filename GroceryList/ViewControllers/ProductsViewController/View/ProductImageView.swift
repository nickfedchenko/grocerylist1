//
//  ProductImageView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 27.02.2023.
//

import UIKit

final class ProductImageView: UIView {

    var deleteImageAction: (() -> Void)?
    var galleryAction: (() -> Void)?
    var closeAction: (() -> Void)?
    var updatePurchaseStatusAction: ((Bool) -> Void)?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCustomShadow(color: UIColor(hex: "#484848"), radius: 1, offset: CGSize(width: 0, height: 0.5))
        return view
    }()
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCustomShadow(color: UIColor(hex: "#858585"), radius: 6, offset: CGSize(width: 0, height: 4))
        return view
    }()
    
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
    
    private lazy var crossButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.closeButtonCross(), for: .normal)
        button.addTarget(self, action: #selector(crossButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var galleryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#D1D5DB").withAlphaComponent(0.5)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.setImage(R.image.gallery(), for: .normal)
        button.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#D1D5DB").withAlphaComponent(0.5)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.setImage(R.image.trash_can(), for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let recipeColor = UIColor(hex: "#58B368")
    private var textColor: UIColor?
    private var isRecipe = false
    private var purchaseStatus = false {
        didSet { updatePurchaseStatus() }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configuration(product: Product, textColor: UIColor?) {
        guard let image = product.imageData else {
            return
        }
        self.textColor = textColor
        isRecipe = product.fromRecipeTitle != nil
        purchaseStatus = product.isPurchased
        productImageView.image = UIImage(data: image)
        productTitleLabel.text = product.name
        descriptionLabel.text = product.description
        recipeLabel.text = isRecipe ? R.string.localizable.recipe() : ""
    }
    
    func updateImage(_ image: UIImage?) {
        productImageView.image = image
    }
    
    private func setup() {
        let tapOnNavView = UITapGestureRecognizer(target: self, action: #selector(navViewTapped))
        navView.addGestureRecognizer(tapOnNavView)
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(crossButtonTapped))
        self.addGestureRecognizer(tapOnView)
        self.backgroundColor = .black.withAlphaComponent(0.2)
        
        makeConstraints()
    }
    
    @objc
    private func crossButtonTapped() {
        updatePurchaseStatusAction?(purchaseStatus)
        closeAction?()
    }
    
    @objc
    private func deleteButtonTapped() {
        deleteImageAction?()
    }
    
    @objc
    private func galleryButtonTapped() {
        galleryAction?()
    }
    
    @objc
    private func navViewTapped() {
        purchaseStatus.toggle()
    }
    
    private func updatePurchaseStatus() {
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
        self.addSubview(contentView)
        contentView.addSubviews([productImageView, galleryButton, deleteButton, shadowView, navView])
        navView.addSubviews([checkmarkImageView, whiteCheckmarkImage, crossButton,
                             productTitleLabel, recipeLabel, descriptionLabel])
        
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(self.snp.width).offset(16)
        }
        
        shadowView.snp.makeConstraints {
            $0.edges.equalTo(navView)
        }
        
        navView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        productImageView.snp.makeConstraints {
            $0.top.equalTo(navView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        galleryButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
            $0.height.width.equalTo(40)
        }
        
        deleteButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().offset(-4)
            $0.height.width.equalTo(40)
        }
        
        makeNavViewConstraints()
    }
    
    private func makeNavViewConstraints() {
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
            $0.trailing.equalTo(crossButton.snp.leading).offset(-8)
            $0.top.equalToSuperview().offset(7)
            $0.height.equalTo(17)
        }
        
        recipeLabel.snp.makeConstraints {
            $0.leading.equalTo(checkmarkImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(descriptionLabel.snp.leading)
            $0.top.equalTo(productTitleLabel.snp.bottom).offset(2)
            $0.height.equalTo(17)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.trailing.equalTo(crossButton.snp.leading).offset(-8)
            $0.top.equalTo(productTitleLabel.snp.bottom).offset(2)
            $0.height.equalTo(17)
        }
        
        crossButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(40)
        }
    }
}
