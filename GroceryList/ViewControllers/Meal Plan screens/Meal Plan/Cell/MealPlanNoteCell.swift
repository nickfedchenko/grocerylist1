//
//  MealPlanNoteCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 25.09.2023.
//

import SnapKit
import UIKit

class MealPlanNoteCell: UICollectionViewCell {

    weak var mealPlanDelegate: MealPlanCellDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "FEFEEB")
        view.setCornerRadius(8)
        view.addShadow(color: UIColor(hex: "858585"), opacity: 0.1,
                       radius: 6, offset: .init(width: 0, height: 4))
        view.layer.masksToBounds = false
        return view
    }()
    
    private let mealPlanLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 12).font
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 16).font
        label.textColor = .black
        label.numberOfLines = 2
        label.clipsToBounds = false
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 14).font
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 2
        
        stackView.setCornerRadius(8)
        return stackView
    }()
    
    private var stackViewTopConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stackView.removeAllArrangedSubviews()
        if !(mealPlanLabel.text?.isEmpty ?? true) {
            stackView.addArrangedSubview(mealPlanLabel)
            
            mealPlanLabel.snp.makeConstraints {
                $0.height.equalTo(14)
            }
        }
        
        stackView.addArrangedSubview(titleLabel)
        
        if !(detailsLabel.text?.isEmpty ?? true) {
            stackView.addArrangedSubview(detailsLabel)
        }
        
        stackViewTopConstraint?.isActive = !(detailsLabel.text?.isEmpty ?? true)
    }
    
    func configure(title: String, details: String?) {
        titleLabel.text = title
        detailsLabel.text = details
        
        titleLabel.setMaximumLineHeight(value: 20)
    }
    
    func configureMealPlanLabel(text: String, color: UIColor) {
        mealPlanLabel.text = text
        mealPlanLabel.textColor = color
    }
    
    private func makeConstraints() {
        self.contentView.addSubview(containerView)
        containerView.addSubviews([stackView])

        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(64)
            $0.height.lessThanOrEqualTo(72)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        stackView.snp.makeConstraints {
            stackViewTopConstraint = $0.top.bottom.greaterThanOrEqualToSuperview().inset(8).constraint
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
