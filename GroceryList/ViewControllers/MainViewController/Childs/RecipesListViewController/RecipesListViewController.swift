//
//  RecipesListViewController.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 06.12.2022.
//

import UIKit

final class RecipesListViewController: UIViewController {
    var router: RootRouter?
    private var section: RecipeSectionsModel
    
    var currentlySelectedIndex: Int = -1
    
    private lazy var recipesListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(RecipeListCell.self, forCellWithReuseIdentifier: RecipeListCell.identifier)
//        collectionView.dataSource = self
        collectionView.contentInset.top = 136
//        collectionView.contentInset.left = 20
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    private let header = RecipesListHeaderView()
    
    init(with section: RecipeSectionsModel) {
        self.section = section
        super.init(nibName: nil, bundle: nil)
        header.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        header.releaseBlurAnimation()
    }
    
    private func setupAppearance() {
        view.backgroundColor = UIColor(hex: "E5F5F3")
    }
    
    private func setupSubviews() {
        view.addSubview(header)
        view.addSubview(recipesListCollectionView)
        view.bringSubviewToFront(header)
        
        header.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(136)
        }
        
        recipesListCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RecipesListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecipeListCell.identifier,
            for: indexPath
        ) as? RecipeListCell  else {
            return UICollectionViewCell()
        }
        let model = section.recipes[indexPath.item]
        cell.configure(with: model)
        cell.selectedIndex = indexPath.item
        cell.delegate = self
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.section.recipes.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: view.bounds.width - 40, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipe = section.recipes[indexPath.item]
        let vc = RecipeViewController(with: RecipeScreenViewModel(recipe: recipe), backButtonTitle: R.string.localizable.recipes())
        navigationController?.pushViewController(vc, animated: true)
//        let vc = router?.prepareSelectListController(height: 200, setOfSelectedProd: Set<section>, compl: <#T##((Set<Product>) -> Void)##((Set<Product>) -> Void)##(Set<Product>) -> Void#>)
    }
}

extension RecipesListViewController: RecipesListHeaderViewDelegate {
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func searchButtonTapped() {
        print("search tapped")
    }
}

extension RecipesListViewController: RecipeListCellDelegate {
    func didTapToButProductsAtRecipe(at index: Int) {
        let recipeTitle = section.recipes[index].title
        currentlySelectedIndex = index
        print("added recipeTitle in product \(recipeTitle)")
        let products: [Product] = section.recipes[index].ingredients.map {
            let netProduct = $0.product
//            let step = $0.product.marketUnit?.step?.defaultQuantityStep ?? 1
//            let description = String(format: "%.0f", $0.product.marketUnit?.step?.defaultQuantityStep ?? 1) + " " + String($0.product.marketUnit?.shortTitle ?? "г")
            let product = Product(
                name: netProduct.title,
                isPurchased: false,
                dateOfCreation: Date(),
                category: netProduct.marketCategory?.title ?? "",
                isFavorite: false,
                description: "",
                fromRecipeTitle: recipeTitle
            )
            return product
        }
        
        let vc = AddProductsSelectionListController(with:products)
        vc.contentViewHeigh = 700
        vc.modalPresentationStyle = .overCurrentContext
        let dataSource = SelectListDataManager()
        let viewModel = SelectListViewModel(dataSource: dataSource)
        vc.viewModel = viewModel
        vc.delegate = self
        present(vc, animated: true)
    }
}

extension RecipesListViewController: AddProductsSelectionListControllerDelegate {
    func ingredientsSuccessfullyAdded() {
        guard currentlySelectedIndex >= 0 else { return }
        guard let cell = recipesListCollectionView.cellForItem(at: IndexPath(item: currentlySelectedIndex, section: 0)) as? RecipeListCell else { return }
        cell.setSuccessfullyAddedIngredients(isSuccess: true)
    }
}
