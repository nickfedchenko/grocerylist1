//
//  EditTabBarView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.04.2023.
//

import UIKit

protocol EditTabBarViewDelegate: AnyObject {
    func tappedSelectAll()
    func tappedMove()
    func tappedCopy()
    func tappedDelete()
    func tappedClearAll()
}

final class EditTabBarView: ViewWithOverriddenPoint {

    weak var delegate: EditTabBarViewDelegate?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var countItemSelectedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFCompactDisplay.semibold(size: 14).font
        label.textColor = UIColor(hex: "#7E19FF")
        return label
    }()
    
    private let countItemSelectedView = UIView()
    private let deleteAlertView = EditDeleteAlertView()
    private let selectAllView = EditTabBarItemView(state: .selectAll(isSelect: true))
    private let moveView = EditTabBarItemView(state: .move)
    private let copyView = EditTabBarItemView(state: .copy)
    private let deleteView = EditTabBarItemView(state: .delete)
    
    private var allItemView: [EditTabBarItemView] {
        [selectAllView, moveView, copyView, deleteView]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setCountSelectedItems(_ count: Int) {
        guard count > 0 else {
            updateItemSelectedViewConstraint(with: 2, alpha: 0)
            allItemView.forEach {
                $0.setColor($0.state.deselectColor)
                if $0 != selectAllView {
                    $0.isUserInteractionEnabled = false
                }
            }
            return
        }
        countItemSelectedLabel.text = R.string.localizable.itemSelected("\(count)")
        updateItemSelectedViewConstraint(with: 36, alpha: 1)
        allItemView.forEach {
            $0.setColor($0.state.selectColor)
            $0.isUserInteractionEnabled = true
        }
    }
    
    func isSelectAll(_ isSelectAll: Bool) {
        selectAllView.state = EditTabBarItemState.selectAll(isSelect: !isSelectAll)
    }
    
    private func setup() {
        self.backgroundColor = .white
        countItemSelectedView.backgroundColor = UIColor(hex: "#EBFEFE")
        allItemView.forEach {
            $0.delegate = self
            stackView.addArrangedSubview($0)
            if $0 != selectAllView {
                $0.isUserInteractionEnabled = false
            }
        }
        
        deleteAlertView.deleteTapped = { [weak self] in
            self?.delegate?.tappedDelete()
            self?.updateDeleteAlertViewConstraint(with: 0)
        }
        
        deleteAlertView.cancelTapped = { [weak self] in
            self?.updateDeleteAlertViewConstraint(with: 0)
        }

        makeConstraints()
    }
    
    private func updateItemSelectedViewConstraint(with height: Double, alpha: Double) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.countItemSelectedLabel.alpha = alpha
            self?.countItemSelectedView.snp.updateConstraints {
                $0.height.equalTo(height)
            }
            self?.layoutIfNeeded()
        }
    }
    
    private func updateDeleteAlertViewConstraint(with height: Double) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.deleteAlertView.snp.updateConstraints {
                $0.height.equalTo(height)
            }
            self?.layoutIfNeeded()
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([stackView, countItemSelectedView, deleteAlertView])
        countItemSelectedView.addSubview(countItemSelectedLabel)
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        countItemSelectedView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.snp.top).offset(2)
            $0.height.equalTo(2)
        }
        
        countItemSelectedLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        deleteAlertView.snp.makeConstraints {
            $0.leading.centerX.bottom.equalToSuperview()
            $0.height.equalTo(0)
        }
    }
}

extension EditTabBarView: EditTabBarItemViewDelegate {
    fileprivate func tappedItem(state: EditTabBarItemState) {
        switch state {
        case .selectAll(let isSelect):
            if isSelect {
                delegate?.tappedSelectAll()
            } else {
                delegate?.tappedClearAll()
            }
            isSelectAll(isSelect)
        case .move:     delegate?.tappedMove()
        case .copy:     delegate?.tappedCopy()
        case .delete:   updateDeleteAlertViewConstraint(with: 224)
        }
    }
}

private protocol EditTabBarItemViewDelegate: AnyObject {
    func tappedItem(state: EditTabBarItemState)
}

private final class EditTabBarItemView: UIView {
    
    weak var delegate: EditTabBarItemViewDelegate?
    
    var titleLabel = UILabel()
    var imageView = UIImageView()
    var state: EditTabBarItemState {
        didSet {
            switch state {
            case .selectAll:
                titleLabel.text = state.title
                let expandTransform: CGAffineTransform = CGAffineTransformMakeScale(1.1, 1.1)
                UIView.transition(with: self.imageView, duration: 0.1,
                                  options: .transitionCrossDissolve, animations: {
                    self.imageView.image = self.state.image
                    self.imageView.transform = expandTransform
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.4,
                                   initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
                        self.imageView.transform = CGAffineTransformInvert(expandTransform)
                    }, completion: nil)
                })
            default: break
            }
        }
    }
    
    init(state: EditTabBarItemState) {
        self.state = state
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        state = .selectAll(isSelect: true)
        super.init(coder: aDecoder)
    }
    
    func setColor(_ color: UIColor) {
        titleLabel.textColor = color
        imageView.image = imageView.image?.withTintColor(color)
    }
    
    private func setup() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tapRecognizer)

        titleLabel.text = state.title
        
        if let locale = Locale.current.languageCode,
           let currentLocale = CurrentLocale(rawValue: locale),
           (currentLocale == .fr || currentLocale == .ru || currentLocale == .de) {
            titleLabel.font = UIFont.SFCompactDisplay.medium(size: 13).font
            titleLabel.allowsDefaultTighteningForTruncation = true
            titleLabel.setMaximumLineHeight(value: 12)
        } else {
            titleLabel.font = UIFont.SFCompactDisplay.semibold(size: 14).font
        }

        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        imageView.image = state.image
        
        setColor(state.deselectColor)
        makeConstraints()
    }
    
    @objc
    private func tappedOnView() {
        delegate?.tappedItem(state: state)
    }
    
    private func makeConstraints() {
        self.addSubviews([imageView, titleLabel])
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(24)
        }
    }
}

private enum EditTabBarItemState {
    case selectAll(isSelect: Bool)
    case move
    case copy
    case delete
    
    var title: String {
        switch self {
        case .selectAll(let isSelect):
            return isSelect ? R.string.localizable.selectAllTabBar() : R.string.localizable.clearAll()
        case .move:         return R.string.localizable.move()
        case .copy:         return R.string.localizable.copyTabBar()
        case .delete:       return R.string.localizable.delete()
        }
    }
    
    var image: UIImage? {
        switch self {
        case .selectAll(let isSelect):
            return isSelect ? R.image.selectAll_TabBar() : R.image.deselectAll_TabBar()
        case .move:         return R.image.move_TabBar()
        case .copy:         return R.image.copy_TabBar()
        case .delete:       return R.image.trash_TabBar()
        }
    }
    
    var selectColor: UIColor {
        switch self {
        case .selectAll, .move, .copy:
            return UIColor(hex: "#7E19FF")
        case .delete:
            return UIColor(hex: "#DF0404")
        }
    }
    
    var deselectColor: UIColor {
        switch self {
        case .selectAll:
            return UIColor(hex: "#7E19FF")
        case .delete, .move, .copy:
            return UIColor(hex: "#ACB4B4")
        }
    }
}

extension UILabel {
    func setMaximumLineHeight(value: CGFloat) {
        guard let textString = text else { return }
        let attributedString = NSMutableAttributedString(string: textString)
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.maximumLineHeight = value
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: attributedString.length))
        attributedText = attributedString
    }
}
