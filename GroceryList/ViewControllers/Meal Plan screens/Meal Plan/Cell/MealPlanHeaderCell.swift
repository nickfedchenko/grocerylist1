//
//  MealPlanHeaderCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 12.09.2023.
//

import UIKit

protocol MealPlanHeaderCellDelegate: AnyObject {
    func addNote(_ cell: MealPlanHeaderCell)
    func addRecipe(_ cell: MealPlanHeaderCell)
}

class MealPlanHeaderCell: UICollectionReusableView {
    
    weak var delegate: MealPlanHeaderCellDelegate?
    
    private let containerView = UIView()
    private let separatorView = UIView()
    
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 13).font
        label.textColor = R.color.darkGray()
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 13).font
        label.textColor = R.color.darkGray()
        return label
    }()
    
    private lazy var addNoteButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.addNotEtoMealPlan(), for: .normal)
        button.addTarget(self, action: #selector(tappedAddNoteButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var addRecipeButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.addRecipeToMealPlan(), for: .normal)
        button.addTarget(self, action: #selector(tappedAddRecipeButton), for: .touchUpInside)
        return button
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 2
        return stackView
    }()
    
    private(set) var index: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView.backgroundColor = UIColor(hex: "D1EFEF")
        separatorView.backgroundColor = R.color.darkGray()
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        weekdayLabel.text = ""
        dateLabel.text = ""
        labelStackView.removeAllArrangedSubviews()
        separatorView.isHidden = true
        containerView.isHidden = true
    }
    
    func setupHeader(section: MealPlanSection, index: IndexPath) {
        weekdayLabel.text = section.date.getStringDate(format: "EEEE").uppercased()
        dateLabel.text = section.date.getStringDate(format: "ddMMyyyy")
        self.index = index
        let bottomOffset: Int
        let height: Int
        switch section.sectionType {
        case .week:
            bottomOffset = -8
            height = 48
            separatorView.isHidden = true
            containerView.isHidden = false
        case .weekStart:
            bottomOffset = -8
            height = 51
            separatorView.isHidden = false
            containerView.isHidden = false
        case .month:
            bottomOffset = 0
            height = 1
            separatorView.isHidden = true
            containerView.isHidden = true
        }

        containerView.snp.updateConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(bottomOffset)
            $0.height.greaterThanOrEqualTo(height)
        }
    }
    
    func configure(labelColors: [UIColor]) {
        labelStackView.removeAllArrangedSubviews()
        labelColors.enumerated().forEach { index, color in
            if index > 4 {
                return
            }
            let view = UIView()
            view.backgroundColor = color
            view.setCornerRadius(3)
            
            labelStackView.addArrangedSubview(view)
            view.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview()
                $0.width.height.equalTo(6)
            }
        }
    }
    
    @objc
    private func tappedAddNoteButton() {
        delegate?.addNote(self)
    }
    
    @objc
    private func tappedAddRecipeButton() {
        delegate?.addRecipe(self)
    }
    
    private func makeConstraints() {
        self.addSubviews([containerView])
        containerView.addSubviews([separatorView,
                                   labelStackView, weekdayLabel, dateLabel,
                                   addNoteButton, addRecipeButton])
        
        containerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
            $0.height.greaterThanOrEqualTo(1)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(3)
        }
        
        labelStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(6)
        }
        
        weekdayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(22)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(weekdayLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(22)
        }
        
        addNoteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalTo(addRecipeButton.snp.leading).offset(-24)
            $0.width.equalTo(64)
            $0.height.equalTo(32)
        }
        
        addRecipeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(64)
            $0.height.equalTo(32)
        }
    }
}
