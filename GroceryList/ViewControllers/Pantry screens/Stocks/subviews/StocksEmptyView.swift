//
//  StocksEmptyView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.06.2023.
//

import UIKit

final class StocksEmptyView: UIView {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    private let overOpacityView = UIView()
    
    private let opacities = [1, 0.8, 0.6, 0.4, 0.2, 0.1]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(color: UIColor) {
        stackView.removeAllArrangedSubviews()
        
        opacities.forEach { opacity in
            let view = UIView()
            view.backgroundColor = color.withAlphaComponent(opacity)
            view.layer.cornerRadius = 8
            view.layer.cornerCurve = .continuous
            stackView.addArrangedSubview(view)
        }
    }
    
    private func setup() {
        overOpacityView.backgroundColor = .white.withAlphaComponent(0.25)
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([stackView, overOpacityView])
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        overOpacityView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
