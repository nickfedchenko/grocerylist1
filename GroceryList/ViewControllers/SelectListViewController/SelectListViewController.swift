//
//  SelectListViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import SnapKit
import UIKit

class SelectListViewController: UIViewController {
    
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionModel, GroceryListsModel>?
    var viewModel: SelectListViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupCollectionView()
        createTableViewDataSource()
        viewModel?.reloadDataCallBack = { [weak self] in
            self?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard var snapshot = collectionViewDataSource?.snapshot() else { return }
        snapshot.deleteAllItems()
        collectionViewDataSource?.apply(snapshot)
        viewModel?.reloadDataFromStorage()
    }
    
    // MARK: - UI
    
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F9FBEB")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private func setupConstraints() {
        view.backgroundColor = .clear
        view.addSubviews([contentView])
        contentView.addSubviews([collectionView])
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(385)
        }
        
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
    
}

// MARK: - CollectionView
extension SelectListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = collectionViewDataSource?.itemIdentifier(for: indexPath) else { return }
        guard let section = self.collectionViewDataSource?.snapshot().sectionIdentifier(containingItem: model) else { return }
        guard section.cellType == .usual else { return }
        viewModel?.cellTapped(with: model)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(hex: "#E8F5F3")
        collectionView.register(GroceryCollectionViewCell.self,
                                forCellWithReuseIdentifier: "GroceryListsCollectionViewCell")
        collectionView.register(EmptyColoredCell.self,
                                forCellWithReuseIdentifier: "EmptyColoredCell")
        collectionView.register(InstructionCell.self,
                                forCellWithReuseIdentifier: "InstructionCell")
        collectionView.register(MainScreenTopCell.self,
                                forCellWithReuseIdentifier: "MainScreenTopCell")
        collectionView.register(GroceryCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "GroceryCollectionViewHeader")
    }
    
    private func createTableViewDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                                      cellProvider: { collectionView, indexPath, model in
            switch self.viewModel?.model[indexPath.section].cellType {
            
            // top view with switcher
            case .topMenu:
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "MainScreenTopCell", for: indexPath)
                as? MainScreenTopCell
                return cell
                
            // empty cell in bottom of collection
            case .empty:
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyColoredCell", for: indexPath)
                as? EmptyColoredCell
                guard let viewModel = self.viewModel else { return UICollectionViewCell() }
                let isTopRouned = viewModel.isTopRounded(at: indexPath)
                let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
                let color = viewModel.getBGColorForEmptyCell(at: indexPath)
                cell?.setupCell(bckgColor: color, isTopRounded: isTopRouned, isBottomRounded: isBottomRounded)
                return cell
            
            // cell for cold start
            case .instruction:
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "InstructionCell", for: indexPath)
                as? InstructionCell
                return cell
          
            // default cell for list
            default:
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "GroceryListsCollectionViewCell",
                                                                   for: indexPath) as? GroceryCollectionViewCell
                guard let viewModel = self.viewModel else { return UICollectionViewCell() }
                let name = viewModel.getNameOfList(at: indexPath)
                let isTopRouned = viewModel.isTopRounded(at: indexPath)
                let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
                let numberOfItems = viewModel.getnumberOfProductsInside(at: indexPath)
                let color = viewModel.getBGColor(at: indexPath)
                cell?.setupCell(nameOfList: name, bckgColor: color, isTopRounded: isTopRouned,
                                isBottomRounded: isBottomRounded, numberOfItemsInside: numberOfItems, isFavorite: model.isFavorite)
              
                return cell
            }
        })
        addHeaderToCollectionView()
    }
    
    private func addHeaderToCollectionView() {
        collectionViewDataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                      withReuseIdentifier: "GroceryCollectionViewHeader",
                                                                                      for: indexPath) as? GroceryCollectionViewHeader else { return nil }
            
            guard let model = self.collectionViewDataSource?.itemIdentifier(for: indexPath) else { return nil }
            guard let section = self.collectionViewDataSource?.snapshot().sectionIdentifier(containingItem: model) else { return nil }
            sectionHeader.setupHeader(sectionType: section.sectionType)
            return sectionHeader
        }
    }
    
    // ReloadData
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, GroceryListsModel>()
        guard let viewModel = viewModel else { return }
        snapshot.appendSections(viewModel.model)
        for section in viewModel.model {
            snapshot.appendItems(section.lists, toSection: section)
        }
        collectionViewDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadItems(lists: Set<GroceryListsModel>) {
        guard var snapshot = collectionViewDataSource?.snapshot() else { return }
        let array = Array(lists)
        array.forEach({ if snapshot.sectionIdentifier(containingItem: $0) != nil { snapshot.reloadItems([$0]) } })
       
        collectionViewDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    // CollectionViewLayout
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            return self.createLayout()
        }
        return layout
    }
    
    private func createLayout(isHeaderNeeded: Bool = true) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(72))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .estimated(44))
        let layutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutHeaderSize,
                                                                             elementKind: UICollectionView.elementKindSectionHeader,
                                                                             alignment: .top)
        return layutSectionHeader
    }
}
