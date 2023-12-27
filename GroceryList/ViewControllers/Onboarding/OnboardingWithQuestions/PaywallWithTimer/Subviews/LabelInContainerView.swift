//
//  LabelInContainerView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 27.12.2023.
//

import Foundation
import UIKit

final class LabelInContainerView: UIView {
    
    private var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#00B59B")
        label.font = R.font.sfProTextSemibold(size: 16)
        label.text = R.string.localizable.onboardingWithQuestionsPaywallOnlyOneHour().uppercased()
        return label
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String) {
        label.text = text
    }
}

extension LabelInContainerView {
    // MARK: - SetupView
    private func setupView() {
        addSubview()
        setupConstraint()
        setupLayers()
    }
    
    private func setupLayers() {
        self.backgroundColor = UIColor(hex: "#E8FEFE")
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    private func addSubview() {
        addSubviews([label])
    }
    
    private func setupConstraint() {
        label.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(4)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
    }
}
