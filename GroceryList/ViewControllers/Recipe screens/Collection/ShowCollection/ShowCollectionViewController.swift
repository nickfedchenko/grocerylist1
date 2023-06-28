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
    
    private let contentShadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor(hex: "#E5F5F3")
        view.addCustomShadow(opacity: 0.15, radius: 11, offset: CGSize(width: 0, height: -12))
        return view
    }()
    
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
        label.font = UIFont.SFProDisplay.heavy(size: 32).font
        label.textColor = R.color.primaryDark()
        label.numberOfLines = 0
        label.text = R.string.localizable.collections()
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFCompactDisplay.semibold(size: 16).font
        label.textColor = R.color.darkGray()
        label.numberOfLines = 0
        label.text = R.string.localizable.selectOneOrMoreCollections()
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done".localized, for: .normal)
        button.setTitleColor(R.color.primaryDark(), for: .normal)
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
    
    private let contextMenuView = PantryEditMenuView()
    private let contextMenuBackgroundView = UIView()
    private var contextMenuIndex: IndexPath?
    private let deleteAlertView = ShowCollectionDeleteAlertView()
    private let deleteAlertBackgroundView = UIView()
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showContentView()
    }
    
    deinit {
        print("ShowCollectionViewController deinited")
    }
    
    private func setup() {
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        swipeDownRecognizer.direction = .down
        swipeDownRecognizer.delegate = self
        contentView.addGestureRecognizer(swipeDownRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneButtonAction))
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
        
        setupTableView()
        setupContextMenu()
        makeConstraints()
    }
    
    private func setupState() {
        descriptionLabel.isHidden = state == .edit

        tableView.isEditing = state == .edit
        if state == .edit {
            tableView.allowsSelectionDuringEditing = true
            tableView.semanticContentAttribute = .forceRightToLeft
            contentView.backgroundColor = .white
            navView.backgroundColor = .white.withAlphaComponent(0.9)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 66
        tableView.register(classCell: ShowCollectionCell.self)
    }
    
    private func setupContextMenu() {
        let menuTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuTapAction))
        contextMenuBackgroundView.addGestureRecognizer(menuTapRecognizer)
        contextMenuView.delegate = self
        contextMenuView.isHidden = true
        contextMenuBackgroundView.isHidden = true
        contextMenuBackgroundView.backgroundColor = .black.withAlphaComponent(0.2)
        
        let deleteTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteTapAction))
        deleteAlertBackgroundView.addGestureRecognizer(deleteTapRecognizer)
        deleteAlertView.isHidden = true
        deleteAlertBackgroundView.isHidden = true
        deleteAlertBackgroundView.backgroundColor = .black.withAlphaComponent(0.2)
        
        deleteAlertView.deleteTapped = { [weak self] in
            if let contextMenuIndex = self?.contextMenuIndex {
                self?.viewModel?.deleteCollection(by: contextMenuIndex.row - 1)
            }
            self?.deleteTapAction()
        }
        
        deleteAlertView.cancelTapped = { [weak self] in
            self?.deleteTapAction()
        }
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
    
    @objc
    private func menuTapAction() {
        contextMenuView.fadeOut()
        contextMenuBackgroundView.isHidden = true
    }
    
    @objc
    private func deleteTapAction() {
        deleteAlertView.fadeOut()
        deleteAlertBackgroundView.isHidden = true
    }
    
    private func hideContentView() {
        viewModel?.saveChanges()
        updateConstraints(with: 900, alpha: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.viewModel?.dismissView()
        }
    }
    
    private func showContentView() {
        updateConstraints(with: 0, alpha: 0.2)
    }
    
    private func updateConstraints(with offset: Double, alpha: Double) {
        contentView.snp.updateConstraints { $0.bottom.equalToSuperview().offset(offset) }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.backgroundColor = .black.withAlphaComponent(alpha)
            self?.view.layoutIfNeeded()
        }
    }
    
    private func tapContextMenu(point: CGPoint, cell: ShowCollectionCell) {
        let convertPointOnTable = cell.convert(point, to: tableView)
        let convertPointOnView = cell.convert(point, to: contentView)
        contextMenuIndex = tableView.indexPathForRow(at: convertPointOnTable)
        guard let contextMenuIndex else {
            return
        }
        contextMenuView.fadeIn()
        contextMenuBackgroundView.isHidden = false
        contextMenuView.setupColor(theme: viewModel?.getColor(by: contextMenuIndex.row - 1) ??
                                          ColorManager.shared.getFirstColor())

        let topSafeArea = UIView.safeAreaTop
        let offset: CGFloat = 32
        let tabBarRect: CGRect = .init(origin: .init(x: 0, y: self.view.bounds.height),
                                       size: .init(width: self.view.bounds.width, height: topSafeArea > 24 ? 90 : 60))
        let contextMenuRect: CGRect = .init(origin: .init(x: convertPointOnView.x, y: convertPointOnView.y + offset),
                                            size: .init(width: 250, height: 150))
        
        if contextMenuRect.intersects(tabBarRect) {
            contextMenuView.snp.updateConstraints {
                $0.top.equalToSuperview().offset(convertPointOnView.y - offset - 114)
            }
        } else {
            contextMenuView.snp.updateConstraints {
                $0.top.equalToSuperview().offset(convertPointOnView.y + offset)
            }
        }
    }
    
    private func makeConstraints() {
        self.view.addSubviews([contentShadowView, contentView, deleteAlertBackgroundView, deleteAlertView])
        contentView.addSubviews([tableView, navView, contextMenuBackgroundView, contextMenuView])
        navView.addSubviews([titleLabel, descriptionLabel, doneButton])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(self.view.frame.height)
            $0.height.equalTo(self.view.frame.height - 49)
        }
        
        contentShadowView.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(navView.snp.bottom).offset(-20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        navView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(doneButton.snp.leading).offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(22)
            $0.top.equalToSuperview().offset(57)
//            $0.trailing.equalTo(doneButton.snp.leading).offset(-16)
            $0.bottom.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-19)
            $0.top.equalToSuperview().offset(30)
            $0.height.equalTo(32)
        }
        doneButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        doneButton.setContentHuggingPriority(.init(1000), for: .horizontal)
        
        makeContextMenuConstraints()
    }
    
    private func makeContextMenuConstraints() {
        contextMenuBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contextMenuView.snp.makeConstraints {
            $0.width.equalTo(250)
            $0.height.equalTo(114)
            $0.top.equalToSuperview().offset(0)
            $0.trailing.equalToSuperview().offset(-20)
        }

        deleteAlertBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteAlertView.snp.makeConstraints {
            $0.width.equalTo(270)
            $0.center.equalToSuperview()
        }
    }
}

extension ShowCollectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getNumberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(classCell: ShowCollectionCell.self, indexPath: indexPath)
        guard let viewModel else {
            return cell
        }
        if indexPath.row == 0 {
            cell.configureCreateCollection()
        } else {
            cell.configure(title: viewModel.getCollectionTitle(by: indexPath.row - 1),
                           count: viewModel.getRecipeCount(by: indexPath.row - 1))
            cell.configure(isSelect: viewModel.isSelect(by: indexPath.row - 1))
            cell.configure(isTechnical: viewModel.isTechnicalCollection(by: indexPath.row - 1))
        }

        let isFirstCell = viewModel.canMove(by: indexPath)
        guard state == .edit && !isFirstCell else {
            return cell
        }
        cell.updateConstraintsForEditState()
        cell.configure(isTechnical: viewModel.isTechnicalCollection(by: indexPath.row - 1),
                       color: viewModel.getColor(by: indexPath.row - 1))
        cell.contextMenuTapped = { [weak self] point, cell in
            self?.tapContextMenu(point: point, cell: cell)
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
        let isFirstCell = viewModel?.canMove(by: indexPath) ?? false
        return state == .edit && !isFirstCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let isFirstCell = viewModel?.canMove(by: indexPath) ?? false
        return state == .edit && !isFirstCell
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
        let isFirstCell = viewModel?.canMove(by: proposedDestinationIndexPath) ?? false
        if isFirstCell {
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

extension ShowCollectionViewController: PantryEditMenuViewDelegate {
    func selectedState(state: PantryEditMenuView.MenuState) {
        contextMenuView.fadeOut { [weak self] in
            self?.contextMenuBackgroundView.isHidden = true
            switch state {
            case .edit:
                guard let self,
                      let contextMenuIndex = self.contextMenuIndex else {
                    return
                }
                self.viewModel?.editCollection(by: contextMenuIndex.row - 1)
            case .delete:
                self?.deleteAlertView.fadeIn()
                self?.deleteAlertBackgroundView.isHidden = false
            }
            self?.contextMenuView.removeSelected()
        }
    }
}
