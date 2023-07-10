//
//  SearchInRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.03.2023.
//

import UIKit
import TagListView

final class SearchInRecipeViewController: SearchViewController {

    var viewModel: SearchInRecipeViewModel?

    private lazy var addFilterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Filter", for: .normal)
        button.titleLabel?.font = UIFont.SFPro.medium(size: 16).font
        button.setTitleColor(R.color.darkGray(), for: .normal)
        button.setImage(R.image.recipeFilters(), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = R.color.darkGray()?.cgColor
        button.semanticContentAttribute = .forceLeftToRight
        button.addTarget(self, action: #selector(addFilterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleView = RecipeListTitleView()
    private let filterTagsView = FiltersView()
    private var currentlySelectedIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.updateData = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel?.updateFilter = { [weak self] in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }
                self.updateFilterTagsView()
                self.collectionView.contentInset.top = self.navigationView.frame.height + self.topSafeAreaView.frame.height + 10
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset.top = navigationView.frame.height + topSafeAreaView.frame.height + 10
    }

    override func setup() {
        super.setup()
        updateColor()
        iconImageView.image = R.image.searchButtonImage()?.withTintColor(R.color.mediumGray() ?? .gray)
        setSearchPlaceholder(R.string.localizable.searchByNameOrIngredient())
        searchTextField.delegate = self
        
        makeConstraints()
        updateTitleViewConstraints()

        filterTagsView.delegate = self
        updateFilterTagsView()
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(classCell: RecipeListCell.self)
        collectionView.register(classCell: AllRecipesCell.self)
    }
    
    override func tappedCancelButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tappedCleanerButton() {
        super.tappedCleanerButton()
        viewModel?.search(text: "")
    }
    
    private func updateTitleViewConstraints() {
        guard !(viewModel?.isSearchAllRecipe ?? true) else {
            cancelButton.setTitle(nil, for: .normal)
            titleView.isHidden = true
            titleView.snp.updateConstraints {
                $0.top.equalTo(searchView.snp.bottom).offset(0)
                $0.height.equalTo(0)
            }
            return
        }
        
        titleView.setTitle(viewModel?.section?.sectionType.title)
        cancelButton.setTitle("   " + R.string.localizable.cancel(), for: .normal)
        cancelButton.titleLabel?.font = UIFont.SFProRounded.bold(size: 16).font
        
        cancelButton.snp.remakeConstraints {
            $0.top.equalTo(navigationView)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(40)
        }
        
        titleView.snp.remakeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        searchView.snp.remakeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(-4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }
        
        filterTagsView.snp.remakeConstraints {
            $0.top.equalTo(searchView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(addFilterButton.snp.top).offset(-12)
            $0.height.greaterThanOrEqualTo(1).priority(.high)
        }
    }
    
    private func updateColor() {
        let theme = viewModel?.theme ?? ColorManager.shared.getColorForRecipe()
        self.view.backgroundColor = theme.light
        searchTextField.becomeFirstResponder()
        navigationView.backgroundColor = theme.light.withAlphaComponent(0.95)
        topSafeAreaView.backgroundColor = theme.light.withAlphaComponent(0.95)
        
        cancelButton.setTitleColor(theme.dark, for: .normal)
        searchTextField.tintColor = theme.dark
        crossCleanerButton.setImage(R.image.xMarkInput()?.withTintColor(theme.dark), for: .normal)
        cancelButton.setImage(R.image.greenArrowBack()?.withTintColor(theme.dark), for: .normal)
        addFilterButton.setTitleColor(theme.dark, for: .normal)
        addFilterButton.setImage(R.image.recipeFilters()?.withTintColor(theme.dark), for: .normal)
        addFilterButton.layer.borderColor = theme.dark.cgColor
        
        titleView.setColor(theme)
    }
    
    private func updateFilterTagsView() {
        let tags = viewModel?.recipeTags ?? []
        filterTagsView.configure(tags: tags, color: viewModel?.theme.dark)
        filterTagsView.snp.updateConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(tags.isEmpty ? 0 : 24)
        }
    }
    
    @objc
    private func addFilterButtonTapped() {
        guard let controller = viewModel?.showFilter() else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func makeConstraints() {
        navigationView.insertSubview(titleView, belowSubview: searchView)
        navigationView.addSubviews([filterTagsView, addFilterButton])
        navigationView.snp.removeConstraints()
        cancelButton.snp.removeConstraints()
        searchView.snp.removeConstraints()
        crossCleanerButton.snp.removeConstraints()
        collectionView.snp.removeConstraints()
        
        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(searchView)
            $0.leading.equalToSuperview()
            $0.height.width.equalTo(40)
        }

        searchView.snp.makeConstraints {
            $0.top.equalTo(navigationView)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }

        crossCleanerButton.snp.makeConstraints {
            $0.centerY.equalTo(searchView)
            $0.trailing.equalTo(searchView).offset(-12)
            $0.height.width.equalTo(24)
        }

        
        collectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        navigationView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(104)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(searchView.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        filterTagsView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(addFilterButton.snp.top).offset(-12)
            $0.height.greaterThanOrEqualTo(1).priority(.high)
        }
        
        addFilterButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
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
            lastCell.setColor(theme: viewModel?.theme)
            lastCell.searchAllRecipe = { [weak self] in
                self?.viewModel?.searchAllRecipe()
                self?.setSearchPlaceholder(self?.viewModel?.placeholder ?? R.string.localizable.recipes())
            }
            return lastCell
        }
        cell.configure(with: ShortRecipeModel(modelForSearch: recipe))
        cell.configureColor(theme: viewModel?.theme ?? ColorManager.shared.getColorForRecipe())
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
        self.viewModel?.showRecipe(recipe)
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
    func contextMenuTapped(at index: Int, point: CGPoint, cell: RecipeListCell) {
        let recipeTitle = viewModel?.getRecipe(by: index)?.title
        currentlySelectedIndex = index
        let products: [Product] = viewModel?.getRecipe(by: index)?.ingredients?.map({
            let netProduct = $0.product
            let product = Product(name: netProduct.title,
                                  isPurchased: false,
                                  dateOfCreation: Date(),
                                  category: netProduct.marketCategory?.title ?? "",
                                  isFavorite: false,
                                  description: $0.description ?? "",
                                  fromRecipeTitle: recipeTitle)
            return product
        }) ?? []

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

extension SearchInRecipeViewController: AddProductsSelectionListDelegate {
    func ingredientsSuccessfullyAdded() {
        guard currentlySelectedIndex >= 0 else { return }
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentlySelectedIndex, section: 0)) as? RecipeListCell else { return }
        cell.setSuccessfullyAddedIngredients(isSuccess: true)
    }
}

extension SearchInRecipeViewController: TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        viewModel?.removeTag(recipeTag: title.trimmingCharacters(in: .whitespacesAndNewlines))
        updateFilterTagsView()
    }
}
