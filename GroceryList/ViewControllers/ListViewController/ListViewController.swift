//
//  ListViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import UIKit

final class ListViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    private var viewModel: ListViewModel
    
    private lazy var collectionView: UICollectionView = {
        let layout = collectionViewLayoutManager.createCompositionalLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.contentInset.bottom = 60
        collectionView.contentInset.top = 34
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.backgroundColor = R.color.background()
        collectionView.register(classCell: GroceryCollectionViewCell.self)
        collectionView.register(classCell: EmptyColoredCell.self)
        collectionView.register(classCell: InstructionCell.self)
        collectionView.registerHeader(classHeader: GroceryCollectionViewHeader.self)
        return collectionView
    }()
    
    private let foodImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "foodImage")
        return imageView
    }()
    
    private var collectionViewLayoutManager = ListCollectionViewLayout()
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionModel, GroceryListsModel>?
    private let synchronizationActivityView = SynchronizationActivityView()
    
    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as? MainTabBarController)?.listDelegate = self
        
        setupConstraints()
        createDataSource()
        viewModelChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard var snapshot = collectionViewDataSource?.snapshot() else { return }
        snapshot.deleteAllItems()
        collectionViewDataSource?.apply(snapshot)
        viewModel.reloadDataFromStorage()
        updateImageConstraint()
        (self.tabBarController as? MainTabBarController)?.isHideNavView(isHide: false)
        (self.tabBarController as? MainTabBarController)?.setTextTabBar()
    }
    
    private func viewModelChanges() {
        viewModel.reloadDataCallBack = { [weak self] in
            self?.reloadData()
            self?.updateImageConstraint()
        }
        
        viewModel.updateCells = { [weak self] setOfLists in
            self?.reloadItems(lists: setOfLists)
            self?.updateImageConstraint()
        }
        
        viewModel.showSynchronizationActivity = { [weak self] isShow in
            guard let self else { return }
            DispatchQueue.main.async {
                if isShow {
                    self.synchronizationActivityView.show(for: self.view)
                } else {
                    self.synchronizationActivityView.removeFromView()
                }
            }
        }
    }
    
    private func updateImageConstraint() {
        let height = viewModel.getImageHeight()
        
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
        }
    }

    private func createDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                                      cellProvider: { [self] _, indexPath, model in
            
            switch self.viewModel.model[indexPath.section].cellType {
            case .empty:
                // empty cell in bottom of collection
                return createEmptyCell(indexPath: indexPath)
                
            case .instruction:
                // cell for cold start
                return self.collectionView.reusableCell(classCell: InstructionCell.self, indexPath: indexPath)
                
            default:
                return createListCell(model: model, indexPath: indexPath)
            }
        })
        addHeaderToCollectionView()
    }
    
    private func createEmptyCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.reusableCell(classCell: EmptyColoredCell.self, indexPath: indexPath)
        let isTopRounded = viewModel.isTopRounded(at: indexPath)
        let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
        let color = viewModel.getBGColorForEmptyCell(at: indexPath)
        cell.setupCell(bckgColor: color, isTopRounded: isTopRounded, isBottomRounded: isBottomRounded)
        return cell
    }
    
    private func createListCell(model: GroceryListsModel, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.reusableCell(classCell: GroceryCollectionViewCell.self, indexPath: indexPath)
        let name = viewModel.getNameOfList(at: indexPath)
        let isTopRounded = viewModel.isTopRounded(at: indexPath)
        let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
        let numberOfItems = viewModel.getNumberOfProductsInside(at: indexPath)
        let color = viewModel.getBGColor(at: indexPath)
        cell.setupCell(nameOfList: name, bckgColor: color, isTopRounded: isTopRounded,
                       isBottomRounded: isBottomRounded, numberOfItemsInside: numberOfItems,
                       isFavorite: model.isFavorite)
        cell.setupSharing(state: viewModel.getSharingState(model),
                          color: color,
                          image: viewModel.getShareImages(model))
        
        // Удаление и закрепление ячейки
        cell.swipeDeleteAction = { [weak self] in
            AmplitudeManager.shared.logEvent(.listDelete)
            self?.viewModel.deleteCell(with: model)
        }
        
        cell.swipeToAddOrDeleteFromFavorite = { [weak self] in
            self?.viewModel.addOrDeleteFromFavorite(with: model)
        }
        // Шаринг карточки списка
        cell.sharingAction = { [weak self] in
            self?.viewModel.sharingTapped(model: model)
        }
        return cell
    }
    
    private func addHeaderToCollectionView() {
        collectionViewDataSource?.supplementaryViewProvider = { collectionView, _, indexPath in
            guard let sectionHeader = collectionView.reusableHeader(classHeader: GroceryCollectionViewHeader.self,
                                                                    indexPath: indexPath) else {
                return nil
            }
            
            guard let model = self.collectionViewDataSource?.itemIdentifier(for: indexPath) else {
                return nil
            }
            guard let section = self.collectionViewDataSource?.snapshot().sectionIdentifier(containingItem: model) else {
                return nil
            }
            sectionHeader.setupHeader(sectionType: section.sectionType)
            return sectionHeader
        }
    }
    
    // ReloadData
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, GroceryListsModel>()
        snapshot.appendSections(viewModel.model)
        for section in viewModel.model {
            snapshot.appendItems(section.lists, toSection: section)
        }
        collectionViewDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadItems(lists: Set<GroceryListsModel>) {
        guard var snapshot = collectionViewDataSource?.snapshot() else {
            return
        }
        let array = Array(lists)
        array.forEach({ if snapshot.sectionIdentifier(containingItem: $0) != nil { snapshot.reloadItems([$0]) } })
        
        collectionViewDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupConstraints() {
        view.backgroundColor = R.color.background()
        
        view.addSubviews([collectionView])
        collectionView.addSubview(foodImage)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
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
extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = collectionViewDataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        guard let section = self.collectionViewDataSource?.snapshot().sectionIdentifier(containingItem: model) else {
            return
        }
        guard section.cellType == .usual else {
            return
        }
        viewModel.cellTapped(with: model)
    }
}

extension ListViewController: MainTabBarControllerListDelegate {
    func tappedAddItem() {
        viewModel.tappedAddItem()
    }
    
    func updatedUI() {
        viewModel.reloadDataFromStorage()
        collectionView.reloadData()
    }
}
