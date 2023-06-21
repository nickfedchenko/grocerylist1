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
    
    private let backgroundHeaderView = UIView()
    private let header = RecipesListHeaderView()
    private let titleView = RecipeListTitleView()
    private let photoView = RecipeListPhotoView()
    private var imagePicker = UIImagePickerController()
    private var currentlySelectedIndex: Int = -1
    
    init(viewModel: RecipesListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        header.delegate = self
        photoView.delegate = self
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
        backgroundHeaderView.backgroundColor = viewModel.theme.light.withAlphaComponent(0.95)
    }
    
    private func setupSubviews() {
        self.view.addSubviews([recipesListCollectionView, header])
        recipesListCollectionView.addSubviews([photoView, backgroundHeaderView, titleView])
        
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
        
        backgroundHeaderView.snp.makeConstraints {
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
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .pageSheet
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension RecipesListViewController: RecipeListCellDelegate {
    func contextMenuTapped(at index: Int) {
//        let recipeId = section.recipes[index].id
//        guard let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId) else {
//            return
//        }
//        let model = ShortRecipeModel(withIngredients: dbRecipe)
//        let recipeTitle = model.title
//        currentlySelectedIndex = index
//        print("added recipeTitle in product \(recipeTitle)")
//        let products: [Product] = model.ingredients?.map({
//            let netProduct = $0.product
//            let product = Product(
//                name: netProduct.title,
//                isPurchased: false,
//                dateOfCreation: Date(),
//                category: netProduct.marketCategory?.title ?? "",
//                isFavorite: false,
//                description: "",
//                fromRecipeTitle: recipeTitle
//            )
//            return product
//        }) ?? []
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

extension RecipesListViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        photoView.setImage(image: image)
        viewModel.savePhoto(image: image)
    }
}
