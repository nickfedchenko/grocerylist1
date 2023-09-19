//
//  MealPlanLabelView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.09.2023.
//

import UIKit

protocol MealPlanLabelViewDelegate: AnyObject {
    func tapMenuLabel()
    func tapLabel(index: Int)
}

class MealPlanLabelView: UIView {
    
    weak var delegate: MealPlanLabelViewDelegate?
    
    private let containerView = UIView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = R.color.darkGray()
        label.text = R.string.localizable.mealPlanLabel()
        return label
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.recipe_menu(), for: .normal)
        button.addTarget(self, action: #selector(tappedOnMenuButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.primaryLight()
        view.setCornerRadius(8)
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var labelShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(8)
        view.addShadow(color: .init(hex: "858585"), opacity: 0.1,
                       radius: 6, offset: .init(width: 0, height: 4))
        return view
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        stackView.spacing = 1
        
        stackView.setCornerRadius(8)
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(allLabels: [MealPlanLabel]) {
        labelStackView.removeAllArrangedSubviews()
        
        allLabels.enumerated().forEach { index, label in
            let view = LabelView()
            view.tag = index
            view.configure(label)
            view.isSelected = label.isSelected
            view.selectedView = { [weak self] view in
                self?.delegate?.tapLabel(index: view.tag)
            }
            labelStackView.addArrangedSubview(view)
        }
        
        labelStackView.snp.updateConstraints {
            $0.height.equalTo(labelStackView.arrangedSubviews.count * 42 - 2)
        }
    }
    
    func updateLabels(allLabels: [MealPlanLabel]) {
        labelStackView.arrangedSubviews.enumerated().forEach { index, view in
            (view as? LabelView)?.isSelected = allLabels[index].isSelected
        }
    }
    
    private func setup() {
        makeConstraints()
    }
    
    @objc
    private func tappedOnMenuButton() {
        delegate?.tapMenuLabel()
    }
    
    private func makeConstraints() {
        self.addSubviews([containerView])
        containerView.addSubviews([titleLabel, menuButton, labelShadowView, labelBackgroundView])
        labelBackgroundView.addSubview(labelStackView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(40)
        }
        
        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        labelShadowView.snp.makeConstraints {
            $0.edges.equalTo(labelBackgroundView)
        }
        
        labelBackgroundView.snp.makeConstraints {
            $0.top.equalTo(menuButton.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(labelStackView)
        }
        
        let stackViewHeight = labelStackView.arrangedSubviews.count * 42 - 2
        labelStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(stackViewHeight < 0 ? 0 : stackViewHeight)
        }
    }
}

class LabelView: UIView {
    
    var selectedView: ((LabelView) -> Void)?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 16).font
        label.textColor = R.color.darkGray()
        return label
    }()
    
    let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.autorepeat_checkmark()?.withTintColor(R.color.primaryDark() ?? .black)
        return imageView
    }()
    
    var isSelected = false {
        didSet { checkmarkImageView.isHidden = !isSelected }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tapOnView)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ label: MealPlanLabel) {
        titleLabel.text = label.title
        titleLabel.textColor = ColorManager.shared.getLabelColor(index: label.color)
    }
    
    @objc
    private func tappedOnView() {
        selectedView?(self)
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, checkmarkImageView])
        
        self.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }

        checkmarkImageView.snp.makeConstraints {
            $0.verticalEdges.trailing.equalToSuperview()
            $0.height.width.equalTo(40)
        }
    }
}
