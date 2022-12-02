//
//  MainScreenViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import SnapKit
import UIKit

class MainScreenViewController: UIViewController {
    
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionModel, GroceryListsModel>?
    var viewModel: MainScreenViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupCollectionView()
        addRecognizer()
        createTableViewDataSource()
        viewModel?.reloadDataCallBack = { [weak self] in
            self?.reloadData()
            self?.updateImageConstraint()
        }
        
        viewModel?.updateCells = { setOfLists in
            self.reloadItems(lists: setOfLists)
            self.updateImageConstraint()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard var snapshot = collectionViewDataSource?.snapshot() else { return }
        snapshot.deleteAllItems()
        collectionViewDataSource?.apply(snapshot)
        viewModel?.reloadDataFromStorage()
    }
    
    private func createAttributedString(title: String, color: UIColor = .white) -> NSAttributedString {
        NSAttributedString(string: title, attributes: [
            .font: UIFont.SFPro.bold(size: 18).font ?? UIFont(),
            .foregroundColor: color
        ])
    }
    
    private func updateImageConstraint() {
        let height = viewModel?.getImageHeight()
        
        switch height {
        case .empty:
            foodImage.isHidden = true
        case .min:
            foodImage.isHidden = false
            foodImage.image = UIImage(named: "halfFood")
            foodImage.snp.updateConstraints { make in
                make.bottom.equalTo(collectionView.contentSize.height)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(213)
            }
        case .middle:
            foodImage.isHidden = false
            foodImage.image = UIImage(named: "foodImage")
            foodImage.snp.updateConstraints { make in
                make.bottom.equalTo(collectionView.contentSize.height)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(400)
            }
        case .none:
            print("print")
        }
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomCreateListView.startAnimating()
        updateImageConstraint()
    }
    // MARK: - UI
    
    private lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    private let bottomCreateListView: ShimmerView = {
        let view = ShimmerView()
        view.backgroundColor = .white.withAlphaComponent(0.9)
        return view
    }()
    
    private let plusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "#plusImage")
        imageView.blink()
        return imageView
    }()
    
    private let createListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "CreateList".localized
        return label
    }()
    
    private let foodImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "foodImage")
        return imageView
    }()
    
    private func setupConstraints() {
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.addSubviews([collectionView, bottomCreateListView])
        bottomCreateListView.addSubviews([plusImage, createListLabel])
        collectionView.addSubview(foodImage)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(88)
        }
        
        bottomCreateListView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(86)
        }
        
        plusImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(38)
            make.top.equalToSuperview().inset(24)
            make.height.width.equalTo(24)
        }
        
        createListLabel.snp.makeConstraints { make in
            make.left.equalTo(plusImage.snp.right).inset(-8)
            make.centerY.equalTo(plusImage)
        }
        
        foodImage.snp.makeConstraints { make in
            make.bottom.equalTo(collectionView.contentSize.height)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(400)
            make.centerX.equalToSuperview()
        }
    }
    
}

// MARK: - CollectionView
extension MainScreenViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = collectionViewDataSource?.itemIdentifier(for: indexPath) else { return }
        guard let section = self.collectionViewDataSource?.snapshot().sectionIdentifier(containingItem: model) else { return }
        guard section.cellType == .usual else { return }
        viewModel?.cellTapped(with: model)
    }
    
    private func setupCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
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
                cell?.settingsTapped = { [weak self] in
                    self?.viewModel?.settingsTapped()
                }
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
              
            // Удаление и закрепление ячейки
                cell?.swipeDeleteAction = {
                    viewModel.deleteCell(with: model)
                }
                
                cell?.swipeToAddOrDeleteFromFavorite = {
                    viewModel.addOrDeleteFromFavorite(with: model)
       
                }
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
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            return self.createLayout(sectionIndex: sectionIndex)
        }
        return layout
    }
    
    private func createLayout(sectionIndex: Int) -> NSCollectionLayoutSection {
        var itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(72))
        if sectionIndex == 0 {
            itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(92))
        }
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        if sectionIndex != 0 {
            let header = createSectionHeader()
            section.boundarySupplementaryItems = [header]
        }
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

// MARK: - CreateListAction
extension MainScreenViewController {
    private func addRecognizer() {
        let firstRecognizer = UITapGestureRecognizer(target: self, action: #selector(createListAction))
        bottomCreateListView.addGestureRecognizer(firstRecognizer)
    }
    
    @objc
    private func createListAction() {
        viewModel?.createNewListTapped()
    }
}
