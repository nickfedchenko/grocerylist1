//
//  HeaderListCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.11.2022.
//

import Kingfisher
import SnapKit
import UIKit

class HeaderListCell: UICollectionViewListCell {
    
    var tapSortPurchased: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let coloredView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let checkmarkView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.image = R.image.chevronDown()
        view.tintColor = UIColor(hex: "#58B368")
        view.transform = CGAffineTransform(rotationAngle: .pi )
        return view
    }()
    
    let collapsedColoredView: CorneredView = {
        let view = CorneredView()
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    private let coloredViewForSorting: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.layer.cornerCurve = .continuous
        view.isHidden = true
        return view
    }()
    
    private let checkmarkForSorting: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "sheckmarkForSorting")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 15).font
        label.textColor = .white
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .white
        return label
    }()
    
    private let pinchView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "blackPinch")
        imageView.isHidden = true
        return imageView
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1.5
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.layer.cornerCurve = .continuous
        imageView.image = nil
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(sortButtonPressed), for: .touchUpInside)
        button.setImage(R.image.sort()?.withTintColor(.white), for: .normal)
        return button
    }()
    
    private let purchasedCostLabel = UILabel()
    private var purchasedCostHeight = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.backgroundConfiguration = .clear()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pinchView.isHidden = true
        checkmarkView.isHidden = false
        coloredViewForSorting.isHidden = true
        dateLabel.isHidden = true
        purchasedCostLabel.isHidden = true
        coloredView.backgroundColor = .clear
        collapsedColoredView.backgroundColor = .clear
        titleLabel.textColor = .white
        titleLabel.font = UIFont.SFPro.semibold(size: 15).font
        titleLabel.numberOfLines = 1
        userImageView.image = nil
        userImageView.layer.borderColor = UIColor.clear.cgColor
        
        resetConstraints()
    }
    
    func collapsing(color: UIColor?, typeOfCell: TypeOfCell) {
        guard typeOfCell != .sortedByRecipe else {
            return
        }
        let isPurchased = typeOfCell == .purchased
        UIView.animate(withDuration: 0.5) {
            if !isPurchased {
                self.coloredView.backgroundColor = color
            } else {
                self.checkmarkView.tintColor = color
            }
        }
        
        UIView.animate(withDuration: 0.25, delay: .zero, options: .curveEaseOut) {
            self.checkmarkView.transform = CGAffineTransform(rotationAngle: .pi * 2)
            self.checkmarkView.tintColor = .white
            self.pinchView.tintColor = .white
        }
    }
    
    func expanding(color: UIColor?, typeOfCell: TypeOfCell) {
        guard typeOfCell != .sortedByRecipe else {
            return
        }
        let isPurchased = typeOfCell == .purchased
        UIView.animate(withDuration: 0.5) {
            if !isPurchased {
                self.coloredView.backgroundColor = .clear
            }
        }
        UIView.animate(withDuration: 0.25, delay: .zero, options: .curveEaseOut) {
            self.checkmarkView.transform = CGAffineTransform(rotationAngle: -.pi )
            self.checkmarkView.tintColor = isPurchased ? .white : color
            self.pinchView.tintColor = color
        }
    }
    
    func setupCell(text: String?, color: UIColor?, bcgColor: UIColor?, isExpand: Bool, typeOfCell: TypeOfCell) {
        checkmarkView.tintColor = color
        checkmarkView.transform = CGAffineTransform(rotationAngle: isExpand ? -.pi : .pi * 2)
        containerView.backgroundColor = .clear
        sortButton.isHidden = typeOfCell != .purchased

        switch typeOfCell {
        case .favorite:
            titleLabel.text = ""
            pinchView.isHidden = false
            pinchView.tintColor = color
            if !isExpand { coloredView.backgroundColor = color }
        case .purchased:
            setupPurchasedCell(color, text)
        case .sortedByAlphabet:
            setupAlphabeticalSortedCell(color)
        case .normal, .sortedByDate, .sortedByUser:
            titleLabel.text = text
            collapsedColoredView.backgroundColor = color
            if !isExpand {
                coloredView.backgroundColor = color
            }
        case .sortedByRecipe:
            setupRecipeCell(text, color)
        case .withoutCategory:
            titleLabel.text = ""
            checkmarkView.isHidden = true
            containerView.snp.updateConstraints { make in
                make.height.equalTo(10 + purchasedCostHeight).priority(1000)
            }
        case .displayCostSwitch: return
        }
    }
    
    func setupDate(date: Date?) {
        guard let date else {
            dateLabel.isHidden = true
            titleLabel.snp.updateConstraints { make in
                make.right.equalTo(collapsedColoredView.snp.right).offset(30)
            }
            return
        }
        dateLabel.isHidden = false
        dateLabel.text = date.getStringDate(format: "MMM d")
    }
    
    func setupUserImage(image: String?, color: UIColor?) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.setupUserImage(image: image, color: color)
            }
            return
        }
        
        guard let image else { return }
        userImageView.isHidden = false
        userImageView.layer.borderColor = color?.cgColor
        titleLabel.snp.updateConstraints { make in
            make.right.equalTo(collapsedColoredView.snp.right).offset(-44)
        }
        guard let url = URL(string: image) else {
            let image = R.image.profile_icon()
            return userImageView.image = image
        }
        let size = CGSize(width: 30, height: 30)
        userImageView.kf.setImage(with: url, placeholder: nil,
                                  options: [.processor(DownsamplingImageProcessor(size: size)),
                                            .scaleFactor(UIScreen.main.scale),
                                            .cacheOriginalImage])
        
    }
    
    func setupTotalCost(isVisible: Bool, color: UIColor?, purchasedCost: Double?, typeOfCell: TypeOfCell) {
        guard isVisible, typeOfCell == .purchased else {
            purchasedCostLabel.isHidden = true
            purchasedCostLabel.snp.updateConstraints {
                $0.top.equalTo(coloredView.snp.bottom).offset(0)
                $0.height.equalTo(0)
            }
            return
        }
        
        let title = R.string.localizable.purchasedCost()
        let currency = (Locale.current.currencySymbol ?? "")
        var cost = ""
        if let totalCost = purchasedCost {
            cost = "\(totalCost)"
        } else {
            cost = "---"
        }
        
        let titleFont = UIFont.SFPro.medium(size: 16).font ?? .systemFont(ofSize: 16)
        let costFont = UIFont.SFPro.semibold(size: 16).font ?? .systemFont(ofSize: 16)
        
        let titleAttr = NSMutableAttributedString(string: title,
                                                  attributes: [.font: titleFont,
                                                               .foregroundColor: color ?? .black])
        let costAttr = NSAttributedString(string: cost + " " + currency,
                                          attributes: [.font: costFont,
                                                       .foregroundColor: color ?? .black])
        titleAttr.append(costAttr)
        purchasedCostLabel.attributedText = titleAttr
        purchasedCostLabel.textAlignment = .right
        purchasedCostLabel.isHidden = false
        purchasedCostLabel.snp.updateConstraints {
            $0.top.equalTo(coloredView.snp.bottom).offset(8)
            $0.height.equalTo(19)
        }
        purchasedCostHeight = 25
    }
    
    private func setupPurchasedCell(_ color: UIColor?, _ text: String?) {
        titleLabel.font = UIFont.SFPro.semibold(size: 18).font
        coloredView.backgroundColor = color
        titleLabel.textColor = .white
        titleLabel.text = text
        titleLabel.snp.updateConstraints { make in
            make.centerY.equalTo(collapsedColoredView.snp.centerY).offset(-5)
        }
        collapsedColoredView.backgroundColor = color
        checkmarkView.tintColor = .white
    }
    
    private func setupAlphabeticalSortedCell(_ color: UIColor?) {
        checkmarkView.isHidden = true
        titleLabel.text = "AlphabeticalSorted".localized
        coloredViewForSorting.backgroundColor = color
        coloredViewForSorting.isHidden = false
    }

    private func setupRecipeCell(_ text: String?, _ color: UIColor?) {
        checkmarkView.isHidden = true
        titleLabel.font = UIFont.SFPro.bold(size: 16).font
        titleLabel.text = text
        titleLabel.numberOfLines = 2
        coloredView.backgroundColor = color

        containerView.snp.updateConstraints { make in
            make.height.equalTo(64 + purchasedCostHeight).priority(1000)
        }
        
        coloredView.snp.updateConstraints { make in
            make.height.equalTo(48)
        }
        
        collapsedColoredView.snp.updateConstraints { make in
            make.height.equalTo(48)
        }
        
        titleLabel.snp.updateConstraints { make in
            make.right.equalTo(collapsedColoredView.snp.right).offset(-46)
        }
    }
    
    private func resetConstraints() {
        purchasedCostLabel.snp.updateConstraints {
            $0.top.equalTo(coloredView.snp.bottom).offset(0)
            $0.height.equalTo(0)
        }
        titleLabel.snp.updateConstraints { make in
            make.centerY.equalTo(collapsedColoredView.snp.centerY)
            make.right.equalTo(collapsedColoredView.snp.right).offset(-26)
        }
        containerView.snp.updateConstraints { make in
            make.height.equalTo(56 + purchasedCostHeight).priority(1000)
        }
        collapsedColoredView.snp.updateConstraints { make in
            make.height.equalTo(32)
        }
        coloredView.snp.updateConstraints { make in
            make.height.equalTo(40)
        }
    }
    
    @objc
    private func sortButtonPressed() {
        tapSortPurchased?()
    }
    
    // MARK: - UI
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        contentView.addSubviews([containerView, dateLabel])
        containerView.addSubviews([coloredView, collapsedColoredView, coloredViewForSorting,
                                   titleLabel, checkmarkView, pinchView, userImageView,
                                   purchasedCostLabel, sortButton])
        coloredViewForSorting.addSubview(checkmarkForSorting)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(56 + purchasedCostHeight).priority(1000)
        }
        
        coloredView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
        
        collapsedColoredView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.lessThanOrEqualTo(checkmarkView.snp.left).offset(-4)
            make.height.equalTo(32)
            make.bottom.equalTo(coloredView)
        }
        
        coloredViewForSorting.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(checkmarkForSorting.snp.right).inset(-18)
            make.height.equalTo(40)
            make.top.equalToSuperview().inset(12)
        }
        
        checkmarkForSorting.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).inset(-22)
            make.width.equalTo(12)
            make.height.equalTo(7)
            make.centerY.equalTo(titleLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.right.equalTo(collapsedColoredView.snp.right).offset(-26)
            make.centerY.equalTo(collapsedColoredView.snp.centerY)
        }
        
        checkmarkView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.width.equalTo(19)
            make.height.equalTo(11)
            make.centerY.equalTo(coloredView.snp.centerY)
        }
        
        sortButton.snp.makeConstraints { make in
            make.trailing.equalTo(checkmarkView.snp.leading).offset(-16)
            make.width.height.equalTo(40)
            make.centerY.equalTo(coloredView.snp.centerY)
        }
        
        pinchView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalTo(coloredView.snp.centerY)
            make.width.equalTo(26)
        }
        
        userImageView.snp.makeConstraints { make in
            make.centerY.equalTo(collapsedColoredView)
            make.trailing.equalTo(collapsedColoredView).offset(0)
            make.width.height.equalTo(32)
        }
        
        purchasedCostLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(coloredView.snp.bottom).offset(8)
            make.height.equalTo(19)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
        }
    }
}

class CorneredView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        makeCustomRound(topLeft: 0, topRight: 20, bottomLeft: 0, bottomRight: 4)
    }
}
