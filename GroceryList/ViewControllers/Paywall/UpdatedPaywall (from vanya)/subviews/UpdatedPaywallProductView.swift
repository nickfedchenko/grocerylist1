//
//  UpdatedPaywallProductView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 12.07.2023.
//

import UIKit

final class UpdatedPaywallProductView: UIView {

    var tapProduct: ((Int) -> Void)?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(products: [PayWallModelWithSave]) {
        stackView.removeAllArrangedSubviews()
        
        products.enumerated().forEach { index, product in
            let view = ProductView()
            view.configure(product: product)
            view.tag = index
            
            view.tapProduct = { [weak self] tag in
                self?.tapProduct?(tag)
            }
            stackView.addArrangedSubview(view)
        }
        
    }
    
    func selectProduct(_ selectProduct: Int) {
        stackView.arrangedSubviews.forEach {
            ($0 as? ProductView)?.markAsSelect(selectProduct == $0.tag)
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([stackView])
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}

final private class ProductView: UIView {

    var tapProduct: ((Int) -> Void)?
    
    private let periodLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.SFProDisplay.semibold(size: 15).font
        label.textColor = .black
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.bold(size: 17).font
        label.textColor = .black
        return label
    }()
    
    private let perWeekLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 12).font
        label.textColor = R.color.darkGray()
        return label
    }()
    
    private let threeDaysFreeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.medium(size: 12).font
        label.textColor = UIColor(hex: "#045C5")
        label.text = R.string.localizable.daysFree()
        return label
    }()
    
    private let selectImageView = UIImageView(image: R.image.updatedPaywall_selectProduct())
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "DDFFF6")
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 3
        return view
    }()
    
    private let badgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 12).font
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hex: "DDFFF6")
        self.layer.cornerRadius = 8
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tapOnView)
        
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(product: PayWallModelWithSave) {
        periodLabel.text = product.period
        priceLabel.text = product.price
        perWeekLabel.text = product.description + R.string.localizable.weeK().lowercased()
        
        badgeView.isHidden = !product.isVisibleBadge
        badgeView.backgroundColor = product.badgeColor
        badgeLabel.text = R.string.localizable.saveMoney().uppercased() + " " + product.savePrecent.asString + "%"
    }
    
    func markAsSelect(_ select: Bool) {
        borderView.layer.borderColor = select ? UIColor(hex: "045C5C").cgColor : UIColor.clear.cgColor
        selectImageView.isHidden = !select
    }

    @objc
    private func tappedOnView() {
        tapProduct?(self.tag)
    }
    
    private func makeConstraints() {
        self.addSubviews([borderView, periodLabel, priceLabel, perWeekLabel, threeDaysFreeLabel,
                          selectImageView, badgeView])
        badgeView.addSubview(badgeLabel)

        borderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        periodLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
        }

        priceLabel.snp.makeConstraints {
            $0.top.equalTo(periodLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        perWeekLabel.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }
        
        threeDaysFreeLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-8)
            $0.centerX.equalToSuperview()
        }
        
        selectImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        badgeView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-7)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(16)
        }
        
        badgeLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(2)
            $0.center.equalToSuperview()
        }
    }

}
