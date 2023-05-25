//
//  MainTabBarController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 18.05.2023.
//

import ApphudSDK
import UIKit

protocol MainTabBarControllerRecipeDelegate: AnyObject {
    func updateRecipeUI(_ recipe: Recipe?)
}

final class MainTabBarController: UITabBarController {
    
    weak var recipeDelegate: MainTabBarControllerRecipeDelegate?
    
    private var viewModel: MainTabBarViewModel
    private let contextMenu = MainScreenMenuView()
    private let customTabBar = CustomTabBarView()
    private var navView = MainNavigationView()
    private var navBackgroundView = UIView()
    private let contextMenuBackgroundView = UIView()
    private var initAnalytic = false
    private var didLayoutSubviews = false
    
    private var tabBarHeight: Int {
        UIView.safeAreaTop > 0 ? 90 : 60
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
            viewModel.analytic()
            initAnalytic.toggle()
            viewModel.showFeedback()
        }
    }
    
    private func setupTabBar() {
        viewModel.recipeDelegate = self
        tabBar.removeFromSuperview()
        customTabBar.delegate = self
        
        self.delegate = self
        self.tabBar.backgroundColor = .white
        self.tabBar.unselectedItemTintColor = R.color.darkGray()
        self.tabBar.tintColor = R.color.primaryDark()
        self.viewControllers = viewModel.getViewControllers()
    }
    
    private func setupCustomNavBar() {
        navBackgroundView.backgroundColor = R.color.background()?.withAlphaComponent(0.9)
        navView.backgroundColor = .clear
        navView.delegate = self
        navView.configure(with: .list, animate: false)
        updateUserInfo()
    }
    
    private func setupContextMenu() {
        let menuTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuTapAction))
        contextMenuBackgroundView.addGestureRecognizer(menuTapRecognizer)
        
        contextMenu.isHidden = true
        contextMenuBackgroundView.isHidden = true
        contextMenu.selectedState = { [weak self] state in
            self?.contextMenu.fadeOut {
                self?.contextMenuBackgroundView.isHidden = true
                switch state {
                case .createRecipe:
                    self?.viewModel.createNewRecipeTapped()
                case .createCollection:
                    self?.viewModel.createNewCollectionTapped()
                }
                self?.contextMenu.removeSelected()
            }
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
        contextMenu.fadeOut()
        contextMenuBackgroundView.isHidden = true
    }
    
    private func makeConstraints() {
        self.view.addSubview(customTabBar)
        self.view.addSubviews([navBackgroundView, navView, contextMenuBackgroundView, contextMenu])
        
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
        
        contextMenu.snp.makeConstraints { make in
            make.top.equalTo(navView)
            make.trailing.equalToSuperview().offset(-68)
            make.height.equalTo(contextMenu.requiredHeight)
            make.width.equalTo(254)
        }
        
        contextMenuBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController,
                          animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransition(viewControllers: tabBarController.viewControllers)
    }
}

extension MainTabBarController: MainNavigationViewDelegate {
    func searchButtonTapped() {
        if self.selectedViewController is ListViewController {
            viewModel.showSearchProductsInList()
        } else if self.selectedViewController is MainRecipeViewController {
            viewModel.showSearchProductsInRecipe()
        }
    }
    
    func settingsTapped() {
        viewModel.settingsTapped()
    }
    
    func contextMenuTapped() {
        contextMenu.fadeIn()
        contextMenuBackgroundView.isHidden = false
    }
    
    func sortCollectionTapped() {
        viewModel.showCollection()
    }
}

extension MainTabBarController: CustomTabBarViewDelegate {
    func tabSelected(at index: Int) {
#if RELEASE
        let recipeIndex = TabBarItemView.Item.recipe.rawValue
        if index == recipeIndex && !Apphud.hasActiveSubscription() {
            viewModel.showPaywall()
            return
        }
#endif
        selectedIndex = index
        customTabBar.updateItems(by: index)
        updateNavView()
    }
    
    func tabAddItem() {
        viewModel.tappedAddItem(state: .list)
    }
}

extension MainTabBarController: MainTabBarViewModelDelegate {
    func updateRecipeUI(_ recipe: Recipe?) {
        recipeDelegate?.updateRecipeUI(recipe)
    }
}
