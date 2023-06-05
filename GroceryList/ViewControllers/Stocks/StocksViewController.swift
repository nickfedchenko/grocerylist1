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
    private var cellState: CellState = .normal
    
    init(viewModel: StocksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupEmptyView()
        updateColor()
        
        createDataSource()
        reloadData()
        
        makeConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationView.setupCustomRoundIfNeeded()
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
    
    private func updateColor() {
        let theme = viewModel.getTheme()
        self.view.backgroundColor = theme.medium
        navigationView.configureColor(theme: theme)
        emptyView.configure(color: theme.medium)
        navigationView.configureSharingView(sharingState: viewModel.getSharingState(),
                                            sharingUsers: viewModel.getShareImages(),
                                            color: theme.medium)
        linkView.configure(theme: theme)
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                                      cellProvider: { [self] _, indexPath, model in
            let cell = self.collectionView.reusableCell(classCell: StockCell.self, indexPath: indexPath)
            let cellModel = viewModel.getCellModel(model: model)
            cell.delegate = self
            cell.configure(cellModel)
            return cell
        })
        
        dataSource?.reorderingHandlers.canReorderItem = { _ in
            return true
        }
        
        dataSource?.reorderingHandlers.didReorder = { [weak self] transaction in
            let backingStore = transaction.finalSnapshot.itemIdentifiers
//            self?.viewModel.updatePantriesAfterMove(updatedPantries: backingStore)
        }
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Stock>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.getStocks())
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadItems(pantries: Set<Stock>) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Stock>()
        let pantries = Array(pantries)
        pantries.forEach({
            if snapshot.sectionIdentifier(containingItem: $0) != nil {
                snapshot.reloadItems([$0])
            }
        })
        dataSource?.apply(snapshot, animatingDifferences: true)
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
        guard cellState == .normal,
              recognizer.state == .began else {
            return
        }
        
        let location = recognizer.location(in: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: location),
                  let model = dataSource?.itemIdentifier(for: indexPath) else {
                      return
                  }
        viewModel.goToCreateItem(stock: model)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([containerView, emptyView, iconImageView, linkView,
                               collectionView, navigationView])
        
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
    }
}

extension StocksViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let stock = dataSource?.itemIdentifier(for: indexPath)
//        viewModel.goToCreateItem(stock: stock)
//    }
}

extension StocksViewController: StocksNavigationViewDelegate {
    func tapOnBackButton() {
        viewModel.goBackButtonPressed()
    }
    
    func tapOnSharingButton() {
        viewModel.goToCreateItem(stock: nil)
    }
    
    func tapOnSettingButton() {
        let snapshot = makeSnapshot()
        viewModel.goToListOptions(snapshot: snapshot)
    }
    
    func tapOnOutButton() {
        
    }
}

extension StocksViewController: StockCellDelegate {
    func tapMoveButton(gesture: UILongPressGestureRecognizer) {
        
    }
    
    func tapSelectEditState(cell: StockCell) {
        
    }
}
