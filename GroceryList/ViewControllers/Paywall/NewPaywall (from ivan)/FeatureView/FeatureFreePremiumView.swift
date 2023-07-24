//
//  FeatureFreePremiumView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.07.2023.
//

import UIKit

class FeatureFreePremiumView: UIView {
    
    enum State {
        case free
        case premium
        
        var title: String {
            switch self {
            case .free:     return "free".uppercased()
            case .premium:  return "prem".uppercased()
            }
        }
        
        var color: UIColor {
            switch self {
            case .free:     return UIColor(hex: "00A3A3")
            case .premium:  return UIColor(hex: "045C5C")
            }
        }
    }
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFPro.bold(size: 13).font
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.textAlignment = .center
        return label
    }()

    init(state: State) {
        super.init(frame: .zero)
        
        titleLabel.text = state.title
        self.backgroundColor = state.color
        
        self.layer.cornerRadius = 4
        self.layer.cornerCurve = .continuous
        
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel])

        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
