//
//  MainScreenViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import ApphudSDK
import SnapKit
import UIKit

class MainScreenViewController: UIViewController {
   
    var viewModel: MainScreenViewModel?
    var collectionViewLayoutManager = MainScreenCollectionViewLayout()
    private var presentationMode: MainScreenPresentationMode = .lists
    private var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionModel, GroceryListsModel>?
  
    private lazy var recipesCollectionView: UICollectionView = {
        let layout = collectionViewLayoutManager.makeRecipesLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: MainScreenTopCell.self)
        collectionView.register(classCell: RecipePreviewCell.self)
        collectionView.register(classCell: MoreRecipeCell.self)
        collectionView.registerHeader(classHeader: RecipesFolderHeader.self)
        collectionView.contentInset.bottom = 10
        collectionView.contentInset.right = 10
        collectionView.dataSource = self
        collectionView.alpha = 0
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        return collectionView
    }()
    private let defaultRecipeCount = 12
    
    private lazy var collectionView: UICollectionView = {
        let layout = collectionViewLayoutManager.createCompositionalLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.contentInset.bottom = 60
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(hex: "#E8F5F3")
        collectionView.register(classCell: GroceryCollectionViewCell.self)
        collectionView.register(classCell: EmptyColoredCell.self)
        collectionView.register(classCell: InstructionCell.self)
        collectionView.register(classCell: MainScreenTopCell.self)
        collectionView.registerHeader(classHeader: GroceryCollectionViewHeader.self)
        return collectionView
    }()
    
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
        label.font = UIFont.SFProRounded.semibold(size: 18).font
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
    
    private let contextMenu = MainScreenMenuView()
    private var menuTapRecognizer = UITapGestureRecognizer()
    
    // MARK: - Lifecycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        addRecognizer()
        createTableViewDataSource()
        setupContextMenu()
        viewModel?.reloadDataCallBack = { [weak self] in
            self?.reloadData()
            self?.updateImageConstraint()
        }
        
        viewModel?.modeChanged = { [weak self] in
            guard Apphud.hasActiveSubscription() else { return }
            self?.modeChanged(to: .recipes)
        }
        
        viewModel?.updateCells = { setOfLists in
            self.reloadItems(lists: setOfLists)
            self.updateImageConstraint()

        }
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard var snapshot = collectionViewDataSource?.snapshot() else { return }
        snapshot.deleteAllItems()
        collectionViewDataSource?.apply(snapshot)
        viewModel?.reloadDataFromStorage()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.viewModel?.updateFavorites()
            DispatchQueue.main.async {
                self?.recipesCollectionView.reloadData()
            }
        }
        updateImageConstraint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomCreateListView.startAnimating()
    }
    
    // MARK: - Functions
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
    
    private func setupContextMenu() {
        contextMenu.isHidden = true
        
        contextMenu.selectedState = { [weak self] state in
            self?.contextMenu.fadeOut {
                switch state {
                case .createRecipe:
                    self?.viewModel?.createNewRecipeTapped()
                case .createCollection:
                    self?.viewModel?.createNewCollectionTapped()
                }
                self?.contextMenu.removeSelected()
            }
        }
    }
    
    // MARK: - UI
    private func setupConstraints() {
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.addSubviews([collectionView, bottomCreateListView, recipesCollectionView, contextMenu])
        bottomCreateListView.addSubviews([plusImage, createListLabel])
        collectionView.addSubview(foodImage)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(10)
            make.width.equalTo(view.snp.width)
            make.leading.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        recipesCollectionView.snp.makeConstraints { make in
            make.width.equalTo(self.view.bounds.width)
            make.height.equalTo(collectionView)
            make.top.equalTo(collectionView)
            make.leading.equalTo(collectionView.snp.trailing)
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
        
        contextMenu.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(10)
            make.trailing.equalToSuperview().offset(-68)
            make.height.equalTo(contextMenu.requiredHeight)
            make.width.equalTo(254)
        }
    }
}

// MARK: - CollectionView
extension MainScreenViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            guard let model = collectionViewDataSource?.itemIdentifier(for: indexPath) else { return }
            guard let section = self.collectionViewDataSource?.snapshot().sectionIdentifier(containingItem: model) else { return }
            guard section.cellType == .usual else { return }
            viewModel?.cellTapped(with: model)
        } else {
            if indexPath.section != 0 && indexPath.row != (viewModel?.dataSource?.recipeCount ?? 10) - 1 {
                guard let model = viewModel?.dataSource?.recipesSections[indexPath.section].recipes[indexPath.item] else { return }
                let view = RecipeViewController(with: RecipeScreenViewModel(recipe: model), backButtonTitle: R.string.localizable.back())
                navigationController?.pushViewController(view, animated: true)
            }
        }
    }
    
        // swiftlint:disable:next function_body_length
    private func createTableViewDataSource() {
        collectionViewDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                                      cellProvider: { [self] _, indexPath, model in
            
            switch self.viewModel?.model[indexPath.section].cellType {
                
                // top view with switcher
            case .topMenu:
                let cell = self.collectionView.reusableCell(classCell: MainScreenTopCell.self, indexPath: indexPath)
                cell.settingsTapped = { [weak self] in
                    self?.viewModel?.settingsTapped()
                }
                cell.contextMenuTapped = { [weak self] in
                    self?.contextMenu.fadeIn()
                    self?.menuTapRecognizer.isEnabled = true
                }
                cell.delegate = self
                cell.configure(with: self.presentationMode)
                cell.setupUser(photo: self.viewModel?.userPhoto,
                                name: self.viewModel?.userName)
                return cell
                
                // empty cell in bottom of collection
            case .empty:
                let cell = self.collectionView.reusableCell(classCell: EmptyColoredCell.self, indexPath: indexPath)
                guard let viewModel = self.viewModel else { return UICollectionViewCell() }
                let isTopRouned = viewModel.isTopRounded(at: indexPath)
                let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
                let color = viewModel.getBGColorForEmptyCell(at: indexPath)
                cell.setupCell(bckgColor: color, isTopRounded: isTopRouned, isBottomRounded: isBottomRounded)
                return cell
                
                // cell for cold start
            case .instruction:
                let cell = self.collectionView.reusableCell(classCell: InstructionCell.self, indexPath: indexPath)
                return cell
            default:
                let cell = self.collectionView.reusableCell(classCell: GroceryCollectionViewCell.self, indexPath: indexPath)
                guard let viewModel = self.viewModel else { return UICollectionViewCell() }
                let name = viewModel.getNameOfList(at: indexPath)
                let isTopRouned = viewModel.isTopRounded(at: indexPath)
                let isBottomRounded = viewModel.isBottomRounded(at: indexPath)
                let numberOfItems = viewModel.getnumberOfProductsInside(at: indexPath)
                let color = viewModel.getBGColor(at: indexPath)
                cell.setupCell(nameOfList: name, bckgColor: color, isTopRounded: isTopRouned,
                                isBottomRounded: isBottomRounded, numberOfItemsInside: numberOfItems, isFavorite: model.isFavorite)
                cell.setupSharing(state: viewModel.getSharingState(model), image: viewModel.getShareImages(model))
                
                // Удаление и закрепление ячейки
                cell.swipeDeleteAction = {
                    viewModel.deleteCell(with: model)
                }
                
                cell.swipeToAddOrDeleteFromFavorite = {
                    viewModel.addOrDeleteFromFavorite(with: model)
                    
                }
                // Шаринг карточки списка
                cell.sharingAction = {
                    viewModel.sharingTapped(model: model)
                }
                return cell
            }
        })
        addHeaderToCollectionView()
    }
    
    private func addHeaderToCollectionView() {
        collectionViewDataSource?.supplementaryViewProvider = { collectionView, _, indexPath in
            guard let sectionHeader = collectionView.reusableHeader(classHeader: GroceryCollectionViewHeader.self,
                                                                    indexPath: indexPath) else { return nil }
            
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
    
}

// MARK: - CreateListAction
extension MainScreenViewController {
    private func addRecognizer() {
        let firstRecognizer = UITapGestureRecognizer(target: self, action: #selector(createListAction))
        bottomCreateListView.addGestureRecognizer(firstRecognizer)
        
        menuTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuTapAction))
        self.view.addGestureRecognizer(menuTapRecognizer)
    }
    
    @objc
    private func createListAction() {
        viewModel?.createNewListTapped()
    }
    
    @objc
    private func menuTapAction() {
        contextMenu.fadeOut()
        menuTapRecognizer.isEnabled = false
    }
}

extension MainScreenViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.dataSource?.recipesSections.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? 1 : viewModel?.recipeCount(for: section) ?? defaultRecipeCount
    }
    
    func collectionView( _ collectionView: UICollectionView,
                         cellForItemAt indexPath: IndexPath ) -> UICollectionViewCell {
        guard !(indexPath.section == 0) else {
            let topCell = collectionView.reusableCell(classCell: MainScreenTopCell.self, indexPath: indexPath)
            topCell.settingsTapped = { [weak self] in
                self?.viewModel?.settingsTapped()
            }
            topCell.contextMenuTapped = { [weak self] in
                self?.contextMenu.fadeIn()
                self?.menuTapRecognizer.isEnabled = true
            }
            topCell.delegate = self
            topCell.configure(with: presentationMode)
            topCell.setupUser(photo: self.viewModel?.userPhoto,
                              name: self.viewModel?.userName)
            return topCell
        }
        
        let recipeCount = viewModel?.dataSource?.recipeCount ?? defaultRecipeCount
        
        if indexPath.row == recipeCount - 1,
           let sectionModel = viewModel?.dataSource?.recipesSections[indexPath.section] {
            let moreCell = collectionView.reusableCell(classCell: MoreRecipeCell.self, indexPath: indexPath)
            moreCell.delegate = self
            moreCell.configure(at: indexPath.section, title: "\(sectionModel.recipes.count - recipeCount)")
            return moreCell
        }
        
        guard let model = viewModel?.getRecipeModel(for: indexPath) else { return UICollectionViewCell() }
        let cell = collectionView.reusableCell(classCell: RecipePreviewCell.self, indexPath: indexPath)
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard indexPath.section > 0,
              let header = collectionView.reusableHeader(classHeader: RecipesFolderHeader.self, indexPath: indexPath),
              let sectionModel = viewModel?.dataSource?.recipesSections[indexPath.section] else {
            return UICollectionReusableView()
        }
        header.configure(with: sectionModel, at: indexPath.section)
        header.delegate = self
        return header
    }
}

// MARK: - Swapping collections logic
extension MainScreenViewController: MainScreenTopCellDelegate {
    private func showRecipesCollection() {
        collectionView.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(-view.bounds.width)
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
            self.collectionView.alpha = 0
            self.recipesCollectionView.alpha = 1
        }
    }
    
    private func showListsCollection() {
        collectionView.snp.updateConstraints { make in
            make.leading.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
            self.collectionView.alpha = 1
            self.recipesCollectionView.alpha = 0
        }
    }
    
    func modeChanged(to mode: MainScreenPresentationMode) {
//        guard Apphud.hasActiveSubscription() else {
//            showPaywall()
//            return
//        }
        presentationMode = mode
        if mode == .lists {
            showListsCollection()
            if let item = collectionViewDataSource?.itemIdentifier(for: IndexPath(item: 0, section: 0)),
               var snapshot = collectionViewDataSource?.snapshot() {
                snapshot.reloadItems([item])
                collectionViewDataSource?.apply(snapshot)
            }
            bottomCreateListView.isHidden = false
            
        } else {
            showRecipesCollection()
            recipesCollectionView.reloadSections(IndexSet(integer: 0))
            bottomCreateListView.isHidden = true
        }
    }
    
    private func showPaywall() {
        if let paywall = viewModel?.router?.viewControllerFactory.createAlternativePaywallController() {
            paywall.modalPresentationStyle = .fullScreen
            present(paywall, animated: true)
        }
    }
}

extension MainScreenViewController: RecipesFolderHeaderDelegate {
    func headerTapped(at index: Int) {
        guard let section = viewModel?.dataSource?.recipesSections[index] else { return }
        viewModel?.router?.goToRecipes(for: section)
    }
}
