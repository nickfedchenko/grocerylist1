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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.recipes()
        label.font = UIFont.SFProDisplay.heavy(size: 32).font
        label.textColor = R.color.primaryDark()
        return label
    }()
    
    private lazy var searchIconButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.searchButtonImage()?.withTintColor(R.color.primaryDark() ?? .black),
                        for: .normal)
        button.addTarget(self, action: #selector(tappedOnSearch), for: .touchUpInside)
        return button
    }()
    
    private lazy var recipesCollectionView: UICollectionView = {
        let layout = collectionViewLayoutManager.makeRecipesLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(classCell: RecipePreviewCell.self)
        collectionView.register(classCell: MoreRecipeCell.self)
        collectionView.register(classCell: RecipeColorCell.self)
        collectionView.register(classCell: FolderRecipePreviewCell.self)
        collectionView.registerHeader(classHeader: RecipesFolderHeader.self)
        collectionView.contentInset.bottom = 90
        collectionView.contentInset.top = topContentInset + 108
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var collectionViewLayoutManager = MainRecipeCollectionViewLayout(recipeCount: viewModel.defaultRecipeCount)
    private let activityView = ActivityIndicatorView()
    private let searchView = RecipeSearchView()
    private let titleBackgroundView = UIView()
    
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
        let tabBar = (self.tabBarController as? MainTabBarController)
        tabBar?.recipeDelegate = self
        tabBar?.navBackgroundView.backgroundColor = R.color.background()?.withAlphaComponent(0.95)
        titleBackgroundView.backgroundColor = R.color.background()?.withAlphaComponent(0.95)
        
        let tapOnSearch = UITapGestureRecognizer(target: self, action: #selector(tappedOnSearch))
        searchView.addGestureRecognizer(tapOnSearch)
        
        setupConstraints()
        viewModelChanges()
        updateCollectionContentInset()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as? MainTabBarController)?.isHideNavView(isHide: false)
        (self.tabBarController as? MainTabBarController)?.setTextTabBar(
            text: R.string.localizable.create().uppercased()
        )
        
        if !isShowFirstViewWillAppear {
            updateRecipeCollectionView()
            isShowFirstViewWillAppear = true
        }
        
        DispatchQueue.main.async {
            self.viewModel.updateRecipesSection()
            self.recipesCollectionView.reloadData()
        }
    }

    private func viewModelChanges() {
        viewModel.reloadRecipes = { [weak self] in
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
                self?.viewModel.updateSection()
                DispatchQueue.main.async {
                    self?.recipesCollectionView.reloadData()
                }
            }
        }
    }
    
    private func updateCollectionContentInset() {
        let offset: CGFloat = UserDefaultsManager.shared.recipeIsFolderView ? 0 : -24
        searchView.snp.updateConstraints {
            $0.bottom.equalTo(recipesCollectionView.snp.top).offset(offset)
        }
        let contentInset: CGFloat = UserDefaultsManager.shared.recipeIsFolderView ? 78 : 108
        recipesCollectionView.contentInset.top = topContentInset + contentInset
    }
    
    private func setupCollectionViewCell(indexPath: IndexPath) -> UICollectionViewCell {
        let color = viewModel.collectionColor(for: indexPath.section)
        
        if indexPath.row == 0 {
            let colorCell = recipesCollectionView.reusableCell(classCell: RecipeColorCell.self,
                                                              indexPath: indexPath)
            colorCell.configure(color: color.medium)
            return colorCell
        }
        
        let recipeCount = viewModel.defaultRecipeCount
        
        if indexPath.row == recipeCount - 1,
           let sectionModel = viewModel.getRecipeSectionsModel(for: indexPath.section) {
            let moreCell = recipesCollectionView.reusableCell(classCell: MoreRecipeCell.self, indexPath: indexPath)
            moreCell.delegate = self
            moreCell.configure(at: indexPath.section,
                               title: "\(sectionModel.recipes.count - recipeCount + 2)")
            moreCell.configureColor(theme: color)
            return moreCell
        }
        
        guard let model = viewModel.getShortRecipeModel(for: indexPath) else {
            return UICollectionViewCell()
        }
        let cell = recipesCollectionView.reusableCell(classCell: RecipePreviewCell.self, indexPath: indexPath)
        cell.configure(with: model, color: color)
        return cell
    }
    
    private func setupFolderViewCell(indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionModel = viewModel.getRecipeSectionsModel(for: indexPath.item) else {
            return UICollectionViewCell()
        }
        let cell = recipesCollectionView.reusableCell(classCell: FolderRecipePreviewCell.self, indexPath: indexPath)
        cell.layoutIfNeeded()
        let image = viewModel.collectionImage(for: indexPath)
        cell.configure(folderTitle: sectionModel.sectionType.title,
                       photoUrl: image.url, imageData: image.data,
                       color: viewModel.collectionColor(for: indexPath.item),
                       recipeCount: "\(sectionModel.recipes.count)")
        return cell
    }
    
    @objc
    private func tappedOnSearch() {
        viewModel.showSearch()
    }
    
    @objc
    private func appWillEnterForeground() {
        viewModel.updateUI()
    }
    
    private func setupConstraints() {
        view.backgroundColor = R.color.background()
        view.addSubviews([recipesCollectionView, titleBackgroundView, activityView])
        titleBackgroundView.addSubviews([titleLabel, searchIconButton])
        recipesCollectionView.addSubview(searchView)

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
        
        titleBackgroundView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(titleBackgroundView).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(32)
        }
        
        searchIconButton.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing)
            $0.centerY.equalTo(titleLabel)
            $0.height.width.equalTo(40)
        }
        
        searchView.snp.makeConstraints { make in
            make.bottom.equalTo(recipesCollectionView.snp.top).offset(-24)
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(48)
        }
    }
}

// MARK: - CollectionView
extension MainRecipeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isFolder = UserDefaultsManager.shared.recipeIsFolderView
        
        guard isFolder else {
            viewModel.showRecipe(by: indexPath)
            return
        }
        
        guard let section = viewModel.getRecipeSectionsModel(for: indexPath.item) else {
            return
        }
        viewModel.router?.goToRecipes(for: section)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bgTitleViewOffset: CGFloat = -160
        
        searchIconButton.isHidden = scrollView.contentOffset.y < bgTitleViewOffset
    }
}

extension MainRecipeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        UserDefaultsManager.shared.recipeIsFolderView ? 1 : viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        UserDefaultsManager.shared.recipeIsFolderView ? viewModel.numberOfSections : viewModel.recipeCount(for: section)
    }
    
    func collectionView( _ collectionView: UICollectionView,
                         cellForItemAt indexPath: IndexPath ) -> UICollectionViewCell {
        let isFolder = UserDefaultsManager.shared.recipeIsFolderView
        
        guard isFolder else {
            return setupCollectionViewCell(indexPath: indexPath)
        }
        
        return setupFolderViewCell(indexPath: indexPath)
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
        
        header.configure(with: sectionModel, at: indexPath.section,
                         color: viewModel.collectionColor(for: indexPath.section))
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
//        if let recipe {
//            viewModel.showCustomRecipe(recipe: recipe)
//        }
    }
    
    func tappedChangeView() {
        if UserDefaultsManager.shared.recipeIsFolderView {
            AmplitudeManager.shared.logEvent(.recipeToggleFolderViev)
        } else {
            AmplitudeManager.shared.logEvent(.recipeToggleCollectionView)
        }
        
        DispatchQueue.main.async {
            self.updateCollectionContentInset()
            self.recipesCollectionView.reloadData()
            self.recipesCollectionView.collectionViewLayout.invalidateLayout()
            let layout = self.collectionViewLayoutManager.makeRecipesLayout()
            self.recipesCollectionView.setCollectionViewLayout(layout, animated: false)
            self.recipesCollectionView.collectionViewLayout.collectionView?.reloadData()
            
            if UserDefaultsManager.shared.recipeIsFolderView {
                self.recipesCollectionView.reloadData()
            }
        }
    }
}
