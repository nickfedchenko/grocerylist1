//
//  CheckmarkCompositionView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.01.2023.
//

import UIKit

final class CheckmarkCompositionView: UIView {
    
    private let firstView = CheckmarkView(
        title: "Save time and money".localized,
        using: CGFloat("Save time and money".count) / CGFloat("Save time and money".localized.count) > 1
        ? 17
        : CGFloat("Save time and money".count) / CGFloat("Save time and money".localized.count) * 17
    )
    private let seconfView = CheckmarkView(
        title: "Plan your shopping list for the week".localized,
        using: CGFloat("Plan your shopping list for the week".count) / CGFloat("Plan your shopping list for the week".localized.count) > 1
        ? 17
        : CGFloat("Plan your shopping list for the week".count) / CGFloat("Plan your shopping list for the week".localized.count) * 17
    )
    private let thirdView = CheckmarkView(
        title: "Quick add recipe ingredients into your lists".localized,
        using: CGFloat("Quick add recipe ingredients into your lists".count) / CGFloat("Quick add recipe ingredients into your lists".localized.count) > 1
        ? 17
        : CGFloat("Quick add recipe ingredients into your lists".count) / CGFloat("Quick add recipe ingredients into your lists".localized.count) * 17)
    
    private lazy var parametrsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstView, seconfView, thirdView])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - LifeCycle
    
    init() {
        super.init(frame: .zero)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constraints
    private func setupConstraint() {
        self.addSubviews([parametrsStackView])
        
        snp.makeConstraints { make in
//            make.height.equalTo(88)
            make.width.equalTo(274)
        }
        
        parametrsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
