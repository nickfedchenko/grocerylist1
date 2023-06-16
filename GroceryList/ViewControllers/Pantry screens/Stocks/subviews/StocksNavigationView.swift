//
//  StocksNavigationView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.06.2023.
//

import UIKit

protocol StocksNavigationViewDelegate: AnyObject {
    func tapOnBackButton()
    func tapOnSharingButton()
    func tapOnSettingButton()
    func tapOnOutButton()
}
 
final class StocksNavigationView: UIView {
    
    weak var delegate: StocksNavigationViewDelegate?
    
    private let container = UIView()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.greenArrowBack()?.withTintColor(.white),
                        for: .normal)
        button.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var sharingView: SharingView = {
        let view = SharingView()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedSharingButton))
        view.addGestureRecognizer(tapRecognizer)
        return view
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.contextMenu()?.withTintColor(.white),
                        for: .normal)
        button.addTarget(self, action: #selector(tappedSettingButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let capitalLetterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFProRounded.heavy(size: 22).font
        label.textAlignment = .center
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFPro.bold(size: 22).font
        return label
    }()
    
    private lazy var outOfStocksView: UIView = {
        let view = UIView()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutButton))
        view.addGestureRecognizer(tapRecognizer)
        return view
    }()

    private lazy var outOfStocksShadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.addDefaultShadowForPopUp()
        view.layer.shadowOpacity = 0
        return view
    }()
    
    private lazy var outLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.SFProRounded.semibold(size: 14).font
        return label
    }()
    
    private lazy var totalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 14).font
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = .white
        container.layer.cornerRadius = 24
        container.layer.maskedCorners = [.layerMaxXMaxYCorner]
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureColor(theme: Theme) {
        container.backgroundColor = theme.medium
        outOfStocksView.backgroundColor = theme.dark
        totalLabel.textColor = theme.dark
        outOfStocksShadowView.backgroundColor = theme.medium
    }
    
    func configureOutOfStock(total: String, outOfStock: String) {
        totalLabel.text = total
        guard !outOfStock.isEmpty else {
            outOfStocksView.isHidden = true
            outOfStocksShadowView.isHidden = true
            outLabel.isHidden = true
            totalView.layer.cornerRadius = 12
            totalView.layer.cornerCurve = .continuous
            return
        }
        outOfStocksView.isHidden = false
        outOfStocksShadowView.isHidden = false
        outLabel.isHidden = false
        outLabel.text = R.string.localizable.out() + outOfStock
    }
    
    func setShadowOutOfStockView(isVisible: Bool) {
        outOfStocksShadowView.layer.shadowOpacity = isVisible ? 0.15 : 0
        outOfStocksView.makeCustomRound(topLeft: 12, topRight: 4,
                                        bottomLeft: 12, bottomRight: 4, hasBorder: isVisible)
    }
    
    func setupCustomRoundIfNeeded() {
        guard !outOfStocksView.isHidden else {
            return
        }
        totalView.layer.cornerRadius = 0
        totalView.makeCustomRound(topLeft: 4, topRight: 12,
                                  bottomLeft: 4, bottomRight: 12)
        outOfStocksView.makeCustomRound(topLeft: 12, topRight: 4,
                                        bottomLeft: 12, bottomRight: 4, hasBorder: true)
    }
    
    func configureTitle(icon: UIImage?, title: String) {
        if let icon {
            iconImageView.image = icon.withTintColor(.white)
            capitalLetterLabel.isHidden = true
        } else {
            iconImageView.isHidden = true
            capitalLetterLabel.text = title.first?.uppercased()
        }
        titleLabel.text = title
    }
    
    func configureSharingView(sharingState: SharingView.SharingState,
                              sharingUsers: [String?], color: UIColor) {
        sharingView.configure(state: sharingState, viewState: .pantry,
                              color: color, images: sharingUsers)
    }
    
    @objc
    private func tappedBackButton() {
        delegate?.tapOnBackButton()
    }
    
    @objc
    private func tappedSharingButton() {
        delegate?.tapOnSharingButton()
    }
    
    @objc
    private func tappedSettingButton() {
        delegate?.tapOnSettingButton()
    }
    
    @objc
    private func tappedOutButton() {
        delegate?.tapOnOutButton()
    }
    
    private func makeConstraints() {
        self.addSubview(container)
        container.addSubviews([backButton, sharingView, settingsButton,
                               iconImageView, capitalLetterLabel, titleLabel,
                               outOfStocksShadowView, outOfStocksView, outLabel, totalView, totalLabel])
        
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        sharingView.snp.makeConstraints {
            $0.trailing.equalTo(settingsButton.snp.leading).offset(-16)
            $0.centerY.equalTo(settingsButton)
            $0.height.equalTo(40)
        }
        
        settingsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.width.height.equalTo(32)
        }
        
        capitalLetterLabel.snp.makeConstraints {
            $0.center.equalTo(iconImageView)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
            $0.centerY.equalTo(iconImageView)
        }
        
        makeOutOfStocksViewConstraints()
    }
    
    private func makeOutOfStocksViewConstraints() {
        outOfStocksShadowView.snp.makeConstraints {
            $0.edges.equalTo(outOfStocksView)
        }
        
        outOfStocksView.snp.makeConstraints {
            $0.trailing.equalTo(totalView.snp.leading).offset(-4)
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.equalTo(24)
            $0.width.equalTo(54)
        }
        
        outLabel.snp.makeConstraints {
            $0.center.equalTo(outOfStocksView)
            $0.leading.equalTo(outOfStocksView)
        }
        
        totalView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().offset(-12)
            $0.height.equalTo(24)
            $0.width.equalTo(56)
        }
        
        totalLabel.snp.makeConstraints {
            $0.center.equalTo(totalView)
            $0.leading.equalTo(totalView)
        }
    }
}
