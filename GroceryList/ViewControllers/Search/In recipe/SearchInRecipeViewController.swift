//
//  SearchInRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.03.2023.
//

import UIKit

final class SearchInRecipeViewController: SearchViewController {

    var viewModel: SearchInRecipeViewModel?
    
    private var currentlySelectedIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.updateData = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }

    override func setup() {
        super.setup()
        setSearchPlaceholder(viewModel?.placeholder ?? R.string.localizable.recipes())
        searchTextField.delegate = self
        makeConstraints()
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(classCell: RecipeListCell.self)
        collectionView.register(classCell: AllRecipesCell.self)
    }
    
    override func tappedCancelButton() {
        self.dismiss(animated: true)
    }
    
    override func tappedCleanerButton() {
        super.tappedCleanerButton()
        viewModel?.search(text: "")
    }
    
    private func makeConstraints() {        
        collectionView.snp.removeConstraints()
        collectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
}

extension SearchInRecipeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.recipesCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reusableCell(classCell: RecipeListCell.self, indexPath: indexPath)
        guard let recipe = viewModel?.getRecipe(by: indexPath.row) else {
            let lastCell = collectionView.reusableCell(classCell: AllRecipesCell.self, indexPath: indexPath)
            lastCell.searchAllRecipe = { [weak self] in
                self?.viewModel?.searchAllRecipe()
                self?.setSearchPlaceholder(self?.viewModel?.placeholder ?? R.string.localizable.recipes())
            }
            return lastCell
        }
        cell.configure(with: recipe)
        cell.selectedIndex = indexPath.item
        cell.delegate = self
        return cell
    }
}

extension SearchInRecipeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let recipe = viewModel?.getRecipe(by: indexPath.row) else {
            return
        }
        self.dismiss(animated: true, completion: {
            self.viewModel?.showRecipe(recipe)
        })
    }
}

extension SearchInRecipeViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        setCleanerButton(isVisible: (textField.text?.count ?? 0) >= 3)
        viewModel?.search(text: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
}

extension SearchInRecipeViewController: RecipeListCellDelegate {
    func didTapToButProductsAtRecipe(at index: Int) {
        let recipeTitle = viewModel?.getRecipe(by: index)?.title
        currentlySelectedIndex = index
        let products: [Product] = viewModel?.getRecipe(by: index)?.ingredients.map {
            let netProduct = $0.product
            let product = Product(name: netProduct.title,
                                  isPurchased: false,
                                  dateOfCreation: Date(),
                                  category: netProduct.marketCategory?.title ?? "",
                                  isFavorite: false,
                                  description: $0.description ?? "",
                                  fromRecipeTitle: recipeTitle)
            return product
        } ?? []

        let viewController = AddProductsSelectionListController(with: products)
        viewController.contentViewHeigh = 700
        viewController.modalPresentationStyle = .overCurrentContext
        let dataSource = SelectListDataManager()
        let viewModel = SelectListViewModel(dataSource: dataSource)
        viewController.viewModel = viewModel
        viewController.delegate = self
        present(viewController, animated: false)
    }
}

extension SearchInRecipeViewController: AddProductsSelectionListControllerDelegate {
    func ingredientsSuccessfullyAdded() {
        guard currentlySelectedIndex >= 0 else { return }
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentlySelectedIndex, section: 0)) as? RecipeListCell else { return }
        cell.setSuccessfullyAddedIngredients(isSuccess: true)
    }
}
