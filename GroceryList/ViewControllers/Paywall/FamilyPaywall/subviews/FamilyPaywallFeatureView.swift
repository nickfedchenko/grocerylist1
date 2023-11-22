//
//  FamilyPaywallFeatureView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.11.2023.
//

import UIKit

class FamilyPaywallFeatureView: UIView {
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()
    
    private let features: [String] = [
        R.string.localizable.saveTimeAndMoney(),
        R.string.localizable.planYourShoppingListForTheWeek(),
        R.string.localizable.addRecipesAndShareThem()
    ]
    
    init() {
        super.init(frame: .zero)
        setupConstraint()
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStackView() {
        features.forEach { feature in
            let view = FamilyPaywallFeatureSubView()
            view.configure(title: feature)
            view.layoutIfNeeded()
            stackView.addArrangedSubview(view)
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Constraints
    private func setupConstraint() {
        self.addSubviews([stackView])
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.greaterThanOrEqualTo(32)
        }
    }
}

private final class FamilyPaywallFeatureSubView: UIView {

    private lazy var checkmarkImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "paywallCheckmark")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        var view = UILabel()
        view.textColor = UIColor(hex: "617774")
        view.font = UIFont.SFPro.semibold(size: UIDevice.isSEorXor12mini ? 13 : 15).font
        view.numberOfLines = 0
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Constraints
    private func setupConstraint() {
        self.addSubviews([checkmarkImage, titleLabel])
        
        checkmarkImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        titleLabel.setContentHuggingPriority(.init(1000), for: .vertical)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(2)
            make.height.greaterThanOrEqualTo(20)
        }
    }
}
