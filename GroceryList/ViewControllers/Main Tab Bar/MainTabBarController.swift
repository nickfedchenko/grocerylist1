//
//  MainTabBarController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 18.05.2023.
//

import ApphudSDK
import UIKit

final class MainTabBarController: UITabBarController {
    
    weak var listDelegate: MainTabBarControllerListDelegate?
    weak var pantryDelegate: MainTabBarControllerPantryDelegate?
    weak var recipeDelegate: MainTabBarControllerRecipeDelegate?
    weak var mealDelegate: MainTabBarControllerMealPlanDelegate?
    weak var stocksDelegate: MainTabBarControllerStocksDelegate?
    weak var productsDelegate: MainTabBarControllerProductsDelegate?
    
    let customTabBar = CustomTabBarView()
    
    private var viewModel: MainTabBarViewModel
    private let recipeContextMenu = RecipeContextMenuView()
    private var navView = MainNavigationView()
    private(set) var navBackgroundView = UIView()
    private let contextMenuBackgroundView = UIView()
    private let featureMessageView = ICloudFeatureMessageView()
    private let featureView = NewFeatureView()
    private var initAnalytic = false
    private var didLayoutSubviews = false
    
    private var tabBarHeight: Int {
        UIView.safeAreaTop > 24 ? 90 : 60
    }
    
    init(viewModel: MainTabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupCustomNavBar()
        setupContextMenu()
        setupFeatureView()
        
        self.selectedViewController = viewModel.initialViewController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            makeConstraints()
            customTabBar.layoutIfNeeded()
            didLayoutSubviews = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initAnalytic {
            viewModel.groceryAnalytics()
            viewModel.pantryAnalytics()
            initAnalytic.toggle()
            viewModel.showFeedback()
        }
        viewModel.showNewFeature()
        viewModel.showStockReminderIfNeeded()
    }
    
    func isHideNavView(isHide: Bool) {
        navView.isHidden = isHide
        navBackgroundView.isHidden = isHide
    }
    
    func setTextTabBar(text: String = R.string.localizable.list(),
                       color: UIColor? = R.color.primaryDark()) {
        customTabBar.updateTextAddItem(text)
        customTabBar.updateColorAddItem(color)
    }
    
    private func setupTabBar() {
        viewModel.delegate = self
        tabBar.removeFromSuperview()
        customTabBar.delegate = self
        self.delegate = self
        
        self.viewControllers = viewModel.getViewControllers()
    }
    
    private func setupCustomNavBar() {
        navBackgroundView.backgroundColor = R.color.background()
        navView.backgroundColor = .clear
        navView.delegate = self
        navView.configure(with: .list, animate: false)
        updateUserInfo()
    }
    
    private func setupContextMenu() {
        let menuTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuTapAction))
        contextMenuBackgroundView.addGestureRecognizer(menuTapRecognizer)
        contextMenuBackgroundView.backgroundColor = .black.withAlphaComponent(0.2)
        
        recipeContextMenu.isHidden = true
        contextMenuBackgroundView.isHidden = true
        recipeContextMenu.selectedState = { [weak self] state in
            self?.recipeContextMenu.fadeOut {
                self?.contextMenuBackgroundView.isHidden = true
                switch state {
                case .createRecipe:
                    self?.viewModel.createNewRecipeTapped()
                case .importRecipe:
                    self?.viewModel.importRecipeTapped()
                case .createCollection:
                    self?.viewModel.createNewCollectionTapped()
                }
                self?.recipeContextMenu.removeSelected()
            }
        }
    }
    
    private func setupFeatureView() {
        featureView.isHidden = true
        featureView.greatEnable = { [weak self] in
            self?.viewModel.tappedGreatEnable()
        }
        
        featureView.maybeLater = { [weak self] in
            self?.viewModel.tappedMaybeLater()
        }
        
        featureMessageView.isHidden = true
        featureMessageView.tapOnView = { [weak self] in
            self?.featureMessageView.fadeOut()
        }
        if UserDefaultsManager.shared.isNewFeature {
            let messageCount = UserDefaultsManager.shared.countShowMessageNewFeature
            let isBackupOn = UserDefaultsManager.shared.isICloudDataBackupOn
            featureMessageView.isHidden = messageCount >= 4 || isBackupOn
        }
    }
    
    private func updateUserInfo() {
        navView.setupName(name: viewModel.userName)
        navView.setupImage(photo: viewModel.userPhoto.url,
                           photoAsData: viewModel.userPhoto.data)
    }
    
    private func updateNavView() {
        let itemTag = selectedIndex
        if let item = TabBarItemView.Item(rawValue: itemTag) {
            navView.configure(with: item)
        }
    }
    
    @objc
    private func menuTapAction() {
        recipeContextMenu.fadeOut()
        contextMenuBackgroundView.isHidden = true
    }
    
    private func analytics(tabIndex: Int) {
        switch tabIndex {
        case TabBarItemView.Item.recipe.rawValue:
            AmplitudeManager.shared.logEvent(.recipeSection)
        case TabBarItemView.Item.pantry.rawValue:
            AmplitudeManager.shared.logEvent(.pantrySection)
        default: break
        }
    }
    
    private func makeConstraints() {
        self.view.addSubview(customTabBar)
        self.view.addSubviews([navBackgroundView, navView, contextMenuBackgroundView, recipeContextMenu])
        self.view.addSubviews([featureMessageView, featureView])
        
        navBackgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(navView)
        }
        
        navView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        customTabBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(tabBarHeight)
        }
        
        recipeContextMenu.snp.makeConstraints { make in
            make.bottom.equalTo(customTabBar.snp.top).offset(-9)
            make.centerX.equalToSuperview()
            make.height.equalTo(recipeContextMenu.requiredHeight)
            make.width.equalTo(254)
        }
        
        contextMenuBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        featureMessageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        featureView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          animationControllerForTransitionFrom fromVC: UIViewController,
                          to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransition(viewControllers: tabBarController.viewControllers)
    }
}

extension MainTabBarController: MainNavigationViewDelegate {
    func searchButtonTapped() {
        viewModel.showSearch(self.selectedViewController)
    }
    
    func settingsTapped() {
        viewModel.settingsTapped()
    }
    
    func sortCollectionTapped() {
        viewModel.showCollection()
    }
}

extension MainTabBarController: CustomTabBarViewDelegate {
    func tabSelected(at index: Int) {
        analytics(tabIndex: index)
        selectedIndex = index
        customTabBar.updateItems(by: index)
        updateNavView()
        
        if selectedIndex == 1 {
            viewModel.showPantryStarterPack()
        }
    }
    
    func tabAddItem() {
        let itemTag = selectedIndex
        guard let item = TabBarItemView.Item(rawValue: itemTag) else {
            return
        }
        switch item {
        case .list:
            let navController = self.selectedViewController as? UINavigationController
            let topViewController = navController?.topViewController
            if topViewController is ListViewController {
                listDelegate?.tappedAddItem()
            }
            if topViewController is ProductsViewController {
                productsDelegate?.tappedAddItem()
            }
        case .pantry:
            let navController = self.selectedViewController as? UINavigationController
            let topViewController = navController?.topViewController
            if topViewController is PantryViewController {
                pantryDelegate?.tappedAddItem()
            }
            if topViewController is StocksViewController {
                stocksDelegate?.tappedAddItem()
            }
        case .recipe:
            let navController = self.selectedViewController as? UINavigationController
            let topViewController = navController?.topViewController as? ParentMealPlanRecipeViewController
            if topViewController?.currentIndex == 0 {
                mealDelegate?.tappedAddRecipeToMealPlan()
            }
            if topViewController?.currentIndex == 1 {
                recipeContextMenu.fadeIn()
                contextMenuBackgroundView.isHidden = false
            }
        }
    }
}

extension MainTabBarController: MainTabBarViewModelDelegate {
    func updateListUI() {
        listDelegate?.updatedUI()
    }
    
    func updateRecipeUI(_ recipe: Recipe?) {
        recipeDelegate?.updateRecipeUI(recipe)
    }
    
    func updatePantryUI(_ pantry: PantryModel) {
        pantryDelegate?.updatePantryUI(pantry)
    }
    
    func showFeatureMessageView() {
        setupFeatureView()
    }
    
    func hideFeatureView() {
        featureView.fadeOut()
        featureView.stopViewPropertyAnimator()
    }
    
    func showFeatureView() {
        featureView.isHidden = false
    }
}
