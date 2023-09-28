//
//  ProductListCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.11.2022.
//

import Kingfisher
import SnapKit
import UIKit

class ProductListCell: UICollectionViewListCell {
    
    var swipeToPinchAction: (() -> Void)?
    var swipeToDeleteAction: (() -> Void)?
    var tapImageAction: (() -> Void)?
    var tapInStockCross: (() -> Void)?
    
    private let contentViews: ViewWithOverriddenPoint = {
        let view = ViewWithOverriddenPoint()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.addShadow(color: UIColor(hex: "#858585"), radius: 6, offset: CGSize(width: 0, height: 4))
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
        label.numberOfLines = 2
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
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private let viewWithDescription: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    private let nameWithDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private let secondDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 14).font
        label.textColor = .black
        return label
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let checkmarkView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    private let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.addShadow(color: UIColor(hex: "#484848"), radius: 1, offset: CGSize(width: 0, height: 0.5))
        return view
    }()
    
    private let costView = CostOfProductListView()
    private let foundInPantryView = FoundInPantryView()
    private var state: CellState = .normal
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        rightButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        leftButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        setupConstraints()
        addGestureRecognizers()
        
        foundInPantryView.tapCross = { [weak self] in
            self?.tapInStockCross?()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.textColor = .black
        nameLabel.attributedText = NSAttributedString(string: "")
        nameWithDescriptionLabel.attributedText = NSAttributedString(string: "")
        nameWithDescriptionLabel.textColor = .black
        secondDescriptionLabel.attributedText = NSAttributedString(string: "")
        secondDescriptionLabel.textColor = .black
        viewWithDescription.isHidden = true
        whiteCheckmarkImage.isHidden = false
        whiteCheckmarkImage.image = R.image.whiteCheckmark()
        secondDescriptionLabel.snp.updateConstraints { $0.bottom.equalToSuperview().inset(6) }
        costView.isHidden = true
        foundInPantryView.isHidden = true
        contentViews.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
        imageView.snp.updateConstraints { $0.width.equalTo(40) }
        clearTheCell()
    }
    
    func setState(state: CellState) {
        self.state = state
    }
    
    func setupCell(bcgColor: UIColor?, textColor: UIColor?, text: String?,
                   isPurchased: Bool, description: String, isOutOfStock: Bool) {
        contentView.backgroundColor = bcgColor
        guard let text = text else { return }
        setupCheckmarkImage(isPurchased: isPurchased, color: textColor)
        nameLabel.attributedText = NSAttributedString(string: text)
        nameWithDescriptionLabel.attributedText = NSAttributedString(string: text)
        secondDescriptionLabel.text = description
        
        if isPurchased {
            nameLabel.textColor = textColor
            nameWithDescriptionLabel.textColor = textColor
            secondDescriptionLabel.textColor = textColor
        }
        
        if !(secondDescriptionLabel.text?.isEmpty ?? true) {
            viewWithDescription.isHidden = false
        }
        
        whiteCheckmarkImage.isHidden = isOutOfStock
        checkmarkView.layer.cornerRadius = isOutOfStock ? 5 : 18
        if isOutOfStock {
            checkmarkImage.image = R.image.product_outOfStock()
        }
    }
    
    func setupRecipeMealPlan(textColor: UIColor?, isRecipe: Bool, mealPlan: MealPlan?) {
        let description = secondDescriptionLabel.text ?? ""
        if isRecipe {
            let recipe = "Recipe".localized.attributed(font: UIFont.SFProRounded.bold(size: 14).font,
                                                       color: textColor ?? UIColor(hex: "#58B368"))
            recipe.append(NSAttributedString(string: description))
            secondDescriptionLabel.attributedText = recipe
        }
        
        if let mealPlan {
            let mealPlanDate = mealPlan.date.getStringDate(format: "MMMd")
            let date = mealPlanDate.attributed(font: UIFont.SFProRounded.bold(size: 14).font,
                                               color: textColor ?? UIColor(hex: "#58B368"))
            date.append(NSAttributedString(string: description))
            secondDescriptionLabel.attributedText = date
        }
        
        if !(secondDescriptionLabel.attributedText?.string.isEmpty ?? true) {
            viewWithDescription.isHidden = false
        }
    }
    
    func setupImage(isVisible: Bool, image: Data?) {
        imageView.isHidden = !isVisible
        guard isVisible else {
            imageView.snp.updateConstraints {
                $0.width.equalTo(0)
            }
            return
        }
        
        if let image = image {
            DispatchQueue.global().async {
                let image = UIImage(data: image)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        } else {
            imageView.snp.updateConstraints {
                $0.width.equalTo(0)
            }
        }
    }
    
    func setupUserImage(image: String?) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.setupUserImage(image: image)
            }
            return
        }
        
        guard let image else {
            userImageView.image = nil
            userImageView.isHidden = true
            userImageView.snp.updateConstraints { $0.trailing.equalTo(checkmarkView).offset(0) }
            return
        }
        userImageView.isHidden = false
        userImageView.snp.updateConstraints { $0.trailing.equalTo(checkmarkView).offset(26) }
        guard let url = URL(string: image) else {
            let image = R.image.profile_icon()
            return userImageView.image = image
        }
        let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
        userImageView.kf.setImage(with: resource, options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 30, height: 30))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
    }
    
    func setupCost(isVisible: Bool, isAddNewLine: Bool, color: UIColor?, storeTitle: String?, costValue: Double?) {
        costView.isHidden = !isVisible
        guard isVisible else {
            return
        }
        costView.configureColor(color ?? UIColor(hex: "#58B168"))
        costView.configureStore(title: storeTitle)
        costView.configureCost(value: costValue)
        secondDescriptionLabel.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(isAddNewLine ? 16 : 6)
        }
    }
    
    func setupInStock(isVisible: Bool, color: UIColor?) {
        foundInPantryView.isHidden = !isVisible
        guard isVisible else {
            return
        }
        foundInPantryView.configureColor(color)
        contentViews.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    func addCheckmark(color: UIColor?, compl: @escaping (() -> Void) ) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.checkmarkImage.image = self.getImageWithColor(color: color)
            self.nameLabel.attributedText = self.nameLabel.text?.strikeThrough()
            self.nameWithDescriptionLabel.attributedText = self.nameWithDescriptionLabel.text?.strikeThrough()
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
    
    func updateEditCheckmark(isSelect: Bool) {
        guard state == .edit else { return }
        
        guard isSelect else {
            self.checkmarkImage.image = R.image.emptyCheckmark()?.withTintColor(UIColor(hex: "#6319FF"))
            return
        }
        self.checkmarkImage.image = self.getImageWithColor(color: UIColor(hex: "#6319FF"))
    }
    
    private func setupCheckmarkImage(isPurchased: Bool, color: UIColor?) {
        guard state != .stock else {
            return
        }
        
        guard state != .edit else {
            whiteCheckmarkImage.snp.updateConstraints { $0.width.height.equalTo(8) }
            whiteCheckmarkImage.image = getImageWithColor(color: .white)
            
            checkmarkImage.image = R.image.emptyCheckmark()?.withTintColor(UIColor(hex: "#6319FF"))
            return
        }
        
        whiteCheckmarkImage.snp.updateConstraints { $0.width.height.equalTo(14) }
        whiteCheckmarkImage.image = R.image.whiteCheckmark()
        if isPurchased {
            checkmarkImage.image = getImageWithColor(color: color)
        } else {
            let emptyCheckmarkColor = UIColor(hex: "#ACB4B4")
            checkmarkImage.image = R.image.emptyCheckmark()?.withTintColor(emptyCheckmarkColor)
        }
    }
    
    // MARK: - UI
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        contentView.addSubviews([leftButton, rightButton, shadowView, contentViews])
        contentViews.addSubviews([userImageView, nameLabel, checkmarkView, checkmarkImage, whiteCheckmarkImage,
                                  imageView, viewWithDescription, costView, foundInPantryView])
        viewWithDescription.addSubviews([nameWithDescriptionLabel, secondDescriptionLabel])
        
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(contentViews)
        }
        
        contentViews.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
        
        viewWithDescription.snp.makeConstraints { make in
            make.right.equalTo(imageView.snp.left)
            make.left.equalTo(nameLabel)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        nameWithDescriptionLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        nameWithDescriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(6)
            make.height.greaterThanOrEqualTo(17)
        }
        
        secondDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameWithDescriptionLabel.snp.bottom)
            make.left.equalToSuperview()
            make.height.equalTo(17)
            make.bottom.equalToSuperview().inset(6)
        }
        
        checkmarkView.snp.makeConstraints { make in
            make.center.equalTo(checkmarkImage)
            make.width.height.equalTo(36)
        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        userImageView.snp.makeConstraints { make in
            make.trailing.equalTo(checkmarkView).offset(26)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(userImageView.snp.trailing).offset(8)
            make.trailing.equalTo(imageView.snp.leading).offset(-8)
        }
        
        whiteCheckmarkImage.snp.makeConstraints { make in
            make.center.equalTo(checkmarkImage)
            make.width.height.equalTo(14)
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
            make.right.equalToSuperview().inset(3)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        costView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-4)
            make.height.equalTo(16)
        }
        
        foundInPantryView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(-18)
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(120)
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
