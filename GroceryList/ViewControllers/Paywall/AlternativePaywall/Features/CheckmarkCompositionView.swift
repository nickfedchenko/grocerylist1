//
//  CheckmarkCompositionView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.01.2023.
//

import UIKit

final class CheckmarkCompositionView: UIView {
    
    private let firstView = CheckmarkView(title: "Create your own exercises".localized)
    private let seconfView = CheckmarkView(title: "Track your exercise analytics".localized)
    private let thirdView = CheckmarkView(title: "Discover your best results".localized)
    
    private lazy var parametrsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstView, seconfView, thirdView] )
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
            make.height.equalTo(88)
            make.width.equalTo(274)
        }
        
        parametrsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
