//
//  ProductsViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import SnapKit
import UIKit

class ProductsViewController: UIViewController {
    
    enum DataItem: Hashable {
        case parent(Category)
        case child(Supplay)
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Category, DataItem>!
    
    var viewModel: ProductsViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupCollectionView()
        setupController()
        
        viewModel?.valueChangedCallback = { [self] in
            var snapshot = dataSource.snapshot()
            snapshot.deleteAllItems()
            self.dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
            self.reloadData()
        }
    }
    
    private func setupController() {
        nameOfListLabel.text = viewModel?.getNameOfList()
        view.backgroundColor = viewModel?.getColorForBackground()
        addItemView.backgroundColor = viewModel?.getAddItemViewColor()
        nameOfListLabel.textColor = viewModel?.getAddItemViewColor()
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
        viewModel?.settingsTapped()
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
    
    func setupCollectionView() {
        
        // MARK: Configure collection view
        collectionView.delegate = self
        
        // MARK: Cell registration
        let headerCellRegistration = UICollectionView.CellRegistration<HeaderListCell, Category> {
            (cell, indexPath, parent) in
           
            cell.setupCell(text: parent.name)
            
            var headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
           
            if parent.name == "Purchased".localized {
                headerDisclosureOption.tintColor = UIColor(hex: "#70B170")
            } else {
                headerDisclosureOption.tintColor = .white
            }
         
            
            cell.accessories = [.outlineDisclosure(options:headerDisclosureOption)]
        }
        
        let childCellRegistration = UICollectionView.CellRegistration<ProductListCell, Supplay> {
            (cell, indexPath, child) in
            
            let color = self.viewModel?.getColorForBackground()
            cell.setupCell(bcgColor: color, text: child.name, isPurchased: child.isPurchased)

        }
        
        // MARK: Initialize data source
        dataSource = UICollectionViewDiffableDataSource<Category, DataItem>(collectionView: collectionView) {
            (collectionView, indexPath, listItem) -> UICollectionViewCell? in
            
            switch listItem {
            case .parent(let parent):
                
                // Dequeue header cell
                let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration,
                                                                        for: indexPath,
                                                                        item: parent)
                return cell
                
            case .child(let child):
                
                // Dequeue cell
                let cell = collectionView.dequeueConfiguredReusableCell(using: childCellRegistration,
                                                                        for: indexPath,
                                                                        item: child)
                return cell
            }
        }
        reloadData()
      
    }
    
    private func reloadData() {
        // MARK: Construct data source snapshot
        // Loop through each parent items to create a section snapshots.
        guard let viewModel = viewModel else { return }
        for parent in viewModel.arrayWithSections {
            
            // Create a section snapshot
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<DataItem>()
            
            // Create a parent DataItem & append as parent
            let parentDataItem = DataItem.parent(parent)
            sectionSnapshot.append([parentDataItem])
            
            // Create an array of child items & append as children of parentDataItem
            let childDataItemArray = parent.supplays.map { DataItem.child($0) }
            sectionSnapshot.append(childDataItemArray, to: parentDataItem)
            
            // Expand this section by default
            sectionSnapshot.expand([parentDataItem])
            
            // Apply section snapshot to the respective collection view section
            
            dataSource.apply(sectionSnapshot, to: parent, animatingDifferences: true)
        }
        
    }
    
    // MARK: - Constraints

    private func setupConstraints() {
        view.addSubviews([navigationView, collectionView, addItemView])
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
            make.top.equalTo(navigationView.snp.bottom)
        }
    }
}

extension ProductsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource?.itemIdentifier(for: indexPath) else { return }
        switch model {
        case .parent(let category):
            print(category)
        case .child(let supplay):
            viewModel?.cellTapped(product: supplay)
        }
    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        didSelectItemAt indexPath: IndexPath) {
//        print(indexPath)
//
//        let selectedSection = dataSource.snapshot().sectionIdentifiers[indexPath.section]
//        let selectedSectionSnapshot = dataSource.snapshot(for: selectedSection)
//
//        // 1
//        // Obtain a reference to the selected parent
//        guard
//            let selectedParentDataItem = selectedSectionSnapshot.rootItems.first,
//            case let DataItem.parent(selectedParent) = selectedParentDataItem else {
//            return
//        }
//
//        // 2
//        // Obtain a reference to the selected child
//        let selectedChildDataItem = selectedSectionSnapshot.items[indexPath.item]
//        guard case let DataItem.child(selectedChild) = selectedChildDataItem else {
//            return
//        }
//
//        // 3
//        // Create a new parent with selectedChild's title
//        let newParent = Category(name: selectedChild.category, supplays: [])
//      //  Parent(title: selectedChild.title, children: selectedParent.children)
//        let newParentDataItem = DataItem.parent(newParent)
//
//        // 4
//        // Avoid crash when user tap on same cell twice (snapshot data must be unique)
//        guard selectedParent != newParent else {
//            return
//        }
//
//        // 5
//        // Replace the parent in section snapshot (by insert new item and then delete old item)
//        var newSectionSnapshot = selectedSectionSnapshot
//        newSectionSnapshot.insert([newParentDataItem], before: selectedParentDataItem)
//        newSectionSnapshot.delete([selectedParentDataItem])
//
//        // 6
//        // Reconstruct section snapshot by appending children to `newParentDataItem`
//       let allChildDataItems = selectedParent.supplays.map { DataItem.child($0) }
//        newSectionSnapshot.append(allChildDataItems, to: newParentDataItem)
//
//        // 7
//        // Expand the section
//        newSectionSnapshot.expand([newParentDataItem])
//
//        // 8
//        // Apply new section snapshot to selected section
//        dataSource.apply(newSectionSnapshot, to: selectedSection, animatingDifferences: true) {
//            // The cell's select state will be gone after applying a new snapshot, thus manually reselecting the cell.
//            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
//        }
//    }
}
