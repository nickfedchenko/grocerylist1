//
//  CreateNewRecipeKcalView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 04.07.2023.
//

import UIKit

enum NutritionFacts: Int, CaseIterable {
    case carb
    case protein
    case fat
    case kcal
}

class CreateNewRecipeKcalView: UIView {
    
    var requiredHeight: Int {
        12 + 20 + 8 + 72 + 8 + 30 + 4
    }
    
    var kcal: Value? {
        if carbView.value == nil && proteinView.value == nil &&
            fatView.value == nil && kcalView.value == nil {
            return nil
        }
        
        return Value(kcal: kcalView.value,
                     netCarbs: carbView.value,
                     proteins: proteinView.value,
                     fats: fatView.value)
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = R.color.darkGray()
        label.text = "Nutrition Facts per Serving *"
        return label
    }()
    
    private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var asteriskLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 12).font
        label.textColor = R.color.darkGray()
        label.text = "*"
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 12).font
        label.textColor = R.color.darkGray()
        label.text = "If these data are known or calculated. You can write only approximate calories or leave this section blank."
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var carbView: NutritionFactsView = {
        let view = NutritionFactsView(nutritionFact: .carb)
        view.returnTapped = { [weak self] in
            self?.proteinView.textField.becomeFirstResponder()
        }
        return view
    }()
    
    private lazy var proteinView: NutritionFactsView = {
        let view = NutritionFactsView(nutritionFact: .protein)
        view.returnTapped = { [weak self] in
            self?.fatView.textField.becomeFirstResponder()
        }
        return view
    }()
    
    private lazy var fatView: NutritionFactsView = {
        let view = NutritionFactsView(nutritionFact: .fat)
        view.returnTapped = { [weak self] in
            self?.kcalView.textField.becomeFirstResponder()
        }
        return view
    }()
    
    private lazy var kcalView: NutritionFactsView = {
        let view = NutritionFactsView(nutritionFact: .kcal)
        view.returnTapped = { [weak self] in
            self?.kcalView.textField.resignFirstResponder()
        }
        return view
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        self.backgroundColor = .clear

        setupStackView()
        makeConstraints()
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(carbView)
        stackView.addArrangedSubview(proteinView)
        stackView.addArrangedSubview(fatView)
        stackView.addArrangedSubview(kcalView)
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, stackView, asteriskLabel, descriptionLabel])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(12)
            $0.height.equalTo(20)
        }

        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(72)
        }
        
        asteriskLabel.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(30)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(8)
            $0.leading.equalTo(asteriskLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(30)
            $0.bottom.equalToSuperview().offset(-4)
        }
    }
}

extension NutritionFacts {
    var title: String {
        switch self {
        case .carb:     return "carb"
        case .protein:  return "protein"
        case .fat:      return "fat"
        case .kcal:     return "kcal"
        }
    }
    
    var activeColor: UIColor {
        switch self {
        case .carb:     return UIColor(hex: "CAAA00")
        case .protein:  return UIColor(hex: "1EB824")
        case .fat:      return UIColor(hex: "00B6CE")
        case .kcal:     return UIColor(hex: "EF6033")
        }
    }
    
    var placeholder: String {
        switch self {
        case .kcal:     return ""
        default:        return "g"
        }
    }
}

private final class NutritionFactsView: UIView {
    
    var returnTapped: (() -> Void)?
    
    var value: Double? {
        textField.text?.asDouble
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 14).font
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = R.color.mediumGray()
        return label
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.SFPro.medium(size: 17).font
        textField.textColor = nutritionFact.activeColor
        textField.delegate = self
        textField.textAlignment = .center
        textField.backgroundColor = .white
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    let nutritionFact: NutritionFacts
    
    init(nutritionFact: NutritionFacts) {
        self.nutritionFact = nutritionFact
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateActive(isActive: Bool) {
        self.layer.borderColor = (isActive ? nutritionFact.activeColor : R.color.mediumGray())?.cgColor
        titleLabel.backgroundColor = isActive ? nutritionFact.activeColor : R.color.mediumGray()
        let activeColor = nutritionFact == .kcal ? nutritionFact.activeColor : .black
        textField.textColor = isActive ? activeColor : R.color.mediumGray()
        if nutritionFact == .kcal && isActive {
            textField.font = UIFont.SFPro.bold(size: 17).font
        } else {
            textField.font = UIFont.SFPro.medium(size: 17).font
        }
    }
    
    private func setup() {
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.layer.borderColor = R.color.mediumGray()?.cgColor
        self.clipsToBounds = true
        
        titleLabel.text = nutritionFact.title
        textField.attributedPlaceholder = NSAttributedString(
            string: nutritionFact.placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: R.color.mediumGray() ?? UIColor(hex: "ACB4B4")]
        )
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, textField])
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }
        
        textField.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }
    }
}

extension NutritionFactsView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        updateActive(isActive: true)
        textField.text = textField.text?.replacingOccurrences(of: " g", with: "")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateActive(isActive: !(textField.text?.isEmpty ?? true))
        if nutritionFact != .kcal && !(textField.text?.isEmpty ?? true) {
            textField.text?.append(" g")
        }
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        return CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: text))
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        returnTapped?()
        return true
    }
}
