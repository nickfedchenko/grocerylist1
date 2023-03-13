//
//  ShowCollectionViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import UIKit

final class ShowCollectionViewController: UIViewController {
    
    enum ShowCollectionState {
        case select
        case edit
    }
    
    var viewModel: ShowCollectionViewModel?
    
    private let contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = UIColor(hex: "#E5F5F3")
        return view
    }()
    
    private let navView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = UIColor(hex: "#1A645A")
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done".localized, for: .normal)
        button.setTitleColor(UIColor(hex: "#1A645A"), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.bold(size: 18).font
        button.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private var contentViewHeight = 290.0
    private var state: ShowCollectionState = .select {
        didSet { setupState() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        state = viewModel?.viewState ?? .select
        
        viewModel?.updateData = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showContentView()
    }
    
    private func setup() {
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        swipeDownRecognizer.direction = .down
        swipeDownRecognizer.delegate = self
        contentView.addGestureRecognizer(swipeDownRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneButtonAction))
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
        
        calculateContentViewHeight()
        setupTableView()
        makeConstraints()
    }
    
    private func setupState() {
        titleLabel.text = state.title
        titleLabel.font = state.font
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(state == .select ? 24 : 30)
        }
        
        tableView.isEditing = state == .edit
        if state == .edit {
            tableView.allowsSelectionDuringEditing = true
            tableView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    private func calculateContentViewHeight() {
        let maxHeight = self.view.frame.height * 0.9
        contentViewHeight += viewModel?.necessaryHeight ?? 0
        tableView.isScrollEnabled = contentViewHeight > maxHeight
        contentViewHeight = contentViewHeight > maxHeight ? maxHeight : contentViewHeight
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.bottom = 203
        tableView.rowHeight = 66
        tableView.register(classCell: ShowCollectionCell.self)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .down: hideContentView()
        default: break
        }
    }
    
    @objc
    private func doneButtonAction() {
        hideContentView()
    }
    
    private func hideContentView() {
        viewModel?.saveChanges()
        updateConstraints(with: contentViewHeight, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false)
        }
    }
    
    private func showContentView() {
        updateConstraints(with: 0, alpha: 0.2)
    }
    
    private func updateConstraints(with inset: Double, alpha: Double) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            self?.view.backgroundColor = .black.withAlphaComponent(alpha)
            self?.contentView.snp.updateConstraints { $0.bottom.equalToSuperview().offset(inset) }
            
            self?.view.layoutIfNeeded()
        }
    }
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubviews([tableView, navView])
        navView.addSubviews([titleLabel, doneButton])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(contentViewHeight)
            $0.height.equalTo(contentViewHeight)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(navView.snp.bottom).offset(-20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        navView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(doneButton.snp.leading).offset(-16)
            $0.bottom.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-19)
            $0.top.equalToSuperview().offset(30)
            $0.height.equalTo(32)
        }
        doneButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        doneButton.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
}

extension ShowCollectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getNumberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(classCell: ShowCollectionCell.self, indexPath: indexPath)
        guard let viewModel else { return cell }
        if indexPath.row == 0 {
            cell.configureCreateCollection()
        } else {
            cell.configure(title: viewModel.getCollectionTitle(by: indexPath.row - 1),
                           count: viewModel.getRecipeCount(by: indexPath.row - 1))
            cell.configure(isSelect: viewModel.isSelect(by: indexPath.row - 1))
        }

        let isFirstLastCell = viewModel.canMove(by: indexPath)
        guard state == .edit && !isFirstLastCell else {
            return cell
        }
        cell.updateConstraintsForEditState()
        cell.deleteTapped = {
            tableView.beginUpdates()
            viewModel.deleteCollection(by: indexPath.row - 1)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        return cell
    }
}

extension ShowCollectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            viewModel?.createCollectionTapped()
            return
        }
        guard state == .select else {
            return
        }
        viewModel?.updateSelect(by: indexPath.row - 1)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let isFirstLastCell = viewModel?.canMove(by: indexPath) ?? false
        return state == .edit && !isFirstLastCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let isFirstLastCell = viewModel?.canMove(by: indexPath) ?? false
        return state == .edit && !isFirstLastCell
    }
    
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        viewModel?.swapCategories(from: sourceIndexPath.row - 1, to: destinationIndexPath.row - 1)
    }
    
    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let isFirstLastCell = viewModel?.canMove(by: proposedDestinationIndexPath) ?? false
        if isFirstLastCell {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
}

extension ShowCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.tableView) ?? false)
    }
}

extension ShowCollectionViewController.ShowCollectionState {
    var title: String {
        switch self {
        case .select: return R.string.localizable.selectOneOrMoreCollections()
        case .edit: return R.string.localizable.collections()
        }
    }
    
    var font: UIFont {
        switch self {
        case .select: return UIFont.SFProRounded.semibold(size: 17).font
        case .edit: return UIFont.SFPro.semibold(size: 22).font
        }
    }
}
