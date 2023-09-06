//
//  NewPaywallProductView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.07.2023.
//

import UIKit

final class NewPaywallProductView: UIView {

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
        label.textAlignment = .center
        return label
    }()
    
    private let saveLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 12).font
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .center
        return label
    }()
    
    private let selectImageView = UIImageView(image: R.image.checkmarkProductNewPaywall())
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "59FFD4")
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 3
        return view
    }()
    
    private let badgeMostPopularView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let mostPopularLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.mostPopular()
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
        badgeMostPopularView.backgroundColor = UIColor(hex: "FF5C00")
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tapOnView)

        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(product: PayWallModel) {
        periodLabel.text = product.period
        priceLabel.text = product.price
        perWeekLabel.text = "(" + product.description + ")"
        
        badgeMostPopularView.isHidden = !product.isPopular
        saveLabel.isHidden = !product.isVisibleSave
        saveLabel.text = R.string.localizable.saveMoney().uppercased() + " " + product.savePrecent.asString + "%"
    }
    
    func markAsSelect(_ select: Bool) {
        borderView.layer.borderColor = select ? UIColor.white.cgColor : UIColor.clear.cgColor
        selectImageView.isHidden = !select
    }

    @objc
    private func tappedOnView() {
        tapProduct?(self.tag)
    }
    
    private func makeConstraints() {
        self.addSubviews([borderView, periodLabel, priceLabel, perWeekLabel,
                          selectImageView, badgeMostPopularView, saveLabel])
        badgeMostPopularView.addSubview(mostPopularLabel)

        borderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        periodLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
        }

        priceLabel.snp.makeConstraints {
            $0.top.equalTo(periodLabel.snp.bottom).offset(17)
            $0.centerX.equalToSuperview()
        }
        
        perWeekLabel.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(1)
            $0.leading.equalToSuperview().offset(2)
            $0.centerX.equalToSuperview()
        }
        
        saveLabel.snp.makeConstraints {
            $0.top.equalTo(perWeekLabel.snp.bottom).offset(3)
            $0.leading.equalToSuperview().offset(2)
            $0.centerX.equalToSuperview()
        }
        
        selectImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        badgeMostPopularView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.leading.greaterThanOrEqualTo(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(14)
        }
        
        mostPopularLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(2)
            $0.center.equalToSuperview()
        }
    }

}
