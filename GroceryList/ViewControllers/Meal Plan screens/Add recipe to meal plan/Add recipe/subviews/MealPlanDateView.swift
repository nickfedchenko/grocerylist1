//
//  MealPlanDateView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.09.2023.
//

import UIKit

protocol MealPlanDateViewDelegate: AnyObject {
    func selectDate()
}

class MealPlanDateView: UIView {
    
    weak var delegate: MealPlanDateViewDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(8)
        view.addShadow(color: .init(hex: "858585"), opacity: 0.1,
                       radius: 6, offset: .init(width: 0, height: 4))
        return view
    }()
    
    private let actionView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = R.color.darkGray()
        label.text = R.string.localizable.date()
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = R.color.primaryDark()
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.chevron()
        return imageView
    }()
    
    private(set) var currentDate: Date = Date()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(date: Date = Date()) {
        currentDate = date
        dateLabel.text = date.getStringDate(format: "EEMMMdyyyy")
    }
    
    private func setup() {
        let tapOnDate = UITapGestureRecognizer(target: self, action: #selector(tappedOnDate))
        actionView.addGestureRecognizer(tapOnDate)
        
        makeConstraints()
    }
    
    @objc
    private func tappedOnDate() {
        Vibration.medium.vibrate()
        delegate?.selectDate()
    }
    
    private func makeConstraints() {
        self.addSubview(containerView)
        containerView.addSubviews([actionView, titleLabel, dateLabel, chevronImageView])
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        actionView.snp.makeConstraints {
            $0.leading.equalTo(dateLabel)
            $0.trailing.verticalEdges.equalToSuperview()
        }
        
        chevronImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-4)
            $0.width.height.equalTo(24)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
        }
    }
}
