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
        let layout = collectionViewLayoutManager.createCompositionalLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset.bottom = 60
        collectionView.contentInset.top = 44 + UIView.safeAreaTop
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.register(classCell: PantryCell.self)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, PantryModel>?
    private var collectionViewLayoutManager = PantryCollectionViewLayout()
    private let synchronizationActivityView = SynchronizationActivityView()
    private let titleBackgroundView = UIView()
    
    init(viewModel: PantryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = R.color.background()
        titleBackgroundView.backgroundColor = R.color.background()?.withAlphaComponent(0.9)
        createDataSource()
        reloadData()
        makeConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.showStarterPackIfNeeded()
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
        }
    }
    
    private func reloadData() {
        guard var snapshot = dataSource?.snapshot() else {
            return
        }
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.pantries)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadItems(pantries: Set<PantryModel>) {
        guard var snapshot = dataSource?.snapshot() else {
            return
        }
        let pantries = Array(pantries)
        pantries.forEach({
            if snapshot.sectionIdentifier(containingItem: $0) != nil {
                snapshot.reloadItems([$0])
            }
        })
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func makeConstraints() {
        view.addSubviews([collectionView, titleBackgroundView, titleLabel])
        
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
    }
}

extension PantryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let model = dataSource?.itemIdentifier(for: indexPath) else {
//            return
//        }
//        guard let section = self.collectionViewDataSource?.snapshot().sectionIdentifier(containingItem: model) else {
//            return
//        }
//        guard section.cellType == .usual else {
//            return
//        }
//        viewModel.cellTapped(with: model)
    }
}

extension PantryViewController: PantryCellDelegate {
    func tapMoveButton(gesture: UILongPressGestureRecognizer) {
        let gestureLocation = gesture.location(in: collectionView)
        guard let targetIndexPath = collectionView.indexPathForItem(at: gestureLocation),
              let cell = collectionView.cellForItem(at: targetIndexPath) as? PantryCell else {
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
    
    func tapContextMenu() {
        print("tapContextMenu")
    }
}
