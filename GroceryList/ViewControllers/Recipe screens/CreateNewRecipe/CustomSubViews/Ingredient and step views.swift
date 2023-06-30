//
//  IngredientForCreateRecipeView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import UIKit

final class IngredientForCreateRecipeView: IngredientView {

    var swipeDeleteAction: (() -> Void)?
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 14).font
        label.textColor = UIColor(hex: "#303030")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private lazy var rightButton: UIButton = {
        let imageView = UIButton()
        imageView.setImage(UIImage(named: "swipeToDelete"), for: .normal)
        imageView.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return imageView
    }()
    
    private var state: CellState = .normal
    var originalIndex: Int = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        servingLabel.textColor = UIColor(hex: "#D6600A")
        setupDeleteButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDescription(_ description: String?) {
        guard let description, !description.isEmpty else {
            return
        }
        descriptionLabel.text = description
        setupDescriptionLabel()
    }
    
    @objc
    private func swipeAction(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .right:
            if state == .swipedLeft { hidePinch() }
        case .left:
            if state == .swipedLeft {
                DispatchQueue.main.async {
                    self.clearTheCell()
                }
                deleteAction()
            }
            if state == .normal { showPinch() }
        default:
            print("")
        }
    }
    
    @objc
    private func deleteAction() {
        swipeDeleteAction?()
    }
    
    private func clearTheCell() {
        rightButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        self.snp.updateConstraints { make in
            make.left.right.equalToSuperview().inset(20)
        }
        state = .normal
        self.layoutIfNeeded()
    }
    
    private func showPinch() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.rightButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(65)
                make.left.equalToSuperview().inset(-7)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .swipedLeft
        }
    }
    
    private func hidePinch() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.rightButton.transform = CGAffineTransform(scaleX: 0, y: 1)
            self.snp.updateConstraints { make in
                make.left.right.equalToSuperview().inset(20)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.state = .normal
        }
    }
    
    private func setupDeleteButton() {
        rightButton.transform = CGAffineTransform(scaleX: 0.0, y: 1)
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRightRecognizer.direction = .right
        self.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeLeftRecognizer.direction = .left
        self.addGestureRecognizer(swipeLeftRecognizer)
        
        self.addSubviews([rightButton])
        rightButton.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.right.equalToSuperview().inset(-1)
            make.width.equalTo(68)
        }
    }
    
    private func setupDescriptionLabel() {
        self.addSubview(descriptionLabel)
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().offset(-7)
        }
        
        titleLabel.snp.removeConstraints()
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().inset(7)
            make.trailing.equalTo(servingLabel.snp.leading).inset(-18)
        }
    }
}

final class StepForCreateRecipeView: UIView {
    
    private lazy var stepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.medium(size: 16).font
        label.textColor = R.color.primaryDark()
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(step: String, description: String?) {
        stepLabel.text = step
        descriptionLabel.text = description
        
        if descriptionLabel.intrinsicContentSize.height > stepLabel.intrinsicContentSize.height {
            stepLabel.snp.updateConstraints {
                $0.top.equalTo(descriptionLabel.snp.top).offset(10)
            }
        }
    }
    
    func updateStep(step: String) {
        stepLabel.text = step
    }
    
    func getDescription() -> String? {
        descriptionLabel.text
    }
    
    private func setup() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([stepLabel, descriptionLabel])
        
        stepLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(descriptionLabel.snp.leading)
            $0.top.equalTo(descriptionLabel.snp.top).offset(0)
            $0.height.equalTo(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(54)
            $0.trailing.equalToSuperview().offset(-8)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
