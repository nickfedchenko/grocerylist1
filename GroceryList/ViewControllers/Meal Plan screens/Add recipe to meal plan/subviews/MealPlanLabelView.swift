//
//  MealPlanLabelView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.09.2023.
//

import UIKit

protocol MealPlanLabelViewDelegate: AnyObject {
    func tapMenuLabel()
}

class MealPlanLabelView: UIView {
    
    weak var delegate: MealPlanLabelViewDelegate?
    
    private let containerView = UIView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = R.color.darkGray()
        label.text = "Meal Plan Label"
        return label
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.contextMenu(), for: .normal)
        button.addTarget(self, action: #selector(tappedOnMenuButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.primaryLight()
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var labelShadowView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 3
        view.layer.masksToBounds = false
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        stackView.spacing = 1
        
        stackView.layer.cornerRadius = 8
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
        
        allLabels.forEach { label in
            let view = LabelView()
            view.configure(label)
            view.isSelected = label.isSelected
            view.selectedView = { _ in
                
            }
            labelStackView.addArrangedSubview(view)
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
            $0.trailing.verticalEdges.equalToSuperview()
        }

        labelShadowView.snp.makeConstraints {
            $0.edges.equalTo(labelShadowView)
        }
        
        labelBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(labelStackView)
        }
        
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(menuButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
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
        imageView.image = R.image.checkmark()
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
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }

        checkmarkImageView.snp.makeConstraints {
            $0.verticalEdges.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}
