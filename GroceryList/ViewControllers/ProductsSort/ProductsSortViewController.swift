//
//  ProductsSortViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.05.2023.
//

import UIKit

class ProductsSortViewController: UIViewController {
    
    var viewModel: ProductsSortViewModel?
    
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
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.sortFilter(), for: .normal)
        button.addTarget(self, action: #selector(sortButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let sortLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 22).font
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: R.string.localizable.done(),
                                                 attributes: [
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
    
    private var tableviewHeight = 276
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupColor()
        addRecognizers()
        setupConstraints()

        sortLabel.text = viewModel?.title
        if (viewModel?.getIsAscendingOrder() ?? true) {
            sortButton.transform = CGAffineTransform(rotationAngle: -.pi)
        }
        
        tableviewHeight = 46 * (viewModel?.getNumberOfCells() ?? 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let bottomPadding = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        contentView.snp.updateConstraints {
            $0.height.equalTo(Int(bottomPadding) + 96 + tableviewHeight)
        }
        showPanel()
    }
    
    deinit {
        print("Products sort deinited")
    }
    
    private func setupTableView() {
        tableview.backgroundColor = .clear
        tableview.delegate = self
        tableview.dataSource = self
        tableview.isScrollEnabled = false
        tableview.separatorStyle = .none
        tableview.register(classCell: ProductSettingsTableViewCell.self)
        tableview.rowHeight = 46
    }
    
    private func setupColor() {
        let darkColor = viewModel?.getTextColor() ?? .black
        doneButton.backgroundColor = viewModel?.getColor()
        sortLabel.textColor = darkColor
        sortButton.setImage(R.image.sortFilter()?.withTintColor(darkColor), for: .normal)
    }
    
    private func addRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneButtonPressed))
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel(compl: nil)
        }
    }
    
    @objc
    private func sortButtonPressed() {
        viewModel?.toggleIsAscendingOrder()
        if (viewModel?.getIsAscendingOrder() ?? true) {
            ascendingOrder()
        } else {
            descendingOrder()
        }
        viewModel?.updateSortOrder()
    }

    @objc
    private func doneButtonPressed() {
        hidePanel(compl: nil)
    }
    
    private func ascendingOrder() {
        UIView.animate(withDuration: 0.25, delay: .zero, options: .curveEaseOut) {
            self.sortButton.transform = CGAffineTransform(rotationAngle: .pi * 2)
        }
    }
    
    private func descendingOrder() {
        UIView.animate(withDuration: 0.25, delay: .zero, options: .curveEaseOut) {
            self.sortButton.transform = CGAffineTransform(rotationAngle: -.pi )
        }
    }

    private func hidePanel(compl: (() -> Void)?) {
        updateConstr(with: -372, alpha: 0)
       
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

    private func setupConstraints() {
        view.addSubview(contentView)
        contentView.addSubviews([pinchView, sortButton, sortLabel, doneButton, tableview])
       
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-372)
            make.height.equalTo(372)
        }
        
        pinchView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(65)
            make.height.equalTo(4)
            make.top.equalToSuperview().inset(8)
        }
        
        sortButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }
        
        sortLabel.snp.makeConstraints { make in
            make.leading.equalTo(sortButton.snp.trailing).offset(4)
            make.centerY.equalTo(sortButton)
        }
        
        doneButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(48)
        }
        
        tableview.snp.makeConstraints { make in
            make.top.equalTo(sortLabel.snp.bottom).inset(-18)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
    }
}

extension ProductsSortViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.getNumberOfCells() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        let cell = tableview.reusableCell(classCell: ProductSettingsTableViewCell.self, indexPath: indexPath)
        cell.selectionStyle = .none
        let image = viewModel.getImage(at: indexPath.row)
        let text = viewModel.getText(at: indexPath.row)
        let separatorColor = viewModel.getSeparatorLineColor()
        let checkmarkColor = viewModel.getTextColor()
        let isCheckmark = viewModel.isCheckmarkActive(at: indexPath.row)
        cell.setupSortCell(text: text, imageForCell: image,
                           separatorColor: separatorColor, checkmarkColor: checkmarkColor, isCheckmarkActive: isCheckmark)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.cellSelected(at: indexPath.row)
    }
}

extension ProductsSortViewController: ProductSettingsViewDelegate {
    func presentVC(controller: UIViewController?) {
        guard let controller else { return }
        self.present(controller, animated: true)
    }

    func reloadController() {
        tableview.reloadData()
    }
    
    func dismissController(comp: @escaping (() -> Void)) {
        hidePanel { comp() }
    }
}

extension ProductsSortViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.tableview) ?? false)
    }
}
