//
//  ProductListCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.11.2022.
//

import SnapKit
import UIKit

class ProductListCell: UICollectionViewListCell {
    
    var swipeToPinchAction: (() -> Void)?
    var swipeToDeleteAction: (() -> Void)?
    var tapImageAction: (() -> Void)?
    private var state: CellState = .normal
    
    private let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.addCustomShadow(color: UIColor(hex: "#484848"), radius: 1, offset: CGSize(width: 0, height: 0.5))
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        rightButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        leftButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        setupConstraints()
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
        attrs.bounds.size.height = 56
        return attrs
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.textColor = .black
        nameLabel.attributedText = NSAttributedString(string: "")
        firstDescriptionLabel.attributedText = NSAttributedString(string: "")
        firstDescriptionLabel.textColor = .black
        secondDescriptionLabel.attributedText = NSAttributedString(string: "")
        secondDescriptionLabel.textColor = .black
        viewWithDescription.isHidden = true
        clearTheCell()
    }
    
    func setupCell(bcgColor: UIColor?, textColor: UIColor?, text: String?,
                   isPurchased: Bool, image: Data?, description: String, isRecipe: Bool) {
        contentView.backgroundColor = bcgColor
        checkmarkImage.image = isPurchased ? getImageWithColor(color: textColor) : UIImage(named: "emptyCheckmark")
        guard let text = text else { return }
        
        nameLabel.attributedText = NSAttributedString(string: text)
        firstDescriptionLabel.attributedText = NSAttributedString(string: text)
        secondDescriptionLabel.text = description
        
        if isRecipe {
            let recipe = "Recipe".localized.attributed(font: UIFont.SFProRounded.bold(size: 14).font,
                                                       color: UIColor(hex: "#58B368"))
            recipe.append(NSAttributedString(string: description))
            secondDescriptionLabel.attributedText = recipe
            if !isPurchased {
                checkmarkImage.image = UIImage(named: "emptyCheckmark")?.withTintColor(UIColor(hex: "#58B368"))
            }

        }
        
        if isPurchased {
            nameLabel.textColor = textColor
            firstDescriptionLabel.textColor = textColor
            secondDescriptionLabel.textColor = textColor
        }
        
        if let image = image {
            DispatchQueue.global().async {
                let image = UIImage(data: image)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
        
        if !description.isEmpty {
            viewWithDescription.isHidden = false
        }
    }
    
    func addCheckmark(color: UIColor?, compl: @escaping (() -> Void) ) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.checkmarkImage.image = self.getImageWithColor(color: color)
            self.nameLabel.attributedText = self.nameLabel.text?.strikeThrough()
            self.firstDescriptionLabel.attributedText = self.firstDescriptionLabel.text?.strikeThrough()
            self.layoutIfNeeded()
        } completion: { _ in
            compl()
        }
    }
    
    func removeCheckmark(compl: @escaping (() -> Void) ) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.checkmarkImage.image = UIImage(named: "emptyCheckmark")
            guard let text = self.nameLabel.text else { return }
            self.nameLabel.attributedText = NSAttributedString(string: text)
            self.nameLabel.textColor = .black
            self.layoutIfNeeded()
        } completion: { _ in
            compl()
        }
    }
    
    func getImageWithColor(color: UIColor?) -> UIImage? {
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
    
    private let contentViews: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.addCustomShadow(color: UIColor(hex: "#858585"), radius: 6, offset: CGSize(width: 0, height: 4))
        return view
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "emptyCheckmark")
        return imageView
    }()
    
    private let whiteCheckmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "whiteCheckmark")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        return label
    }()
    
    private lazy var leftButton: UIButton = {
        let imageView = UIButton()
        imageView.setImage(UIImage(named: "greenPinchImage"), for: .normal)
        imageView.addTarget(self, action: #selector(pinchPressed), for: .touchUpInside)
        return imageView
    }()
    
    private lazy var rightButton: UIButton = {
        let imageView = UIButton()
        imageView.setImage(UIImage(named: "redDeleteImage"), for: .normal)
        imageView.addTarget(self, action: #selector(deletePressed), for: .touchUpInside)
        return imageView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let viewWithDescription: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    private let firstDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.text = "dfdf"
        return label
    }()
    
    private let secondDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 14).font
        label.textColor = .black
        label.text = "dfdkf"
        return label
    }()
    
    // MARK: - UI
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        contentView.addSubviews([leftButton, rightButton, shadowView, contentViews])
        contentViews.addSubviews([nameLabel, checkmarkImage, whiteCheckmarkImage, imageView, viewWithDescription])
        viewWithDescription.addSubviews([firstDescriptionLabel, secondDescriptionLabel])
        
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(contentViews)
        }
        
        contentViews.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(4)
        }
        
        viewWithDescription.snp.makeConstraints { make in
            make.right.equalTo(imageView.snp.left)
            make.left.equalTo(nameLabel)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        firstDescriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(checkmarkImage.snp.top)
            make.height.equalTo(17)
        }
        
        secondDescriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(6)
            make.height.equalTo(17)
        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(checkmarkImage.snp.right).inset(-12)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(8)
        }
        
        whiteCheckmarkImage.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(checkmarkImage)
            make.width.height.equalTo(17)
        }
        
        rightButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentViews)
            make.right.equalToSuperview().inset(-1)
            make.width.equalTo(68)
        }
        
        leftButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentViews)
            make.left.equalToSuperview().inset(-1)
            make.width.equalTo(68)
        }
        
        imageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
}

// MARK: - Swipe to delete
extension ProductListCell {
    
    private func addGestureRecognizers() {
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRightRecognizer.direction = .right
        contentViews.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeLeftRecognizer.direction = .left
        contentViews.addGestureRecognizer(swipeLeftRecognizer)
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(imagePressed))
        imageView.addGestureRecognizer(tapImage)
    }
    
    @objc
    private func deletePressed() {
        swipeToPinchAction?()
    }
    
    @objc
    private func pinchPressed() {
        swipeToDeleteAction?()
    }
    
    @objc
    private func imagePressed() {
        tapImageAction?()
    }
    
    @objc
    private func swipeAction(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .right:
            if state == .swipedRight {
                DispatchQueue.main.async {
                    self.clearTheCell()
                }
                swipeToDeleteAction?()
            }
            if state == .normal { showLeftImage() }
            if state == .swipedLeft { hideRightImage() }
            
        case .left:
            guard nameLabel.textColor == .black else { return }
            if state == .swipedLeft {
                
                DispatchQueue.main.async {
                    self.clearTheCell()
                }
                swipeToPinchAction?()
            }
            if state == .normal { showRightImage() }
            if state == .swipedRight { hideLeftImage() }
        default:
            print("")
        }
    }
    
    private func showLeftImage() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.leftButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(60)
                make.right.equalToSuperview().inset(-56)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .swipedRight
        }
    }
    
    private func hideLeftImage() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.leftButton.transform = CGAffineTransform(scaleX: 0, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.left.right.equalToSuperview().inset(16)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .normal
        }
    }
    
    private func showRightImage() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.rightButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(60)
                make.left.equalToSuperview().inset(-7)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .swipedLeft
        }
    }
    
    private func hideRightImage() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.rightButton.transform = CGAffineTransform(scaleX: 0, y: 1)
            self.contentViews.snp.updateConstraints { make in
                make.left.right.equalToSuperview().inset(16)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .normal
        }
    }
    
    private func clearTheCell() {
        rightButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        leftButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        contentViews.snp.updateConstraints { make in
            make.left.right.equalToSuperview().inset(16)
        }
        state = .normal
        imageView.image = nil
        self.layoutIfNeeded()
    }
}
