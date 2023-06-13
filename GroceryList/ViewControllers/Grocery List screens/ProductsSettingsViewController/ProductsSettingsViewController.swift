//
//  ProductsSettingsViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import SnapKit
import UIKit

class ProductsSettingsViewController: UIViewController {
    
    var viewModel: ProductsSettingsViewModel?
    
    private let contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = .white
        return view
    }()
    
    private let pinchView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.mediumGray()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    private let parametrsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 22).font
        label.text = "Parametrs".localized
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: "Done".localized, attributes: [
            .font: UIFont.SFPro.semibold(size: 18).font ?? UIFont(),
            .foregroundColor: UIColor.white
        ])
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.maskedCorners = [.layerMinXMaxYCorner]
        return button
    }()
    
    private let tableview: UITableView = {
        let tableview = UITableView()
        tableview.showsVerticalScrollIndicator = false
        tableview.estimatedRowHeight = UITableView.automaticDimension
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        addRecognizers()
        setupTableView()
        parametrsLabel.textColor = viewModel?.getTextColor()
        doneButton.backgroundColor = viewModel?.getColor()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneButtonPressed))
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPanel()
    }
    
    deinit {
        print("Products settings deinited")
    }
    
    // MARK: - close vc
    @objc
    private func doneButtonPressed() {
        hidePanel(compl: nil)
    }
    
    // MARK: - swipeDown
    
    private func hidePanel(compl: (() -> Void)?) {
        updateConstr(with: -570, alpha: 0)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: compl)
        }
    }
    
    private func showPanel() {
        updateConstr(with: 0, alpha: 0.25)
    }
    
    func updateConstr(with inset: Double, alpha: Double) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            self?.view.backgroundColor = UIColor(hex: "285454").withAlphaComponent(alpha)
            self?.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self?.view.layoutIfNeeded()
        }
    }

    // MARK: - Constraints
    private func setupConstraints() {
        view.addSubview(contentView)
        contentView.addSubviews([pinchView, parametrsLabel, doneButton, tableview])
       
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-570)
            make.height.equalTo(570)
        }
        
        pinchView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(65)
            make.height.equalTo(4)
            make.top.equalToSuperview().inset(8)
        }
        
        parametrsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(27)
        }
        
        doneButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(48)
        }
        
        tableview.snp.makeConstraints { make in
            make.top.equalTo(parametrsLabel.snp.bottom).inset(-18)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
    }
}

// MARK: - recognizer actions
extension ProductsSettingsViewController {
    
    private func addRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel(compl: nil)
        }
    }
}

extension ProductsSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableview.backgroundColor = .clear
        tableview.delegate = self
        tableview.dataSource = self
        tableview.isScrollEnabled = false
        tableview.separatorStyle = .none
        tableview.register(ProductSettingsTableViewCell.self, forCellReuseIdentifier: "ProductSettingsTableViewCell")
        tableview.rowHeight = 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.getNumberOfCells() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableview.dequeueReusableCell(withIdentifier: "ProductSettingsTableViewCell", for: indexPath)
                as? ProductSettingsTableViewCell, let viewModel = viewModel else { return UITableViewCell() }
        let image = viewModel.getImage(at: indexPath.row)
        let text = viewModel.getText(at: indexPath.row)
        let separatorColor = viewModel.getSeparatorLineColor()
        let color = viewModel.getColor()
        let checkmarkColor = viewModel.getTextColor()
        let isCheckmark = viewModel.isCheckmarkActive(at: indexPath.row)
        let isSwitchActive = viewModel.isSwitchActive(at: indexPath.row)
        let isShare = viewModel.isSharedList(at: indexPath.row)
        cell.setupCell(imageForCell: image, text: text, separatorColor: separatorColor,
                       checkmarkColor: checkmarkColor, isCheckmarkActive: isCheckmark)
        
        if isSwitchActive {
            let switchValue = viewModel.switchValue(at: indexPath.row)
            cell.setupSwitch(isVisible: isSwitchActive, value: switchValue, tintColor: color)
        }
        
        if isShare {
            let users = viewModel.getShareImages()
            cell.setupShareView(isVisible: isShare, users: users, tintColor: color)
        }
        
        cell.switchValueChanged = { [weak self] isOn in
            self?.viewModel?.changeSwitchValue(at: indexPath.row, isOn: isOn)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.cellSelected(at: indexPath.row)
    }
}

extension ProductsSettingsViewController: ProductSettingsViewDelegate {
    func presentVC(controller: UIViewController?) {
        guard let controller else { return }
        self.present(controller, animated: true)
    }

    func reloadController() {
        parametrsLabel.textColor = viewModel?.getTextColor()
        doneButton.backgroundColor = viewModel?.getColor()
        tableview.reloadData()
    }
    
    func dismissController(comp: @escaping (() -> Void)) {
        hidePanel { comp() }
    }
}

extension ProductsSettingsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.tableview) ?? false)
    }
}
