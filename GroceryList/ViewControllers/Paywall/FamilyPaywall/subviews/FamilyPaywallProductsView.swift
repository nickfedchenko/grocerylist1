//
//  FamilyPaywallProductsView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.11.2023.
//

import UIKit

protocol FamilyPaywallProductsDelegate: AnyObject {
    func changeFamilySwitch(value: Bool)
}

class FamilyPaywallProductsView: UIView {
    
    weak var delegate: BottomProductsViewDelegate?
    weak var familyDelegate: FamilyPaywallProductsDelegate?
    
    private let contentView = UIView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let familyPlanView = FamilyPaywallProductView()
    
    private let familyPlanIncludedImage: UIImageView = {
        let view = UIImageView()
        view.image = R.image.familyPlanIncluded()
        view.isHidden = true
        return view
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        let font = UIFont.SFProDisplay.semibold(size: 20).font ?? UIFont()
        let attributedTitle = NSAttributedString(string: R.string.localizable.next().uppercased(),
                                                 attributes: [.font: font,
                                                              .foregroundColor: UIColor.white])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = R.color.primaryDark()
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        button.setImage(R.image.nextArrow(), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.privacyPolicy(), for: .normal)
        button.setTitleColor(UIColor(hex: "#1A645A"), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.medium(size: 12).font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .left
        button.addTarget(self, action: #selector(privacyDidTap), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("  " + R.string.localizable.cancelAnytime(), for: .normal)
        button.setTitleColor(UIColor(hex: "#1A645A"), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.medium(size: UIDevice.isSE2 ? 12 : 15).font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.1
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setImage(R.image.paywall_lock(), for: .normal)
        return button
    }()
    
    private lazy var termsButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.termOfUse(), for: .normal)
        button.setTitleColor(UIColor(hex: "#1A645A"), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.medium(size: 12).font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .right
        button.addTarget(self, action: #selector(termsDidTap), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        contentView.backgroundColor = .clear
        
        familyPlanView.configureFamilyPlan()
        familyPlanView.changeSwitch = { [weak self] isOn in
            self?.familyDelegate?.changeFamilySwitch(value: isOn)
        }
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(products: [PayWallModel]) {
        stackView.removeAllArrangedSubviews()
        
        products.enumerated().forEach { index, product in
            let view = FamilyPaywallProductView()
            view.configureProduct(product)
            view.tag = index
            
            view.tapProduct = { [weak self] tag in
                self?.delegate?.tapProduct(tag: tag)
            }
            stackView.addArrangedSubview(view)
        }
    }
    
    func selectProduct(_ selectProduct: Int) {
        stackView.arrangedSubviews.forEach {
            ($0 as? FamilyPaywallProductView)?.markAsSelect(selectProduct == $0.tag)
        }
    }
    
    func hideFamilyPlan() {
        familyPlanView.isHidden = true
        familyPlanIncludedImage.isHidden = false
    }
    
    @objc
    private func nextButtonPressed() {
        delegate?.continueButtonPressed()
    }
    
    @objc
    private func didTapToRestorePurchases() {
        delegate?.didTapToRestorePurchases()
    }
    
    @objc
    private func privacyDidTap() {
        delegate?.privacyDidTap()
    }
    
    @objc
    private func termsDidTap() {
        delegate?.termsDidTap()
    }
    
    private func makeConstraints() {
        self.addSubviews([contentView])
        contentView.addSubviews([stackView, familyPlanIncludedImage, familyPlanView, continueButton,
                                 cancelButton, privacyButton, termsButton])
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(UIDevice.isSEorXor12mini ? 196 : 220)
        }
        
        familyPlanIncludedImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(continueButton.snp.top).inset(-16)
        }
        
        familyPlanView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(68)
        }
        
        continueButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(familyPlanView.snp.bottom).offset(UIDevice.isSEorXor12mini ? 12 : 18)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(continueButton.snp.bottom).offset(UIDevice.isSEorXor12mini ? 9 : 16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(135)
        }
        
        privacyButton.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        privacyButton.snp.makeConstraints {
            $0.top.equalTo(continueButton.snp.bottom).offset(UIDevice.isSEorXor12mini ? 10 : 18)
            $0.leading.equalToSuperview().offset(17)
            $0.trailing.equalTo(cancelButton.snp.leading).offset(-16)
            $0.bottom.equalToSuperview()
        }
        
        termsButton.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        termsButton.snp.makeConstraints {
            $0.top.equalTo(privacyButton)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}

private final class FamilyPaywallProductView: UIView {
    
    var tapProduct: ((Int) -> Void)?
    var changeSwitch: ((Bool) -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    private let mostPopularView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FF7A00")
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    private let mostPopularLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 13).font
        label.textColor = .white
        label.text = "MostPopular".localized.uppercased()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.bold(size: 19).font
        label.textColor = R.color.primaryDark()
        return label
    }()
    
    private let perWeekLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.bold(size: 12).font
        label.textColor = R.color.primaryDark()
        label.text = " " + "/WEEK".localized.uppercased()
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 17).font
        label.textColor = R.color.primaryDark()
        label.text = "Year"
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 13).font
        label.textColor = R.color.darkGray()
        label.text = "$43.54"
        return label
    }()
    
    private let threeDaysFreeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 13).font
        label.textColor = UIColor(hex: "#657674")
        label.text = "3 days free".localized
        return label
    }()
    
    private let dotImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "paywallDot")
        return imageView
    }()
    
    private lazy var familySwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = UIColor(hex: "#31635A")
        switcher.isOn = false
        switcher.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        return switcher
    }()
    
    private let familyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.paywall_family_icon()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tapOnView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureProduct(_ product: PayWallModel) {
        periodLabel.text = product.period
        descriptionLabel.text = product.price
        let pricePerWeek = product.description.replacingOccurrences(of: " / " + R.string.localizable.perWeek(), with: "")
        priceLabel.text = pricePerWeek
        
        if pricePerWeek == product.price {
            descriptionLabel.isHidden = true
            dotImage.isHidden = true
            threeDaysFreeLabel.snp.remakeConstraints { make in
                make.left.equalTo(descriptionLabel)
                make.centerY.equalTo(descriptionLabel.snp.centerY)
            }
        } else {
            threeDaysFreeLabel.snp.remakeConstraints { make in
                make.left.equalTo(descriptionLabel.snp.right).inset(-13)
                make.centerY.equalTo(descriptionLabel.snp.centerY)
            }
        }
        mostPopularView.isHidden = !product.isPopular
        
        familySwitch.isHidden = true
        familyImage.isHidden = true
    }
    
    func configureFamilyPlan() {
        containerView.layer.borderColor = R.color.action()?.cgColor
        
        periodLabel.text = R.string.localizable.iCloudFamilyPlan()
        descriptionLabel.text = R.string.localizable.familyPlanMembers()
        
        familySwitch.isHidden = false
        familyImage.isHidden = false
        
        mostPopularView.isHidden = true
        priceLabel.isHidden = true
        perWeekLabel.isHidden = true
        threeDaysFreeLabel.isHidden = true
        dotImage.isHidden = true
    }
    
    func markAsSelect(_ select: Bool) {
        containerView.layer.borderColor = select ? UIColor(hex: "FF7A00").cgColor
                                                 : UIColor.white.cgColor
    }
    
    @objc
    private func tappedOnView() {
        tapProduct?(self.tag)
    }
    
    @objc
    private func switchValueDidChange() {
        containerView.layer.borderColor = familySwitch.isOn ? R.color.primaryDark()?.cgColor
                                                            : R.color.action()?.cgColor
        changeSwitch?(familySwitch.isOn)
    }

    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        self.addSubviews([containerView, mostPopularView])
        mostPopularView.addSubviews([mostPopularLabel])
        containerView.addSubviews([familyImage, familySwitch])
        containerView.addSubviews([priceLabel, perWeekLabel,
                                   periodLabel, descriptionLabel, threeDaysFreeLabel, dotImage])
        
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(UIDevice.isSEorXor12mini ? 64 : 72)
        }
        
        mostPopularView.snp.makeConstraints { make in
            make.right.equalTo(containerView.snp.right).inset(16)
            make.centerY.equalTo(containerView.snp.top)
            make.height.equalTo(24)
        }
        
        mostPopularLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        perWeekLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalTo(priceLabel).offset(-2)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.right.equalTo(perWeekLabel.snp.left)
            make.top.equalToSuperview().offset(23)
            make.centerY.equalToSuperview()
        }

        periodLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(UIDevice.isSEorXor12mini ? 13 : 16)
        }
        
        descriptionLabel.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().inset(UIDevice.isSEorXor12mini ? 13 : 16)
            make.left.equalToSuperview().inset(16)
        }

        threeDaysFreeLabel.snp.makeConstraints { make in
            make.left.equalTo(descriptionLabel.snp.right).inset(-13)
            make.centerY.equalTo(descriptionLabel.snp.centerY)
        }
        
        dotImage.snp.makeConstraints { make in
            make.centerY.equalTo(threeDaysFreeLabel.snp.centerY)
            make.width.height.equalTo(3)
            make.right.equalTo(threeDaysFreeLabel.snp.left).inset(-5)
        }
        
        familySwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(18)
            make.centerY.equalToSuperview()
        }
        
        familyImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(84)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(43)
        }
    }
    
}
