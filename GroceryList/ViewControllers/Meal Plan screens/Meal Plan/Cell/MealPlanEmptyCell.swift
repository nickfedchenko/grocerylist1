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
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    
    private let plusImageView: UIImageView = {
        let imageView = UIImageView()
        let color = R.color.darkGray() ?? .black
        imageView.image = R.image.mealPlanPlus()?.withTintColor(color)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = R.color.darkGray()
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
        
        if state == .planEmpty || state == .noteEmpty {
            setupShadowView()
        }
    }
    
    private func setup() {
        containerView.setCornerRadius(8)
        
        makeConstraints()
    }
    
    private func setupShadowView() {
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.backgroundColor = UIColor(hex: "#DBF6F6")
            shadowView.layer.cornerRadius = 8
        }
        shadowOneView.addShadow(color: UIColor(hex: "#484848"),
                                      opacity: 0.15,
                                      radius: 1,
                                      offset: .init(width: 0, height: 0.5))
        shadowTwoView.addShadow(color: UIColor(hex: "#858585"),
                                      opacity: 0.1,
                                      radius: 6,
                                      offset: .init(width: 0, height: 4))
    }
    
    @objc
    private func tappedOnView() {
        delegate?.tapAdd(state: state)
    }
    
    private func makeConstraints() {
        self.addSubviews([shadowOneView, shadowTwoView, containerView])
        containerView.addSubviews([plusImageView, titleLabel])
        
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalTo(containerView) }
        }
        
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
