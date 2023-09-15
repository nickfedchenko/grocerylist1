//
//  MealPlanEmptyCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 12.09.2023.
//

import UIKit

protocol MealPlanEmptyCellDelegate: AnyObject {
    func tapAdd(state: MealPlanCellType)
}

class MealPlanEmptyCell: UICollectionViewCell {
    
    weak var delegate: MealPlanEmptyCellDelegate?
    
    private let containerView = UIView()
    
    private let plusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = R.image.mealPlanPlus()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = R.color.mediumGray()
        return label
    }()
    
    private var state: MealPlanCellType = .planEmpty
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        containerView.addGestureRecognizer(tapOnView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(state: MealPlanCellType) {
        self.state = state
        containerView.backgroundColor = state.color
        containerView.layer.borderColor = state.border.color?.cgColor
        containerView.layer.borderWidth = state.border.width
        
        titleLabel.text = state.title
    }
    
    private func setup() {
        containerView.setCornerRadius(8)
        
        makeConstraints()
    }
    
    @objc
    private func tappedOnView() {
        delegate?.tapAdd(state: state)
    }
    
    private func makeConstraints() {
        self.addSubview(containerView)
        containerView.addSubviews([plusImageView, titleLabel])
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        plusImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

private extension MealPlanCellType {
    var color: UIColor {
        switch self {
        case .planEmpty:    return UIColor(hex: "DBF6F6")
        case .noteEmpty:    return UIColor(hex: "FEFEEB")
        case .noteFilled:   return .clear
        default:            return .clear
        }
    }
    
    var title: String {
        switch self {
        case .planEmpty:
            return R.string.localizable.recipe().uppercased()
        case .noteEmpty, .noteFilled:
            return R.string.localizable.note().uppercased()
        default:
            return ""
        }
    }
    
    var border: (color: UIColor?, width: CGFloat) {
        switch self {
        case .planEmpty, .noteEmpty:
            return (UIColor.clear, 0)
        case .noteFilled:
            return (R.color.mediumGray(), 1)
        default:
            return (UIColor.clear, 0)
        }
    }
}
