//
//  RecipesListViewController.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 06.12.2022.
//

import UIKit

final class RecipesListViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    private var viewModel: RecipesListViewModel
    
    private lazy var recipesListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: RecipeListCell.self)
        collectionView.register(classCell: RecipeListTableCell.self)
        collectionView.contentInset.top = 340
        collectionView.contentInset.left = 16
        collectionView.contentInset.right = 16
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let headerBackgroundView = UIView()
    private let header = RecipesListHeaderView()
    private let titleView = RecipeListTitleView()
    private let photoView = RecipeListPhotoView()
    private let contextMenuBackgroundView = UIView()
    private let contextMenuView = RecipeListContextMenuView()
    private var currentlySelectedIndex: Int = -1
    
    init(viewModel: RecipesListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        header.delegate = self
        photoView.delegate = self
        contextMenuView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupSubviews()
        
        photoView.setPhoto(viewModel.collectionImage().url,
                           localImage: viewModel.collectionImage().data)
        titleView.setTitle(viewModel.title)
        
        let menuTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuTapAction))
        contextMenuBackgroundView.addGestureRecognizer(menuTapRecognizer)
        contextMenuBackgroundView.backgroundColor = .black.withAlphaComponent(0.2)
        
        contextMenuView.isHidden = true
        contextMenuBackgroundView.isHidden = true
        
        viewModel.updatePhoto = { [weak self] image in
            guard let self else {
                return
            }
            self.photoView.setPhoto("", localImage: image.pngData())
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as? MainTabBarController)?.isHideNavView(isHide: true)
        (self.tabBarController as? MainTabBarController)?.setTextTabBar(
            text: R.string.localizable.create().uppercased(),
            color: viewModel.theme.medium
        )
    }
    
    private func setupAppearance() {
        view.backgroundColor = viewModel.theme.light
        header.setColor(color: viewModel.theme.dark)
        titleView.setColor(viewModel.theme)
        headerBackgroundView.backgroundColor = viewModel.theme.light.withAlphaComponent(0.95)
        contextMenuView.configure(color: viewModel.theme)
    }
    
    @objc
    private func menuTapAction() {
        UIView.animate(withDuration: 0.4) {
            self.contextMenuView.alpha = 0.0
            self.contextMenuBackgroundView.alpha = 0.0
        } completion: { _ in
            self.contextMenuView.isHidden = true
            self.contextMenuBackgroundView.snp.updateConstraints { $0.height.equalTo(0) }
            self.contextMenuBackgroundView.isHidden = true
            
            self.contextMenuView.alpha = 1.0
            self.contextMenuBackgroundView.alpha = 1.0
        }
    }
    
    private func setupSubviews() {
        self.view.addSubviews([recipesListCollectionView, header])
        recipesListCollectionView.addSubviews([photoView, headerBackgroundView, titleView])
        (self.tabBarController as? MainTabBarController)?.customTabBar.addSubviews([contextMenuBackgroundView])
        contextMenuBackgroundView.addSubviews([contextMenuView])
        
        header.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        recipesListCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        photoView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(-16)
            $0.trailing.equalToSuperview().offset(16)
            $0.width.equalToSuperview()
            $0.bottom.equalTo(recipesListCollectionView.snp.top).offset(-76)
            $0.height.equalTo(280)
        }
        
        headerBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(-16)
            $0.trailing.equalToSuperview().offset(16)
            $0.top.equalTo(photoView.snp.bottom)
            $0.bottom.equalTo(titleView.snp.top)
        }
        
        titleView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(-16)
            $0.trailing.equalToSuperview().offset(16)
            $0.height.equalTo(56)
            $0.top.greaterThanOrEqualTo(header.snp.bottom)
            $0.bottom.equalTo(recipesListCollectionView.snp.top).offset(-8)
        }
        
        contextMenuBackgroundView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        contextMenuView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(contextMenuView.requiredHeight)
            $0.width.equalTo(250)
        }
    }
}

extension RecipesListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.recipesCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isTable = UserDefaultsManager.recipeIsTableView
        
        guard isTable else {
            let cell = collectionView.reusableCell(classCell: RecipeListCell.self, indexPath: indexPath)
            let model = viewModel.getModel(by: indexPath)
            cell.configure(with: model)
            cell.configureColor(theme: viewModel.theme)
            cell.selectedIndex = indexPath.item
            cell.delegate = self
            return cell
        }

        let cell = collectionView.reusableCell(classCell: RecipeListTableCell.self, indexPath: indexPath)
        let model = viewModel.getModel(by: indexPath)
        cell.configure(with: model)
        cell.configureColor(theme: viewModel.theme)
        cell.selectedIndex = indexPath.item
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isTable = UserDefaultsManager.recipeIsTableView
        let width = view.bounds.width - 40
        return isTable ? CGSize(width: width / 2, height: 137)
                       : CGSize(width: width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        viewModel.showRecipe(by: indexPath)
    }
}

extension RecipesListViewController: RecipesListHeaderViewDelegate {
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func searchButtonTapped() {
        viewModel.showSearch()
    }
    
    func changeViewButtonTapped() {
        recipesListCollectionView.reloadData()
    }
}

extension RecipesListViewController:  RecipeListPhotoViewDelegate {
    func choosePhotoButtonTapped() {
        viewModel.showPhotosFromRecipe()
    }
}

extension RecipesListViewController: RecipeListCellDelegate {
    func contextMenuTapped(at index: Int, point: CGPoint, cell: RecipeListCell) {
        let convertPointOnView = cell.convert(point, to: self.view)
        
        currentlySelectedIndex = index
        contextMenuBackgroundView.isHidden = false
        contextMenuView.isHidden = false
        
        contextMenuBackgroundView.snp.updateConstraints {
            $0.height.equalTo(self.view.frame.height)
        }
        
        contextMenuView.alpha = 0.0
        contextMenuView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                                        .translatedBy(x: convertPointOnView.x - 125,
                                                      y: convertPointOnView.y - 300)
        UIView.animate(withDuration: 0.3) {
            self.contextMenuView.alpha = 1.0
            self.contextMenuView.transform = .identity
        }
    }
}

extension RecipesListViewController: AddProductsSelectionListDelegate {
    func ingredientsSuccessfullyAdded() {
        guard currentlySelectedIndex >= 0 else {
            return
        }
        let index = IndexPath(item: currentlySelectedIndex, section: 0)
        guard let cell = recipesListCollectionView.cellForItem(at: index) as? RecipeListCell else {
            return
        }
        cell.setSuccessfullyAddedIngredients(isSuccess: true)
    }
}

extension RecipesListViewController: RecipeListContextMenuViewDelegate {
    func selectedState(state: RecipeListContextMenuView.MainMenuState) {
        UIView.animate(withDuration: 0.4) {
            self.contextMenuView.alpha = 0.0
            self.contextMenuBackgroundView.alpha = 0.0
        } completion: { _ in
            self.contextMenuView.isHidden = true
            self.contextMenuBackgroundView.snp.updateConstraints { $0.height.equalTo(0) }
            self.contextMenuBackgroundView.isHidden = true
            
            self.contextMenuView.alpha = 1.0
            self.contextMenuBackgroundView.alpha = 1.0

            switch state {
            case .addToShoppingList:
                self.viewModel.addToShoppingList()
            case .addToFavorites:
                self.viewModel.addToFavorites()
            case .addToCollection:
                self.viewModel.addToCollection()
            case .edit:
                self.viewModel.edit()
            }
            
            self.contextMenuView.removeSelected()
        }
    }
}
