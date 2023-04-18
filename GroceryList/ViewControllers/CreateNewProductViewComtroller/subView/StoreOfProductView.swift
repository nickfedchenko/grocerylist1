//
//  StoreOfProductView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.04.2023.
//

import UIKit

protocol StoreOfProductViewDelegate: AnyObject {
    func tappedNewStore()
}

final class StoreOfProductView: CreateNewProductButtonView {
    
    weak var delegate: StoreOfProductViewDelegate?
    var stores: [String] = [] {
        didSet {
            stores.insert("Any store", at: 0)
            stores.append("")
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
    
    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .black
        return label
    }()
    
    private var storeTableViewHeight: Int {
        stores.count * 40 > 320 ? 320 : stores.count * 40
    }
    
    override init(longTitle: String = "Store", shortTitle: String = "cost") {
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
    }
    
    override func setupColor(_ color: UIColor) {
        super.setupColor(color)
        storeTableView.layer.borderColor = color.cgColor
        storeTableView.layer.borderWidth = 1
    }
    
    override func longViewTapped() {
        hideTableView(isHide: false)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        self.addSubviews([currencyLabel, storeBackgroundView, storeTableView])
        
        currencyLabel.snp.makeConstraints {
            $0.trailing.equalTo(shortView.titleTextField.snp.leading)
            $0.top.bottom.equalTo(shortView.titleTextField)
        }
        
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
    
    @objc
    private func tappedOnStoreBackgroundView() {
        hideTableView(isHide: true)
    }
    
    private func updateCost(isActive: Bool) {
        shortView.backgroundColor = isActive ? .white : nil
        shortView.titleTextField.textColor = isActive ? .black : activeColor
        currencyLabel.font = isActive ? UIFont.SFPro.semibold(size: 17).font : UIFont.SFPro.regular(size: 17).font
        currencyLabel.textColor = isActive ? .black : activeColor
        currencyLabel.text = (Locale.current.currencySymbol ?? "") + (isActive ? " " : "")
    }
    
    private func updateStore(store: String) {
        longView.titleTextField.text = store
    }
    
    private func hideTableView(isHide: Bool, cell: UITableViewCell? = nil) {
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
        let title = stores[indexPath.row]
        cell.setupCell(title: title, isSelected: false, color: activeColor)
        return cell
    }
}

extension StoreOfProductView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = storeTableView.cellForRow(at: indexPath)
        if indexPath.row != 0 || indexPath.row != stores.count - 1 {
            cell?.isSelected = true
        }
        
        if indexPath.row == stores.count - 1 {
            delegate?.tappedNewStore()
            hideTableView(isHide: true, cell: cell)
            return
        }
        
        hideTableView(isHide: true, cell: cell)
        let store = stores[indexPath.row]
        updateStore(store: store)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension StoreOfProductView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateCost(isActive: true)
        if textField.text == "cost" {
            textField.text = ""
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        updateCost(isActive: false)
        return true
    }
}
