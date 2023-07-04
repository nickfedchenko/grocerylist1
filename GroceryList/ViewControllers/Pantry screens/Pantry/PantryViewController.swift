//
//  PantryViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.05.2023.
//

import UIKit

final class PantryViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    enum Section: Hashable {
        case main
    }
    
    private var viewModel: PantryViewModel
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.pantryStocks()
        label.font = UIFont.SFProDisplay.heavy(size: 32).font
        label.textColor = R.color.primaryDark()
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let topSafeArea = UIView.safeAreaTop
        let topContentInset = topSafeArea + (topSafeArea > 24 ? 44 : 84)
        let layout = collectionViewLayoutManager.createCompositionalLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset.bottom = 60
        collectionView.contentInset.top = topContentInset
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.register(classCell: PantryCell.self)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, PantryModel>?
    private var collectionViewLayoutManager = PantryCollectionViewLayout()
    private let synchronizationActivityView = SynchronizationActivityView()
    private let contextMenuView = PantryEditMenuView()
    private let contextMenuBackgroundView = UIView()
    private var contextMenuIndex: IndexPath?
    private let titleBackgroundView = UIView()
    private let deleteAlertView = EditDeleteAlertView()
    private var movedCell: PantryCell?
    
    init(viewModel: PantryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as? MainTabBarController)?.pantryDelegate = self
        self.view.backgroundColor = R.color.background()
        titleBackgroundView.backgroundColor = R.color.background()
        
        viewModel.reloadData = { [weak self] in
            self?.reloadData()
        }
        viewModel.updateNavUI = { [weak self] in
            (self?.tabBarController as? MainTabBarController)?.isHideNavView(isHide: false)
            (self?.tabBarController as? MainTabBarController)?.customTabBar.isHidden = false
        }
        viewModel.sharingUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        setupContextMenu()
        createDataSource()
        makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadDataFromStorage()
        viewModel.showStarterPackIfNeeded()
        (self.tabBarController as? MainTabBarController)?.isHideNavView(isHide: false)
        (self.tabBarController as? MainTabBarController)?.customTabBar.isHidden = false
        (self.tabBarController as? MainTabBarController)?.setTextTabBar()
    }
    
    private func setupContextMenu() {
        let menuTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuTapAction))
        contextMenuBackgroundView.addGestureRecognizer(menuTapRecognizer)
        contextMenuView.delegate = self
        contextMenuView.isHidden = true
        contextMenuBackgroundView.isHidden = true
        
        deleteAlertView.deleteTapped = { [weak self] in
            if let contextMenuIndex = self?.contextMenuIndex,
               let model = self?.dataSource?.itemIdentifier(for: contextMenuIndex) {
                self?.viewModel.delete(model: model)
            }
            self?.updateDeleteAlertViewConstraint(with: 0)
        }
        
        deleteAlertView.cancelTapped = { [weak self] in
            self?.updateDeleteAlertViewConstraint(with: 0)
        }
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                                      cellProvider: { [self] _, indexPath, model in
            let cell = self.collectionView.reusableCell(classCell: PantryCell.self, indexPath: indexPath)
            let cellModel = viewModel.getCellModel(by: indexPath, and: model)
            cell.delegate = self
            cell.configure(cellModel)
            return cell
        })
        
        dataSource?.reorderingHandlers.canReorderItem = { _ in
            return true
        }
        
        dataSource?.reorderingHandlers.didReorder = { [weak self] transaction in
            let backingStore = transaction.finalSnapshot.itemIdentifiers
            self?.viewModel.updatePantriesAfterMove(updatedPantries: backingStore)
            AmplitudeManager.shared.logEvent(.pantryListRearrage)
        }
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PantryModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.pantries)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func reloadItems(pantries: Set<PantryModel>) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PantryModel>()
        let pantries = Array(pantries)
        pantries.forEach({
            if snapshot.sectionIdentifier(containingItem: $0) != nil {
                snapshot.reloadItems([$0])
            }
        })
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateDeleteAlertViewConstraint(with height: Double) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.deleteAlertView.snp.updateConstraints {
                $0.height.equalTo(height)
            }
            (self?.tabBarController as? MainTabBarController)?.customTabBar.layoutIfNeeded()
        }
    }
    
    private func contextViewUpdateConstraints(point: CGPoint) {
        let topSafeArea = UIView.safeAreaTop 
        let offset: CGFloat = 40
        
        let tabBarRect: CGRect = .init(origin: .init(x: 0, y: self.view.bounds.height),
                                       size: .init(width: self.view.bounds.width, height: topSafeArea > 24 ? 90 : 60))
        let contextMenuRect: CGRect = .init(origin: .init(x: point.x, y: point.y + offset),
                                            size: .init(width: 180, height: 180))
        
        if contextMenuRect.intersects(tabBarRect) {
            contextMenuView.snp.updateConstraints {
                $0.top.equalToSuperview().offset(point.y - offset)
            }
        } else {
            contextMenuView.snp.updateConstraints {
                $0.top.equalToSuperview().offset(point.y + offset)
            }
        }
    }
    
    @objc
    private func menuTapAction() {
        contextMenuView.fadeOut()
        contextMenuBackgroundView.isHidden = true
    }
    
    private func makeConstraints() {
        view.addSubviews([collectionView, titleBackgroundView, titleLabel,
                          contextMenuBackgroundView, contextMenuView])
        (self.tabBarController as? MainTabBarController)?.customTabBar.addSubview(deleteAlertView)
        
        titleBackgroundView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(titleBackgroundView).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalTo(view.snp.width)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        contextMenuBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contextMenuView.snp.makeConstraints {
            $0.width.equalTo(180)
            $0.height.equalTo(113)
            $0.top.equalToSuperview().offset(0)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        deleteAlertView.snp.makeConstraints {
            $0.leading.centerX.bottom.equalToSuperview()
            $0.height.equalTo(0)
        }
    }
}

extension PantryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        viewModel.showStocks(controller: self, model: model)
    }
}

extension PantryViewController: PantryCellDelegate {
    func tapMoveButton(gesture: UILongPressGestureRecognizer) {
        let gestureLocation = gesture.location(in: collectionView)
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView.indexPathForItem(at: gestureLocation),
                  let cell = collectionView.cellForItem(at: targetIndexPath) as? PantryCell else {
                return
            }
            movedCell = cell
            movedCell?.addDragAndDropShadow()
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gestureLocation)
        case .ended:
            movedCell?.removeDragAndDropShadow()
            collectionView.endInteractiveMovement()
        default:
            movedCell?.removeDragAndDropShadow()
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func tapContextMenu(point: CGPoint, cell: PantryCell) {
        let convertPointOnCollection = cell.convert(point, to: collectionView)
        let convertPointOnView = cell.convert(point, to: self.view)
        contextMenuIndex = collectionView.indexPathForItem(at: convertPointOnCollection)
        guard let contextMenuIndex,
              let model = dataSource?.itemIdentifier(for: contextMenuIndex) else {
            return
        }
        contextMenuView.fadeIn()
        contextMenuBackgroundView.isHidden = false
        contextMenuView.setupColor(theme: viewModel.getColor(model: model))
        contextViewUpdateConstraints(point: convertPointOnView)
    }
    
    func tapSharing(cell: PantryCell) {
        guard let index = collectionView.indexPath(for: cell),
              let model = dataSource?.itemIdentifier(for: index) else {
            return
        }
        
        viewModel.sharingTapped(model: model)
    }
}

extension PantryViewController: PantryEditMenuViewDelegate {
    func selectedState(state: PantryEditMenuView.MenuState) {
        contextMenuView.fadeOut { [weak self] in
            self?.contextMenuBackgroundView.isHidden = true
            switch state {
            case .edit:
                AmplitudeManager.shared.logEvent(.pantryContextEdit)
                guard let self,
                      let contextMenuIndex = self.contextMenuIndex,
                      let model = self.dataSource?.itemIdentifier(for: contextMenuIndex) else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
                    (self.tabBarController as? MainTabBarController)?.isHideNavView(isHide: true)
                }
                self.viewModel.showEditPantry(presentedController: self, pantry: model)
            case .delete:
                AmplitudeManager.shared.logEvent(.pantryContextDelete)
                self?.updateDeleteAlertViewConstraint(with: 224)
            }
            self?.contextMenuView.removeSelected()
        }
    }
}

extension PantryViewController: MainTabBarControllerPantryDelegate {
    func updatePantryUI(_ pantry: PantryModel) {
        viewModel.addPantry()
    }
    
    func tappedAddItem() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
            (self.tabBarController as? MainTabBarController)?.isHideNavView(isHide: true)
            (self.tabBarController as? MainTabBarController)?.customTabBar.isHidden = true
        }
        viewModel.tappedAddItem(presentedController: self)
    }
}
