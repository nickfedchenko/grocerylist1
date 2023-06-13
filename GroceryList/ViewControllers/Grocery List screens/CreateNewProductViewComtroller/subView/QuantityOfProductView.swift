//
//  QuantityOfProductView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.04.2023.
//

import UIKit

protocol QuantityOfProductViewDelegate: AnyObject {
    func unitSelected(_ unit: UnitSystem)
    func updateQuantityValue(_ quantity: Double)
    func isFirstResponderProductTextField(_ flag: Bool)
    func tappedMinusPlusButtons(_ quantity: Double)
}

final class QuantityOfProductView: CreateNewProductButtonView {
    
    weak var delegate: QuantityOfProductViewDelegate?
    var systemUnits: [UnitSystem] = [] {
        didSet { unitsTableView.reloadData() }
    }
    
    private let unitsBackgroundView = UIView()
    private lazy var unitsTableView: UITableView = {
        let tableview = UITableView()
        tableview.showsVerticalScrollIndicator = false
        tableview.estimatedRowHeight = UITableView.automaticDimension
        tableview.layer.cornerRadius = 8
        tableview.layer.masksToBounds = true
        tableview.backgroundColor = .white
        tableview.delegate = self
        tableview.dataSource = self
        tableview.isScrollEnabled = true
        tableview.separatorStyle = .none
        tableview.register(classCell: UnitsCell.self)
        return tableview
    }()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(minusButtonAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        return button
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(plusButtonAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        return button
    }()
    
    private var bgColor: UIColor = .clear
    private(set) var quantity: Double = 0 {
        didSet {
            longView.titleTextField.text = getDecimalString(quantity)
            delegate?.updateQuantityValue(quantity)
        }
    }
    private var quantityValueStep: Double = 1
    private var defaultUnit: UnitSystem = .piece
    private var currentUnit: UnitSystem? {
        didSet {
            if let currentUnit {
                updateUnit(unitTitle: currentUnit.title, isActive: true)
                updateQuantity(unitStep: Double(currentUnit.stepValue))
                quantityValueStep = Double(currentUnit.stepValue)
                delegate?.unitSelected(currentUnit)
                quantity = Double(currentUnit.stepValue)
            }
        }
    }
    
    override init(longTitle: String = R.string.localizable.quantity1(),
                  shortTitle: String = R.string.localizable.units()) {
        super.init(longTitle: longTitle, shortTitle: shortTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        longView.isTitleEnableUserInteraction(true)
        longView.titleTextField.keyboardType = .decimalPad
        longView.titleTextField.delegate = self
        longView.titleTextField.addTarget(self, action: #selector(changedQuantityValue), for: .editingChanged)
        
        let tapOnUnitsBackgroundView = UITapGestureRecognizer(target: self, action: #selector(tappedOnUnitsBackgroundView))
        unitsBackgroundView.addGestureRecognizer(tapOnUnitsBackgroundView)
        
        unitsTableView.layer.borderWidth = 1
        minusButton.layer.borderWidth = 1
        plusButton.layer.borderWidth = 1
    }
    
    override func setupColor(backgroundColor: UIColor, tintColor: UIColor) {
        super.setupColor(backgroundColor: backgroundColor, tintColor: tintColor)
        bgColor = backgroundColor
        unitsTableView.layer.borderColor = tintColor.cgColor
        
        minusButton.setImage(R.image.black_Minus()?.withTintColor(tintColor), for: .normal)
        plusButton.setImage(R.image.black_Plus()?.withTintColor(tintColor), for: .normal)
        
        minusButton.layer.borderColor = tintColor.cgColor
        plusButton.layer.borderColor = tintColor.cgColor
        
        minusButton.addCustomShadow(color: tintColor, opacity: 0.1, radius: 5, offset: .init(width: 0, height: 4))
        plusButton.addCustomShadow(color: tintColor, opacity: 0.1, radius: 5, offset: .init(width: 0, height: 4))
    }
    
    override func shortViewTapped() {
        hideTableView(isHide: false)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        self.addSubviews([minusButton, plusButton, unitsBackgroundView, unitsTableView])
        
        minusButton.snp.makeConstraints {
            $0.leading.top.bottom.equalTo(longView)
            $0.width.equalTo(40)
        }
        
        plusButton.snp.makeConstraints {
            $0.trailing.bottom.top.equalTo(longView)
            $0.width.equalTo(40)
        }
        
        unitsBackgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(84)
            $0.height.equalTo(0)
        }
        
        unitsTableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(shortView)
            $0.height.equalTo(0)
        }
        
        longView.titleTextField.snp.removeConstraints()
        longView.titleTextField.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
        }
    }
    
    func setupCurrentQuantity(unit: UnitSystem, value: Double) {
        currentUnit = unit
        quantity = value
        updateQuantityButtons(isActive: true)
        longView.shadowViews.forEach { $0.layer.shadowOpacity = 0 }
        shortView.shadowViews.forEach { $0.layer.shadowOpacity = 0 }
    }
    
    func reset() {
        quantity = 0
        updateQuantityButtons(isActive: false)
        updateUnit(isActive: false)
        longView.shadowViews.forEach { $0.layer.shadowOpacity = 0.12 }
        shortView.shadowViews.forEach { $0.layer.shadowOpacity = 0.12 }
    }
    
    func setDefaultUnit(_ unit: UnitSystem) {
        defaultUnit = unit
        updateUnit(unitTitle: unit.title, isActive: false)
        shortView.shadowViews.forEach { $0.layer.shadowOpacity = 0 }
    }
    
    @objc
    private func plusButtonAction() {
        AmplitudeManager.shared.logEvent(.itemQuantityButtons)
        if currentUnit == nil {
            currentUnit = defaultUnit
            quantity = 0
        }
        quantity += quantityValueStep
        updateQuantityButtons(isActive: true)
        updateUnit(isActive: true)
        delegate?.tappedMinusPlusButtons(quantity)
    }

    @objc
    private func minusButtonAction() {
        AmplitudeManager.shared.logEvent(.itemQuantityButtons)
        guard currentUnit != nil else { return }
        if quantity - quantityValueStep <= 0 {
            quantity = 0
            updateQuantityButtons(isActive: false)
            updateUnit(isActive: false)
            delegate?.tappedMinusPlusButtons(quantity)
            return
        }
        quantity -= quantityValueStep
        updateQuantityButtons(isActive: true)
        delegate?.tappedMinusPlusButtons(quantity)
    }
    
    @objc
    private func tappedOnUnitsBackgroundView() {
        hideTableView(isHide: true)
    }
    
    @objc
    private func changedQuantityValue() {
        guard let newQuantity = longView.titleTextField.text?.asDouble else {
            return
        }
        quantity = newQuantity
    }
    
    private func updateQuantityButtons(isActive: Bool) {
        guard isActive else {
            if  minusButton.backgroundColor != .clear {
                minusButton.setImage(R.image.black_Minus()?.withTintColor(activeColor), for: .normal)
                plusButton.setImage(R.image.black_Plus()?.withTintColor(activeColor), for: .normal)
                
                minusButton.backgroundColor = .clear
                plusButton.backgroundColor = .clear
                longView.shadowViews.forEach {
                    $0.backgroundColor = bgColor
                    $0.layer.shadowOpacity = 0.12
                }
                
                longView.titleTextField.textColor = activeColor
            }
            return
        }
        if minusButton.backgroundColor != activeColor {
            minusButton.setImage(R.image.black_Minus()?.withTintColor(.white), for: .normal)
            plusButton.setImage(R.image.black_Plus()?.withTintColor(.white), for: .normal)
            
            minusButton.backgroundColor = activeColor
            plusButton.backgroundColor = activeColor
            longView.shadowViews.forEach {
                $0.backgroundColor = .white
                $0.layer.shadowOpacity = 0
            }
            
            longView.titleTextField.textColor = .black
        }
    }
    
    private func updateUnit(unitTitle: String? = nil, isActive: Bool) {
        if let unitTitle {
            shortView.titleTextField.text = unitTitle
        }
        
        shortView.shadowViews.forEach {
            $0.backgroundColor = isActive ? activeColor : .clear
        }
        shortView.titleTextField.textColor = isActive ? .white : activeColor
    }
    
    private func updateQuantity(unitStep: Double) {
        longView.shadowViews.forEach {
            $0.backgroundColor = .white
        }
        longView.titleTextField.textColor = .black
        longView.titleTextField.text = getDecimalString(unitStep)
    }
    
    private func hideTableView(isHide: Bool, cell: UITableViewCell? = nil) {
        unitsBackgroundView.snp.updateConstraints { $0.height.equalTo(isHide ? 0 : 700) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            cell?.isSelected = false
        }
        
        UIView.animate(withDuration: 0.2, delay: isHide ? 0.2 : 0) { [weak self] in
            self?.unitsTableView.snp.updateConstraints { $0.height.equalTo(isHide ? 0 : 320) }
            self?.layoutIfNeeded()
        }
    }
    
    private func getDecimalString(_ value: Double) -> String {
        String(format: "%.\(value.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", value)
    }
}

extension QuantityOfProductView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        systemUnits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(classCell: UnitsCell.self, indexPath: indexPath)
        let title = systemUnits[indexPath.row].title
        cell.setupCell(title: title, isSelected: false, color: activeColor)
        return cell
    }
}

extension QuantityOfProductView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = unitsTableView.cellForRow(at: indexPath)
        cell?.isSelected = true
        AmplitudeManager.shared.logEvent(.itemUnitsButton)
        hideTableView(isHide: true, cell: cell)
        currentUnit = systemUnits[indexPath.row]
        shortView.shadowViews.forEach { $0.layer.shadowOpacity = 0 }
        updateQuantityButtons(isActive: true)
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension QuantityOfProductView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == longView.titleTextField {
            if longView.titleTextField.text == R.string.localizable.quantity1() {
                longView.titleTextField.text = ""
            }
            longView.shadowViews.forEach { $0.layer.shadowOpacity = 0 }
        }
        delegate?.isFirstResponderProductTextField(false)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == longView.titleTextField,
            let quantity = textField.text?.asDouble {
            delegate?.updateQuantityValue(quantity)
        } else {
            delegate?.updateQuantityValue(0)
        }
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = longView.titleTextField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength < 6
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == longView.titleTextField,
           textField.text?.isEmpty ?? true {
            longView.titleTextField.text = R.string.localizable.quantity1()
        }
    }
}
