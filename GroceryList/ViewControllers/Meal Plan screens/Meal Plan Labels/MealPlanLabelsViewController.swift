//
//  MealPlanLabelsViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.09.2023.
//

import UIKit

class MealPlanLabelsViewController: UIViewController {

    private let viewModel: MealPlanLabelsViewModel
    
    private let grabberBackgroundView = UIView()
    
    private lazy var grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "3C3C43", alpha: 0.3)
        view.setCornerRadius(2.5)
        return view
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "045C5C")
        button.setTitle("Done".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.heavy(size: 17).font
        button.addTarget(self, action: #selector(tappedDoneButton), for: .touchUpInside)
        button.contentEdgeInsets.left = 20
        button.contentEdgeInsets.right = 20
        button.layer.cornerRadius = 20
        button.layer.cornerCurve = .continuous
        button.layer.maskedCorners = [.layerMinXMaxYCorner]
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.heavy(size: 24).font
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.mealPlanLabel()
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.semanticContentAttribute = .forceRightToLeft
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset.bottom = 120
        tableView.register(classCell: MealPlanLabelCell.self)
        return tableView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 14).font
        label.textColor = R.color.darkGray()
        label.numberOfLines = 0
        label.text = R.string.localizable.editMealPlanLabel()
        label.setLineSpacing(lineHeightMultiple: 1.6)
        return label
    }()
    
    init(viewModel: MealPlanLabelsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        grabberBackgroundView.backgroundColor = .white.withAlphaComponent(0.95)
        
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateConstraintsDescriptionLabel()
                self?.view.layoutIfNeeded()
            }
        }
        
        makeConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let offset = grabberBackgroundView.frame.height + 46 - UIView.safeAreaTop
        tableView.contentInset.top = offset
        updateConstraintsDescriptionLabel()
    }

    @objc
    private func tappedDoneButton() {
        viewModel.saveChanges()
        viewModel.dismissView()
        self.dismiss(animated: true)
    }
    
    private func updateConstraintsDescriptionLabel() {
        let offset = grabberBackgroundView.frame.height + 46 - UIView.safeAreaTop
        let height = viewModel.necessaryHeight
        descriptionLabel.snp.updateConstraints {
            $0.top.equalToSuperview().offset(offset - 15 + height)
        }
    }
    
    private func makeConstraints() {
        self.view.addSubviews([tableView, grabberBackgroundView, grabberView, titleLabel, doneButton])
        tableView.addSubview(descriptionLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(24)
        }
        
        grabberBackgroundView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(36)
        }
        
        doneButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.greaterThanOrEqualTo(120)
        }
        doneButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        doneButton.setContentHuggingPriority(.init(1000), for: .horizontal)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(tableView.intrinsicContentSize.height + 25)
            $0.horizontalEdges.equalTo(self.view).inset(20)
        }
    }
}

extension MealPlanLabelsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(classCell: MealPlanLabelCell.self, indexPath: indexPath)
        
        guard viewModel.canMove(by: indexPath) else {
            cell.configureCreateCollection()
            cell.tapOnTitle = { [weak self] in
                self?.viewModel.createNewLabel()
            }
            return cell
        }
        
        let index = indexPath.row - 1
        cell.configure(title: viewModel.getLabelTitle(by: index),
                       color: viewModel.getColor(by: index))
        cell.configure(isSelect: viewModel.isSelect(by: index))
        cell.canDeleteCell(viewModel.canDeleteLabel(by: index))
        cell.tapOnTitle = { [weak self] in
            self?.viewModel.editLabel(by: index)
        }
        cell.tapDelete = { [weak self] in
            self?.viewModel.deleteLabel(by: index)
        }
        return cell
    }
}

extension MealPlanLabelsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            viewModel.createNewLabel()
            return
        }
        viewModel.updateSelect(by: indexPath.row - 1)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return viewModel.canMove(by: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.canMove(by: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        viewModel.swapLabels(from: sourceIndexPath.row - 1, to: destinationIndexPath.row - 1)
    }
    
    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let isFirstCell = !viewModel.canMove(by: proposedDestinationIndexPath)
        if isFirstCell {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        66
    }
}
