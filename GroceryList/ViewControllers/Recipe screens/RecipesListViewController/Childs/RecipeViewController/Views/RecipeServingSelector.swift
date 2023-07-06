//
//  RecipeServingSelector.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 11.12.2022.
//

import UIKit

protocol RecipeServingSelectorDelegate: AnyObject {
    func servingChangedTo(count: Double)
}

final class RecipeServingSelector: UIView {
    weak var delegate: RecipeServingSelectorDelegate?
    
    private var currentCount: Double = 1 {
        didSet { updateLabel() }
    }
    
    private let minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.black_Minus(), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.tintColor = .white
        button.clipsToBounds = true
        return button
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.black_Plus(), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.tintColor = .white
        button.clipsToBounds = true
        return button
    }()
    
    private let servingsLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextSemibold(size: 17)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "1 " + R.string.localizable.servings1()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupSubviews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupColor(color: UIColor?) {
        layer.borderColor = color?.cgColor
        minusButton.backgroundColor = color
        plusButton.backgroundColor = color
        servingsLabel.textColor = color
    }
    
    func setCountInitially(to count: Int) {
        currentCount = count <= 0 ? 1 : Double(count)
    }
    
    private func updateLabel() {
        var servingsString = ""
        switch currentCount {
        case 1:
            servingsString = R.string.localizable.servings1()
        case 2...4:
            servingsString = R.string.localizable.servings24()
        case 5...:
            servingsString = R.string.localizable.servings4()
        default:
            servingsString = R.string.localizable.servings1()
        }
        servingsLabel.text = "\(currentCount.asString) " + servingsString
    }
    
    private func setupAppearance() {
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
    }
    
    private func setupSubviews() {
        addSubviews([servingsLabel, minusButton, plusButton])
        servingsLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        minusButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.top.leading.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.top.trailing.equalToSuperview()
        }
    }
    
    private func setupActions() {
        minusButton.addTarget(self, action: #selector(servingCountChange(sender:)), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(servingCountChange(sender:)), for: .touchUpInside)
    }
    
    private func animateBlinking(button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            button.alpha = 0.5
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                button.alpha = 1
            }
        }
    }
    
    @objc
    private func servingCountChange(sender: UIButton) {
        AmplitudeManager.shared.logEvent(.recipeServingChange)
        switch sender {
        case minusButton:
            if currentCount > 1 {
                currentCount -= 0.5
                delegate?.servingChangedTo(count: currentCount)
            }
        case plusButton:
            currentCount += 0.5
            delegate?.servingChangedTo(count: currentCount)
        default:
            return
        }
        animateBlinking(button: sender)
    }
}
