//
//  ProductsViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import SnapKit
import UIKit
import zlib

class ProductsViewController: UIViewController {
    
    enum DataItem: Hashable {
        case parent(Category)
        case child(Product)
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, DataItem>!
    var viewModel: ProductsViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupCollectionView()
        setupController()
        
        viewModel?.valueChangedCallback = { [weak self] in
            self?.reloadData()
        }
    }
    
    private func setupController() {
        nameOfListLabel.text = viewModel?.getNameOfList()
        view.backgroundColor = viewModel?.getColorForBackground()
        addItemView.backgroundColor = viewModel?.getColorForForeground()
        nameOfListLabel.textColor = viewModel?.getColorForForeground()
        navigationView.backgroundColor = viewModel?.getColorForBackground()
        collectionView.reloadData()
    }
    
    deinit {
        print("ProductView deinited")
    }
    
    @objc
    private func arrowBackButtonPressed() {
        viewModel?.goBackButtonPressed()
    }
    
    @objc
    private func contextMenuButtonPressed() {
        let snapshot = makeSnapshot()
        viewModel?.settingsTapped(with: snapshot)
    }
    
    private func makeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(collectionView.contentSize, false, 0)
        collectionView.drawHierarchy(in: collectionView.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - UI
    private let navigationView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var arrowBackButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(arrowBackButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "greenArrowBack"), for: .normal)
        return button
    }()
    
    private let nameOfListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        return label
    }()
    
    private lazy var contextMenuButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(contextMenuButtonPressed), for: .touchUpInside)
        button.setImage(UIImage(named: "contextMenu"), for: .normal)
        return button
    }()
    
    private let addItemView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 32
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner]
        return view
    }()
    
    private let plusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "whitePlusImage")
        return imageView
    }()
    
    private let addItemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = .white
        label.text = "AddItem".localized
        return label
    }()
    
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.headerMode = .firstItemInSection
        layoutConfig.showsSeparators = false
        layoutConfig.backgroundColor = .clear
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        layout.collectionView?.backgroundColor = .white
        return layout
    }
    
    // MARK: - CollectionView
    func setupCollectionView() {
        
        // MARK: Configure collection view
        collectionView.delegate = self
        
        // MARK: Cell registration
        let headerCellRegistration = UICollectionView.CellRegistration<HeaderListCell, Category> { [ weak self ](cell, _, parent) in
            
            let color = self?.viewModel?.getColorForForeground()
            let bcgColor = self?.viewModel?.getColorForBackground()
            cell.setupCell(text: parent.name, color: color, bcgColor: bcgColor, isExpand: parent.isExpanded)
        }
        
        let childCellRegistration = UICollectionView.CellRegistration<ProductListCell, Product> { [ weak self ] (cell, _, child) in
            
            let bcgColor = self?.viewModel?.getColorForBackground()
            let textColor = self?.viewModel?.getColorForForeground()
            cell.setupCell(bcgColor: bcgColor, textColor: textColor, text: child.name, isPurchased: child.isPurchased)
            
            cell.swipeDeleteAction = {
                self?.viewModel?.delete(product: child)
//                var snapshot = self?.dataSource.snapshot()
//                guard var snapshot = snapshot else { return }
//                snapshot.deleteItems(parent)
            }
            
            cell.swipeToAddOrDeleteFromFavorite = {
               // viewModel.addOrDeleteFromFavorite(with: model)
   
            }
            
        }
        
        // MARK: Initialize data source
        dataSource = UICollectionViewDiffableDataSource<Section, DataItem>(collectionView: collectionView) { (collectionView, indexPath, listItem) ->
            UICollectionViewCell? in
            
            switch listItem {
            case .parent(let parent):
                let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration,
                                                                        for: indexPath,
                                                                        item: parent)
                return cell
                
            case .child(let child):
                let cell = collectionView.dequeueConfiguredReusableCell(using: childCellRegistration,
                                                                        for: indexPath,
                                                                        item: child)
                return cell
            }
        }
        reloadData()
    }
    
    enum Section: Hashable {
        case main
    }
    
    private func reloadData() {
        var snapshot = dataSource.snapshot()
        
        guard let viewModel = viewModel else { return }
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections([.main])
            dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<DataItem>()
        for parent in viewModel.arrayWithSections {
            
            let parentDataItem = DataItem.parent(parent)
            let childDataItemArray = parent.products.map { DataItem.child($0) }
            
            sectionSnapshot.append([parentDataItem])
            sectionSnapshot.append(childDataItemArray, to: parentDataItem)
            
            if parent.isExpanded {
                sectionSnapshot.expand([parentDataItem])
            }
        }
        self.dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: true)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        view.addSubviews([collectionView, navigationView, addItemView])
        navigationView.addSubviews([arrowBackButton, nameOfListLabel, contextMenuButton])
        addItemView.addSubviews([plusImage, addItemLabel])
        
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.right.left.equalToSuperview()
            make.height.equalTo(66)
        }
        
        arrowBackButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalToSuperview()
            make.width.equalTo(17)
            make.height.equalTo(24)
        }
        
        nameOfListLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        contextMenuButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(26)
            make.width.equalTo(28)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        addItemView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(82)
            make.width.equalTo(207)
        }
        
        plusImage.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
        }
        
        addItemLabel.snp.makeConstraints { make in
            make.left.equalTo(plusImage.snp.right).inset(-16)
            make.centerY.equalTo(plusImage)
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom).inset(30)
        }
    }
}

// MARK: - CellTapped
extension ProductsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        
        guard let model = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        switch model {
        case .parent(let category):
            print(category)
        case .child(let product):
            let cell = collectionView.cellForItem(at: indexPath) as? ProductListCell
            if product.isPurchased {
                cell?.removeCheckmark { [weak self] in
                    self?.viewModel?.cellTapped(product: product)
                }
            } else {
                let color = viewModel?.getColorForForeground()
                cell?.addCheckmark(color: color) { [weak self] in
                    self?.viewModel?.cellTapped(product: product)
                }
            }
        }
    }
    
    // Схлопывание и расширения родительской ячейки + анимация
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        var snap = dataSource.snapshot(for: .main)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        let sectionSnapshot = snap.snapshot(of: item, includingParent: false)
        let hasChildren = sectionSnapshot.items.count > 0
        
        if hasChildren {
            if snap.isExpanded(item) {
                switchModelAndSetupParametr(item: item, isExpanded: false, indexPath: indexPath)
                snap.collapse([item])
            } else {
                switchModelAndSetupParametr(item: item, isExpanded: true, indexPath: indexPath)
                snap.expand([item])
            }
            self.dataSource.apply(snap, to: .main)
        }
        return !hasChildren
    }
    
    private func switchModelAndSetupParametr(item: DataItem, isExpanded: Bool, indexPath: IndexPath) {
        switch item {
        case .parent(let category):
            guard let ind = self.viewModel?.getCellIndex(with: category) else { return }
            self.viewModel?.arrayWithSections[ind].isExpanded = isExpanded
            let cellTypeIsPurchased = category.name == "Purchased".localized
            self.shouldExpandCell(isExpanded: isExpanded, ind: indexPath,
                                  color: viewModel?.getColorForForeground(), isPurchased: cellTypeIsPurchased)
        case .child:
            print("")
        }
    }
    
    private func shouldExpandCell(isExpanded: Bool, ind: IndexPath, color: UIColor?, isPurchased: Bool) {
        let cell = collectionView.cellForItem(at: ind) as? HeaderListCell
        
        if isExpanded {
            cell?.expanding(isPurchased: isPurchased)
        } else {
            cell?.collapsing(color: color, isPurchased: isPurchased)
        }
    }
}

// MARK: - View model delegate
extension ProductsViewController: ProductsViewModelDelegate {
    func updateController() {
        setupController()
    }
}
