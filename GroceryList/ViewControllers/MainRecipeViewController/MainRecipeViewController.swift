//
//  MainRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import ApphudSDK
import SnapKit
import UIKit

final class MainRecipeViewController: UIViewController {
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    private var viewModel: MainRecipeViewModel
    
    private lazy var recipesCollectionView: UICollectionView = {
        let layout = collectionViewLayoutManager.makeRecipesLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: RecipePreviewCell.self)
        collectionView.register(classCell: MoreRecipeCell.self)
        collectionView.registerHeader(classHeader: RecipesFolderHeader.self)
        collectionView.contentInset.bottom = 20
        collectionView.contentInset.top = topContentInset
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        return collectionView
    }()
    
    private var collectionViewLayoutManager = MainRecipeCollectionViewLayout()
    private let activityView = ActivityIndicatorView()
    private var isShowFirstViewWillAppear = false
    private var topContentInset: CGFloat {
        let topSafeArea = UIView.safeAreaTop
        return topSafeArea > 24 ? topSafeArea : topSafeArea + 44
    }

    init(viewModel: MainRecipeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as? MainTabBarController)?.recipeDelegate = self
        setupConstraints()
        viewModelChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isShowFirstViewWillAppear {
            updateRecipeCollectionView()
            isShowFirstViewWillAppear = true
        }
    }

    private func viewModelChanges() {
        viewModel.reloadRecipes = { [weak self] in
#if RELEASE
            guard Apphud.hasActiveSubscription() else {
                return
            }
#endif
            DispatchQueue.main.async {
                self?.recipesCollectionView.reloadData()
            }
        }
        
        viewModel.updateRecipeLoaded = { [weak self] in
            DispatchQueue.main.async {
                self?.activityView.removeFromView()
                self?.recipesCollectionView.reloadData()
            }
        }
    }

    private func updateRecipeCollectionView() {
        if InternetConnection.isConnected() && viewModel.ifNeedActivity() {
            activityView.show(for: recipesCollectionView)
        } else {
            activityView.removeFromView()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.viewModel.updateFavorites()
                self?.viewModel.updateCustomSection()
                DispatchQueue.main.async {
                    self?.recipesCollectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UI
    private func setupConstraints() {
        view.backgroundColor = R.color.background()
        view.addSubviews([recipesCollectionView, activityView])

        recipesCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        activityView.snp.makeConstraints { make in
            make.width.equalTo(self.view.bounds.width)
            make.top.equalTo(recipesCollectionView)
            make.bottom.equalToSuperview()
            make.leading.equalTo(recipesCollectionView)
        }
    }
}

// MARK: - CollectionView
extension MainRecipeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.showRecipe(by: indexPath)
    }
}

extension MainRecipeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.recipeCount(for: section)
    }
    
    func collectionView( _ collectionView: UICollectionView,
                         cellForItemAt indexPath: IndexPath ) -> UICollectionViewCell {
        
        let recipeCount = viewModel.defaultRecipeCount
        
        if indexPath.row == recipeCount - 1,
           let sectionModel = viewModel.getRecipeSectionsModel(for: indexPath.section) {
            let moreCell = collectionView.reusableCell(classCell: MoreRecipeCell.self, indexPath: indexPath)
            moreCell.delegate = self
            moreCell.configure(at: indexPath.section, title: "\(sectionModel.recipes.count - recipeCount)")
            return moreCell
        }
        
        guard let model = viewModel.getShortRecipeModel(for: indexPath) else {
            return UICollectionViewCell()
        }
        let cell = collectionView.reusableCell(classCell: RecipePreviewCell.self, indexPath: indexPath)
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.reusableHeader(classHeader: RecipesFolderHeader.self, indexPath: indexPath) else {
            return UICollectionReusableView()
        }
        guard let sectionModel = viewModel.getRecipeSectionsModel(for: indexPath.section) else {
            return header
        }
        
        header.configure(with: sectionModel, at: indexPath.section)
        header.delegate = self
        return header
    }
}

extension MainRecipeViewController: RecipesFolderHeaderDelegate {
    func headerTapped(at index: Int) {
        guard let section = viewModel.getRecipeSectionsModel(for: index) else {
            return
        }
        viewModel.router?.goToRecipes(for: section)
    }
}

extension MainRecipeViewController: MainTabBarControllerRecipeDelegate {
    func updateRecipeUI(_ recipe: Recipe?) {
        viewModel.updateUI()
        if let recipe {
            viewModel.showCustomRecipe(recipe: recipe)
        }
    }
}
