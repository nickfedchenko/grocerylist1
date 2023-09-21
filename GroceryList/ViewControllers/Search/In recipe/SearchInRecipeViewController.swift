//
//  SearchInRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.03.2023.
//

import ApphudSDK
import TagListView
import UIKit

class SearchInRecipeViewController: SearchViewController {

    var viewModel: SearchInRecipeViewModel?

    var isMealPlanMode: Bool {
        false
    }
    
    private lazy var addFilterButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.addFilter(), for: .normal)
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
    private let contextMenuBackgroundView = UIView()
    private let contextMenuView = RecipeListContextMenuView()
    private var currentlySelectedIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContextMenu()
        
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
    
    private func setupContextMenu() {
        let menuTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuTapAction))
        contextMenuBackgroundView.addGestureRecognizer(menuTapRecognizer)
        contextMenuBackgroundView.backgroundColor = .black.withAlphaComponent(0.2)
        
        contextMenuView.delegate = self
        contextMenuView.isHidden = true
        contextMenuBackgroundView.isHidden = true
    }
    
    func showContextMenu(_ cell: RecipeListCell, _ point: CGPoint, _ index: Int) {
        let convertPointOnView = cell.convert(point, to: self.view)
        
        currentlySelectedIndex = index
        contextMenuView.setupMenuStackView(isFavorite: viewModel?.isFavoriteRecipe(by: index) ?? false)
        contextMenuView.removeDeleteButton()
        contextMenuView.setupMenuFunctions(isDefaultRecipe: viewModel?.isDefaultRecipe(by: index) ?? true,
                                           isFavorite: viewModel?.isFavoriteRecipe(by: index) ?? false)
        contextMenuView.snp.updateConstraints { $0.height.equalTo(contextMenuView.requiredHeight) }
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
    
    func tapCell(_ indexPath: IndexPath) {
        guard let recipe = viewModel?.getRecipe(by: indexPath.row) else {
            return
        }
        self.viewModel?.showRecipe(recipe)
    }
    
    private func updateTitleViewConstraints() {
        guard !(viewModel?.isSearchAllRecipe ?? true) else {
            cancelButton.setTitle(nil, for: .normal)
            titleView.isHidden = true

            cancelButton.snp.remakeConstraints {
                $0.centerY.equalTo(searchView)
                $0.leading.equalToSuperview()
                $0.height.width.equalTo(40)
            }

            searchView.snp.remakeConstraints {
                $0.top.equalTo(navigationView)
                $0.leading.equalTo(cancelButton.snp.trailing).offset(8)
                $0.trailing.equalToSuperview().offset(-16)
                $0.height.equalTo(40)
            }

            titleView.snp.remakeConstraints {
                $0.top.equalTo(searchView.snp.bottom).offset(0)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(0)
            }

            filterTagsView.snp.remakeConstraints {
                $0.top.equalTo(titleView.snp.bottom).offset(24)
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.bottom.equalTo(addFilterButton.snp.top).offset(-12)
                $0.height.greaterThanOrEqualTo(1).priority(.high)
            }
            return
        }
        
        updateConstraintsWhenAllRecipe()
    }
    
    private func updateConstraintsWhenAllRecipe() {
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
            $0.leading.trailing.equalToSuperview().inset(16)
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
        contextMenuView.configure(color: theme)
    }
    
    private func updateFilterTagsView() {
        let tags = viewModel?.recipeTags ?? []
        filterTagsView.configure(tags: tags, color: viewModel?.theme.dark)
        
        guard !(viewModel?.isSearchAllRecipe ?? true) else {
            filterTagsView.snp.updateConstraints {
                $0.top.equalTo(titleView.snp.bottom).offset(tags.isEmpty ? 0 : 24)
            }
            return
        }
        
        filterTagsView.snp.updateConstraints {
            $0.top.equalTo(searchView.snp.bottom).offset(tags.isEmpty ? 0 : 24)
        }
    }
    
    private func updateAllRecipeMode() {
        viewModel?.searchAllRecipe()
        updateTitleViewConstraints()
        updateFilterTagsView()
        
        UIView.animate(withDuration: 0.3) {
            self.updateColor()
            self.setSearchPlaceholder(R.string.localizable.searchByNameOrIngredient())
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func addFilterButtonTapped() {
        guard let controller = viewModel?.showFilter() else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
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
    
    private func makeConstraints() {
        navigationView.insertSubview(titleView, belowSubview: searchView)
        navigationView.addSubviews([filterTagsView, addFilterButton])
        removeConstraints()
        self.view.addSubview(contextMenuBackgroundView)
        contextMenuBackgroundView.addSubviews([contextMenuView])
        
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

        makeFilterTagsViewConstraints()
        makeContextMenuViewConstraints()
    }
    
    private func makeContextMenuViewConstraints() {
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
    
    private func makeFilterTagsViewConstraints() {
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
    
    private func removeConstraints() {
        navigationView.snp.removeConstraints()
        cancelButton.snp.removeConstraints()
        searchView.snp.removeConstraints()
        crossCleanerButton.snp.removeConstraints()
        collectionView.snp.removeConstraints()
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
                self?.updateAllRecipeMode()
            }
            return lastCell
        }
        let theme = viewModel?.theme ?? ColorManager.shared.getColorForRecipe()
        cell.configure(with: ShortRecipeModel(modelForSearch: recipe))
        cell.configureColor(theme: theme)
        cell.selectedIndex = indexPath.item
        cell.delegate = self
        if isMealPlanMode {
            cell.setupPlusOnButton(color: theme.dark)
        }
        return cell
    }
}

extension SearchInRecipeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapCell(indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
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
        showContextMenu(cell, point, index)
    }
}

extension SearchInRecipeViewController: AddProductsSelectionListDelegate {
    func ingredientsSuccessfullyAdded() { }
}

extension SearchInRecipeViewController: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        viewModel?.removeTag(recipeTag: title.trimmingCharacters(in: .whitespacesAndNewlines))
        updateFilterTagsView()
    }
}

extension SearchInRecipeViewController: RecipeListContextMenuViewDelegate {
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

#if RELEASE
        if !Apphud.hasActiveSubscription() {
            self.viewModel?.showPaywall()
            self.contextMenuView.removeSelected()
            return
        }
#endif
            switch state {
            case .addToShoppingList:
                self.viewModel?.addToShoppingList(recipeIndex: self.currentlySelectedIndex,
                                                 contentViewHeigh: self.view.frame.height,
                                                 delegate: self)
            case .addToFavorites:
                self.viewModel?.addToFavorites(recipeIndex: self.currentlySelectedIndex)
                let index = IndexPath(item: self.currentlySelectedIndex, section: 0)
                self.collectionView.reloadItems(at: [index])
            case .addToCollection:
                self.viewModel?.addToCollection(recipeIndex: self.currentlySelectedIndex)
            case .edit:
                self.viewModel?.edit(recipeIndex: self.currentlySelectedIndex)
            case .delete: break
            }
            
            self.contextMenuView.removeSelected()
        }
    }
}
