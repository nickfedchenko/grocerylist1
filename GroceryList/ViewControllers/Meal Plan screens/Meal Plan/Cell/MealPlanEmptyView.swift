//
//  MealPlanEmptyView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 12.09.2023.
//

import UIKit

class MealPlanEmptyView: UIView {
    
    enum State {
        case recipe
        case note
        case filledNote
        
        var color: UIColor {
            switch self {
            case .recipe:       return UIColor(hex: "DBF6F6")
            case .note:         return UIColor(hex: "FEFEEB")
            case .filledNote:   return .clear
            }
        }
        
        var title: String {
            switch self {
            case .recipe:
                return R.string.localizable.recipe().uppercased()
            case .note, .filledNote:
                return R.string.localizable.note().uppercased()
            }
        }
        
        var border: (color: UIColor?, width: CGFloat) {
            switch self {
            case .recipe, .note:
                return (UIColor.clear, 0)
            case .filledNote:
                return (R.color.mediumGray(), 1)
            }
        }
    }
    
    private let containerView = UIView()
    
    private let plusImageView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = R.color.mediumGray()
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(state: State) {
        containerView.backgroundColor = state.color
        containerView.layer.borderColor = state.border.color?.cgColor
        containerView.layer.borderWidth = state.border.width
        
        titleLabel.text = state.title
    }
    
    private func setup() {
        containerView.setCornerRadius(8)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubview(containerView)
        containerView.addSubviews([plusImageView, titleLabel])
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
