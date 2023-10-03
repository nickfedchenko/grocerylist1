//
//  AddIngredientsToListHeaderCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.10.2023.
//

import SnapKit
import UIKit

class AddIngredientsToListHeaderCell: UICollectionReusableView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.darkGray()
        return view
    }()
    
    private let collapsedColoredView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.backgroundColor = R.color.darkGray()
        view.isHidden = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 16).font
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private var titleTrailingConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        collapsedColoredView.roundCorners(topRight: 20, bottomRight: 4)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = ""
        titleLabel.text = ""
        
        titleTrailingConstraint?.isActive = true
        containerView.backgroundColor = R.color.darkGray()
        collapsedColoredView.isHidden = true
        dateLabel.isHidden = false

        containerView.snp.updateConstraints {
            $0.height.equalTo(48)
        }
    }

    func configure(model: AddIngredientsToListHeaderModel) {
        titleLabel.text = model.title
        
        guard model.type == .category else {
            dateLabel.text = model.date.getStringDate(format: "ddMMyy")
            return
        }
        
        titleTrailingConstraint?.isActive = false
        containerView.backgroundColor = .clear
        collapsedColoredView.isHidden = false
        dateLabel.isHidden = true
        
        containerView.snp.updateConstraints {
            $0.height.equalTo(32)
        }
    }

    private func makeConstraints() {
        self.addSubviews([containerView])
        containerView.addSubviews([collapsedColoredView, titleLabel, dateLabel])

        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-8)
            $0.height.equalTo(48)
        }
        
        collapsedColoredView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(titleLabel).offset(28)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview().offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            titleTrailingConstraint = $0.trailing.equalTo(dateLabel.snp.leading).offset(-8).constraint
        }
        
        dateLabel.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        dateLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }
}
