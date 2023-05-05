//
//  StoreOfProductView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.04.2023.
//

import UIKit

protocol StoreOfProductViewDelegate: AnyObject {
    func tappedNewStore()
    func isFirstResponderProductTextField(_ flag: Bool)
    func updateCost(_ cost: Double?)
}

final class StoreOfProductView: CreateNewProductButtonView {
    
    weak var delegate: StoreOfProductViewDelegate?
    var store: Store? {
        currentStore
    }
    var cost: Double? {
        let currencySymbol = currency.trimmingCharacters(in: .whitespacesAndNewlines)
        var cost = shortView.titleTextField.text?.replacingOccurrences(of: currencySymbol, with: "") ?? ""
        cost = cost.trimmingCharacters(in: .whitespacesAndNewlines)
        let costValue = cost.asDouble
        return cost == R.string.localizable.cost() ? nil : costValue
    }
    
    var stores: [Store] = [] {
        didSet {
            stores.insert(Store(title: R.string.localizable.anyStore()), at: 0)
            stores.append(Store(title: ""))
            storeTableView.reloadData()
        }
    }
    
    private let storeBackgroundView = UIView()
    private lazy var storeTableView: UITableView = {
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
    
    private var bgColor: UIColor?
    private var currentStore: Store?
    private var isActiveCostView = false
    private var currency = ""
    private var storeTableViewHeight: Int {
        stores.count * 40 > 280 ? 280 : stores.count * 40
    }
    
    override init(longTitle: String = R.string.localizable.store(), shortTitle: String = R.string.localizable.cost()) {
        super.init(longTitle: longTitle, shortTitle: shortTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        shortView.isTitleEnableUserInteraction(true)
        
        let tapOnStoreBackgroundView = UITapGestureRecognizer(target: self, action: #selector(tappedOnStoreBackgroundView))
        storeBackgroundView.addGestureRecognizer(tapOnStoreBackgroundView)
        
        shortView.titleTextField.delegate = self
        shortView.titleTextField.keyboardType = .decimalPad
        shortView.titleTextField.addTarget(self, action: #selector(changedCostValue), for: .editingChanged)
    }
    
    override func setupColor(backgroundColor: UIColor, tintColor: UIColor) {
        super.setupColor(backgroundColor: backgroundColor, tintColor: tintColor)
        bgColor = backgroundColor
        storeTableView.layer.borderColor = tintColor.cgColor
        storeTableView.layer.borderWidth = 1
    }
    
    override func longViewTapped() {
        AmplitudeManager.shared.logEvent(.shopStoreBtn)
        hideTableView(isHide: false)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        self.addSubviews([storeBackgroundView, storeTableView])

        storeBackgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(84)
            $0.height.equalTo(0)
        }
        
        storeTableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(longView)
            $0.height.equalTo(0)
        }
        
    }
    
    func setStore(store: Store) {
        longView.titleTextField.text = store.title
        longView.shadowViews.forEach {
            $0.layer.shadowOpacity = 0
        }
        currentStore = store
    }
    
    func setCost(value: String) {
        shortView.titleTextField.text = value
        shortView.shadowViews.forEach {
            $0.layer.shadowOpacity = 0
        }
        updateCost(isActive: false)
    }
    
    func reset() {
        longView.titleTextField.text = R.string.localizable.store()
        shortView.titleTextField.text = R.string.localizable.cost()
        longView.shadowViews.forEach {
            $0.layer.shadowOpacity = 0.12
        }
        shortView.shadowViews.forEach {
            $0.layer.shadowOpacity = 0.12
        }
    }
    
    func tappedOutsideCostView() {
        guard isActiveCostView else {
            return
        }
        updateCost(isActive: false)
    }
    
    @objc
    private func tappedOnStoreBackgroundView() {
        hideTableView(isHide: true)
    }
    
    @objc
    private func changedCostValue() {
        delegate?.updateCost(getCostString().asDouble)
    }
    
    private func updateCost(isActive: Bool) {
        isActiveCostView = isActive
        shortView.shadowViews.forEach {
            $0.backgroundColor = isActive ? .white : bgColor
        }
        
        shortView.titleTextField.textColor = isActive ? .black : activeColor
        
        currency = ""
        currency = (Locale.current.currencySymbol ?? "") + (isActive ? " " : "")
        var cost = getCostString()
        if !isActive {
            cost = String(format: "%.2f", cost.asDouble ?? 0)
        }
        if !isActive, cost.isEmpty {
            shortView.titleTextField.text = R.string.localizable.cost()
            shortView.shadowViews.forEach {
                $0.layer.shadowOpacity = 0.12
            }
            return
        }
        
        if let currencyFont = isActive ? UIFont.SFPro.semibold(size: 17).font : UIFont.SFPro.regular(size: 17).font {
            let currencyAttr = NSMutableAttributedString(string: currency,
                                                         attributes: [.font: currencyFont])
            let costAttr = NSAttributedString(string: cost,
                                              attributes: [.font: UIFont.SFPro.semibold(size: 17).font ?? .systemFont(ofSize: 17)])
            currencyAttr.append(costAttr)
            shortView.titleTextField.attributedText = currencyAttr
            shortView.shadowViews.forEach {
                $0.layer.shadowOpacity = 0
            }
        }
        
        DispatchQueue.main.async {
            let textField = self.shortView.titleTextField
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    private func getCostString() -> String {
        let currencySymbol = currency.trimmingCharacters(in: .whitespacesAndNewlines)
        let cost = shortView.titleTextField.text?.replacingOccurrences(of: currencySymbol, with: "") ?? ""
        return cost.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func updateStore(store: String) {
        longView.titleTextField.text = store
    }
    
    private func hideTableView(isHide: Bool, cell: UITableViewCell? = nil) {
        if !isHide {
            storeTableView.reloadData()
        }
        storeBackgroundView.snp.updateConstraints { $0.height.equalTo(isHide ? 0 : 700) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            cell?.isSelected = false
        }
        
        UIView.animate(withDuration: 0.2, delay: isHide ? 0.2 : 0) { [weak self] in
            guard let self else { return }
            self.storeTableView.snp.updateConstraints { $0.height.equalTo(isHide ? 0 : self.storeTableViewHeight) }
            self.layoutIfNeeded()
        }
    }
}

extension StoreOfProductView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(classCell: UnitsCell.self, indexPath: indexPath)
        if indexPath.row == 0 {
            cell.state = .anyStore
            cell.setupAnyStore(color: activeColor)
            return cell
        }
        if indexPath.row == stores.count - 1 {
            cell.state = .newStore
            cell.setupNewStore(color: activeColor)
            return cell
        }
        let title = stores[indexPath.row].title
        cell.setupCell(title: title, isSelected: false, color: activeColor)
        cell.isSelected = currentStore == stores[indexPath.row]
        return cell
    }
}

extension StoreOfProductView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = storeTableView.cellForRow(at: indexPath)
        let store = stores[indexPath.row]
        currentStore = store
        if indexPath.row != 0 || indexPath.row != stores.count - 1 {
            storeTableView.reloadData()
        }
        
        if indexPath.row == stores.count - 1 {
            AmplitudeManager.shared.logEvent(.shopNewShop)
            delegate?.tappedNewStore()
            hideTableView(isHide: true, cell: cell)
            return
        }
        AmplitudeManager.shared.logEvent(.shopShopSelectet)
        hideTableView(isHide: true, cell: cell)
        longView.shadowViews.forEach { $0.layer.shadowOpacity = 0 }
        updateStore(store: store.title)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension StoreOfProductView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField == shortView.titleTextField else { return }
        AmplitudeManager.shared.logEvent(.shopCostBtn)
        if textField.text == R.string.localizable.cost() {
            textField.text = ""
        }
        updateCost(isActive: true)
        delegate?.isFirstResponderProductTextField(false)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == shortView.titleTextField,
              let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        guard isActiveCostView else {
            updateCost(isActive: true)
            return newLength < 10
        }
        return newLength < 10
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard textField == shortView.titleTextField else { return true }
        updateCost(isActive: false)
        return true
    }
}
