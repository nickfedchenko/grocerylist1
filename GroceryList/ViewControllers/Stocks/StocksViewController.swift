//
//  StocksViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 31.05.2023.
//

import UIKit

final class StocksViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    enum Section: Hashable {
        case outOfStack
        case main
    }
    
    private var viewModel: StocksViewModel
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Stock>?
    private lazy var collectionView: UICollectionView = {
        let layout = compositionalLayout
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset.bottom = 60
        collectionView.contentInset.top = 16
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.register(classCell: StockCell.self)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        return collectionView
    }()
    
    private lazy var compositionalLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(56))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .estimated(1))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }()
    
    private let containerView = UIView()
    private let navigationView = StocksNavigationView()
    private let emptyView = StocksEmptyView()
    private let iconImageView = UIImageView()
    private let linkView = StocksLinkView()
    
    private let editTabBarView = EditTabBarView()
    private let editView = UIView()
    private lazy var cancelEditButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(cancelEditButtonPressed), for: .touchUpInside)
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 16).font
        button.isHidden = true
        return button
    }()
    
    init(viewModel: StocksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as? MainTabBarController)?.stocksDelegate = self
        viewModel.delegate = self
        editTabBarView.delegate = self
        
        setup()
        setupEmptyView()
        updateColor()
        
        createDataSource()
        reloadDataSource()
        
        makeConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationView.setupCustomRoundIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as? MainTabBarController)?.isHideNavView(isHide: true)
        (self.tabBarController as? MainTabBarController)?.setTextTabBar(text: "item", color: viewModel.getTheme().medium)
    }
    
    private func setup() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 24
        containerView.layer.maskedCorners = [.layerMinXMinYCorner]
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = viewModel.pantryIcon?.withTintColor(viewModel.getTheme().medium.withAlphaComponent(0.25))
        
        navigationView.delegate = self
        navigationView.configureTitle(icon: viewModel.pantryIcon,
                                      title: viewModel.pantryName)
        navigationView.configureOutOfStock(total: viewModel.availabilityOfGoods.total,
                                           outOfStock: viewModel.availabilityOfGoods.outOfStocks)
        navigationView.configureSharingView(sharingState: viewModel.getSharingState(),
                                            sharingUsers: viewModel.getShareImages(),
                                            color: viewModel.getTheme().medium)

        linkView.configureLink(listNames: viewModel.getSynchronizedListNames())
    }
    
    private func setupEmptyView() {
        emptyView.isHidden = !viewModel.getStocks().isEmpty
        collectionView.isHidden = viewModel.getStocks().isEmpty
    }
    
    private func updateTitle() {
        navigationView.configureTitle(icon: viewModel.pantryIcon,
                                      title: viewModel.pantryName)
    }
    
    private func updateColor() {
        let theme = viewModel.getTheme()
        self.view.backgroundColor = theme.medium
        editView.backgroundColor = theme.medium
        navigationView.configureColor(theme: theme)
        emptyView.configure(color: theme.medium)
        navigationView.configureSharingView(sharingState: viewModel.getSharingState(),
                                            sharingUsers: viewModel.getShareImages(),
                                            color: theme.medium)
        linkView.configure(theme: theme)
        (self.tabBarController as? MainTabBarController)?.setTextTabBar(text: "item", color: theme.medium)
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                        cellProvider: { _, indexPath, model in
            let cell = self.collectionView.reusableCell(classCell: StockCell.self, indexPath: indexPath)
            let cellModel = self.viewModel.getCellModel(model: model)
            let isEditCell = self.viewModel.editStocks.contains(where: { $0.id == model.id })
            cell.delegate = self
            cell.configure(cellModel)
            cell.updateEditCheckmark(isSelect: isEditCell)
            return cell
        })
        
        dataSource?.reorderingHandlers.canReorderItem = { [weak self] _ in
            return self?.viewModel.stateCellModel == .edit
        }
        
        dataSource?.reorderingHandlers.didReorder = { [weak self] transaction in
            let backingStore = transaction.finalSnapshot.itemIdentifiers
            self?.viewModel.updateStocksAfterMove(stocks: backingStore)
        }
    }
    
    internal func reloadDataSource() {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Section, Stock>()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.viewModel.getStocks())
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func makeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(collectionView.contentSize, false, 0)
        collectionView.drawHierarchy(in: collectionView.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc
    private func longPressAction(_ recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self.collectionView)
        guard viewModel.stateCellModel == .normal,
              let indexPath = self.collectionView.indexPathForItem(at: location),
              let model = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        viewModel.goToCreateItem(stock: model)
    }
    
    @objc
    private func editCellButtonPressed() {
        let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        let bottomPadding = safeAreaBottom == 0 ? 12 : safeAreaBottom
        let editTabBarHeight = 72 + bottomPadding
        editView.snp.updateConstraints { $0.height.equalTo(47) }
        editTabBarView.snp.updateConstraints { $0.height.equalTo(editTabBarHeight) }
        cancelEditButton.isHidden = false
        cancelEditButton.alpha = 0
        
        let expandTransform: CGAffineTransform = CGAffineTransformMakeScale(1.05, 1.05)
        UIView.transition(with: self.cancelEditButton, duration: 0.1,
                          options: .transitionCrossDissolve, animations: { [weak self] in
            self?.cancelEditButton.transform = expandTransform
        }, completion: { _ in
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 0.2, options: .curveEaseOut, animations: { [weak self] in
                self?.cancelEditButton.alpha = 1
                self?.cancelEditButton.transform = CGAffineTransformInvert(expandTransform)
                self?.view.layoutIfNeeded()
                (self?.tabBarController as? MainTabBarController)?.customTabBar.layoutIfNeeded()
            }, completion: nil)
        })
        
        collectionView.reloadData()
    }
    
    @objc
    private func cancelEditButtonPressed() {
        viewModel.updateEditState(isEdit: false)
        editView.snp.updateConstraints { $0.height.equalTo(0) }
        editTabBarView.snp.updateConstraints { $0.height.equalTo(0) }
        cancelEditButton.isHidden = true
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.cancelEditButton.alpha = 0
            self?.view.layoutIfNeeded()
            (self?.tabBarController as? MainTabBarController)?.customTabBar.layoutIfNeeded()
        }
        editTabBarView.setCountSelectedItems(0)
        collectionView.reloadData()
    }
    
    private func makeConstraints() {
        self.view.addSubviews([containerView, emptyView, iconImageView,
                               collectionView, navigationView, editView])
        collectionView.addSubview(linkView)
        (self.tabBarController as? MainTabBarController)?.customTabBar.addSubview(editTabBarView)
        editView.addSubviews([cancelEditButton])
        
        navigationView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(88)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(328)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.bottom.equalTo(linkView.snp.top).offset(-24)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(100)
        }
        
        linkView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-114)
        }
        
        setupEditViewConstraints()
    }
    
    private func setupEditViewConstraints() {
        editView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(navigationView)
            make.height.equalTo(0)
        }
        
        cancelEditButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        editTabBarView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
    }
}

extension StocksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let stock = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        let cell = collectionView.cellForItem(at: indexPath) as? StockCell
        
        guard viewModel.stateCellModel == .normal else {
            viewModel.updateEditStock(stock)
            let isEditCell = viewModel.editStocks.contains(where: { $0.id == stock.id })
            cell?.updateEditCheckmark(isSelect: isEditCell)
            editTabBarView.setCountSelectedItems(viewModel.editStocks.count)
            if viewModel.isSelectedAllStockForEditing || viewModel.editStocks.count == 0 {
                editTabBarView.isSelectAll(viewModel.isSelectedAllStockForEditing)
            }
            return
        }
        
        viewModel.updateStockStatus(stock: stock)
    }
}

extension StocksViewController: StocksViewModelDelegate {
    func reloadData() {
        setupEmptyView()
        navigationView.configureOutOfStock(total: viewModel.availabilityOfGoods.total,
                                           outOfStock: viewModel.availabilityOfGoods.outOfStocks)
        reloadDataSource()
    }
    
    func editState() {
        editCellButtonPressed()
    }
    
    func updateController() {
        updateColor()
        updateTitle()
        collectionView.reloadData()
    }
    
    func updateUIEditTabBar() {
        editTabBarView.setCountSelectedItems(viewModel.editStocks.count)
    }
}

extension StocksViewController: StocksNavigationViewDelegate {
    func tapOnBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tapOnSharingButton() {
        
    }
    
    func tapOnSettingButton() {
        let snapshot = makeSnapshot()
        viewModel.goToListOptions(snapshot: snapshot)
    }
    
    func tapOnOutButton() {
        viewModel.sortIsAvailability()
    }
}

extension StocksViewController: StockCellDelegate {
    func tapMoveButton(gesture: UILongPressGestureRecognizer) {
        let gestureLocation = gesture.location(in: collectionView)
        guard let targetIndexPath = collectionView.indexPathForItem(at: gestureLocation),
              let cell = collectionView.cellForItem(at: targetIndexPath) as? StockCell else {
            return
        }
        
        switch gesture.state {
        case .began:
            cell.addDragAndDropShadow()
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gestureLocation)
        case .ended:
            cell.removeDragAndDropShadow()
            collectionView.endInteractiveMovement()
        default:
            cell.removeDragAndDropShadow()
            collectionView.cancelInteractiveMovement()
        }
    }
}

extension StocksViewController: MainTabBarControllerStocksDelegate {
    func tappedAddItem() {
        viewModel.goToCreateItem(stock: nil)
    }
}

extension StocksViewController: EditTabBarViewDelegate {
    func tappedSelectAll() {
        viewModel.addAllProductsToEdit()
        collectionView.reloadData()
    }
    
    func tappedMove() {
        viewModel.showListView(contentViewHeigh: self.view.frame.height - 60, state: .move, delegate: self)
    }
    
    func tappedCopy() {
        viewModel.showListView(contentViewHeigh: self.view.frame.height - 60, state: .copy, delegate: self)
    }
    
    func tappedDelete() {
        viewModel.deleteProducts()
        cancelEditButtonPressed()
    }
    
    func tappedClearAll() {
        viewModel.resetEditProducts()
        collectionView.reloadData()
    }
}

extension StocksViewController: EditSelectListDelegate {
    func productsSuccessfullyMoved() {
        viewModel.moveProducts()
        cancelEditButtonPressed()
    }
    
    func productsSuccessfullyCopied() {
        cancelEditButtonPressed()
    }
}
