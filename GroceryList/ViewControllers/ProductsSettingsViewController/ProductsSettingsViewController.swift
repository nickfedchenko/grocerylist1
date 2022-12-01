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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        addRecognizers()
        setupTableView()
        parametrsLabel.textColor = viewModel?.getTextColor()
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
        updateConstr(with: -602, alpha: 0)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: compl)
        }
    }
    
    private func showPanel() {
        updateConstr(with: 0, alpha: 0.5)
    }
    
    func updateConstr(with inset: Double, alpha: Double) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            self?.view.backgroundColor = .black.withAlphaComponent(alpha)
            self?.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self?.view.layoutIfNeeded()
        }
    }
    
    // MARK: - UI
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
        view.backgroundColor = #colorLiteral(red: 0.5402887464, green: 0.5452626944, blue: 0.5623689294, alpha: 1)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    private let parametrsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.text = "Parametrs".localized
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: "Done".localized, attributes: [
            .font: UIFont.SFPro.semibold(size: 16).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#000000")
        ])
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    private let tableview: UITableView = {
        let tableview = UITableView()
        tableview.showsVerticalScrollIndicator = false
        tableview.estimatedRowHeight = UITableView.automaticDimension
        return tableview
    }()

    // MARK: - Constraints
    private func setupConstraints() {
        view.addSubview(contentView)
        contentView.addSubviews([pinchView, parametrsLabel, doneButton, tableview])
       
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-602)
            make.height.equalTo(602)
        }
        
        pinchView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(65)
            make.height.equalTo(4)
            make.top.equalToSuperview().inset(8)
        }
        
        parametrsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(pinchView.snp.bottom).offset(14)
        }
        
        doneButton.snp.makeConstraints { make in
            make.centerY.equalTo(parametrsLabel)
            make.right.equalToSuperview().inset(20)
        }
        
        tableview.snp.makeConstraints { make in
            make.top.equalTo(parametrsLabel.snp.bottom).inset(-20)
            make.bottom.equalToSuperview().inset(20)
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.getNumberOfCells() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableview.dequeueReusableCell(withIdentifier: "ProductSettingsTableViewCell", for: indexPath)
                as? ProductSettingsTableViewCell, let viewModel = viewModel else { return UITableViewCell() }
        let image = viewModel.getImage(at: indexPath.row)
        let text = viewModel.getText(at: indexPath.row)
        let isInset = viewModel.getInset(at: indexPath.row)
        let separatorColor = viewModel.getSeparatirLineColor()
        let isCheckmark = viewModel.isChecmarkActive(at: indexPath.row)
        cell.setupCell(imageForCell: image, text: text, inset: isInset, separatorColor: separatorColor, isCheckmarkActive: isCheckmark)
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
        tableview.reloadData()
    }
    
    func dismissController() {
        hidePanel {[weak self] in
            self?.viewModel?.controllerDissmised()
        }
    }
}
