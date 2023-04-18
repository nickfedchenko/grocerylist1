//
//  QuantityOfProductView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.04.2023.
//

import UIKit

protocol QuantityOfProductViewDelegate: AnyObject {
    func unitSelected(_ unit: UnitSystem)
    func updateQuantityValue(_ quantity: Int)
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
    
    private var quantity = 0 {
        didSet {
            longView.titleTextField.text = "\(quantity)"
            delegate?.updateQuantityValue(quantity)
        }
    }
    private var quantityValueStep = 1
    private var defaultUnit: UnitSystem = .piece
    private var currentUnit: UnitSystem? {
        didSet {
            if let currentUnit {
                updateUnit(unitTitle: currentUnit.title, isActive: true)
                updateQuantity(unitStep: "\(currentUnit.stepValue)")
                quantityValueStep = currentUnit.stepValue
                delegate?.unitSelected(currentUnit)
                quantity = currentUnit.stepValue
            }
        }
    }
    
    override init(longTitle: String = R.string.localizable.quantity1(), shortTitle: String = "units") {
        super.init(longTitle: longTitle, shortTitle: shortTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        longView.isTitleEnableUserInteraction(true)
        
        let tapOnUnitsBackgroundView = UITapGestureRecognizer(target: self, action: #selector(tappedOnUnitsBackgroundView))
        unitsBackgroundView.addGestureRecognizer(tapOnUnitsBackgroundView)
        
        unitsTableView.layer.borderWidth = 1
        minusButton.layer.borderWidth = 1
        plusButton.layer.borderWidth = 1
    }
    
    override func setupColor(_ color: UIColor) {
        super.setupColor(color)
        unitsTableView.layer.borderColor = color.cgColor
        
        minusButton.setImage(R.image.black_Minus()?.withTintColor(color), for: .normal)
        plusButton.setImage(R.image.black_Plus()?.withTintColor(color), for: .normal)
        
        minusButton.layer.borderColor = color.cgColor
        plusButton.layer.borderColor = color.cgColor
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
    }
    
    func reset() {
        quantity = 0
        updateQuantityButtons(isActive: false)
        updateUnit(isActive: false)
    }
    
    func setDefaultUnit(_ unit: UnitSystem) {
        defaultUnit = unit
        updateUnit(unitTitle: unit.title, isActive: false)
    }
    
    @objc
    private func plusButtonAction() {
        if currentUnit == nil {
            currentUnit = defaultUnit
            quantity = 0
        }
        quantity += quantityValueStep
        updateQuantityButtons(isActive: true)
        updateUnit(isActive: true)
    }

    @objc
    private func minusButtonAction() {
        guard currentUnit != nil else { return }
        if quantity - quantityValueStep <= 0 {
            quantity = 0
            updateQuantityButtons(isActive: false)
            updateUnit(isActive: false)
            return
        }
        quantity -= quantityValueStep
        updateQuantityButtons(isActive: true)
    }
    
    @objc
    private func tappedOnUnitsBackgroundView() {
        hideTableView(isHide: true)
    }
    
    private func updateQuantityButtons(isActive: Bool) {
        guard isActive else {
            if  minusButton.backgroundColor != .clear {
                minusButton.setImage(R.image.black_Minus()?.withTintColor(activeColor), for: .normal)
                plusButton.setImage(R.image.black_Plus()?.withTintColor(activeColor), for: .normal)
                
                minusButton.backgroundColor = .clear
                plusButton.backgroundColor = .clear
                longView.backgroundColor = .clear
                
                longView.titleTextField.textColor = activeColor
            }
            return
        }
        if minusButton.backgroundColor != activeColor {
            minusButton.setImage(R.image.black_Minus()?.withTintColor(.white), for: .normal)
            plusButton.setImage(R.image.black_Plus()?.withTintColor(.white), for: .normal)
            
            minusButton.backgroundColor = activeColor
            plusButton.backgroundColor = activeColor
            longView.backgroundColor = .white
            
            longView.titleTextField.textColor = .black
        }
    }
    
    private func updateUnit(unitTitle: String? = nil, isActive: Bool) {
        if let unitTitle {
            shortView.titleTextField.text = unitTitle
        }
        shortView.backgroundColor = isActive ? activeColor : .clear
        shortView.titleTextField.textColor = isActive ? .white : activeColor
    }
    
    private func updateQuantity(unitStep: String) {
        longView.backgroundColor = .white
        longView.titleTextField.textColor = .black
        longView.titleTextField.text = unitStep
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
        hideTableView(isHide: true, cell: cell)
        currentUnit = systemUnits[indexPath.row]
        updateQuantityButtons(isActive: true)
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
