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
    
    enum Items {
        case list
        case pantry
        case recipe
    }
    
    weak var recipeDelegate: MainTabBarControllerRecipeDelegate?
    
    private var viewModel: MainTabBarViewModel
    private let contextMenu = MainScreenMenuView()
    private let addItem = AddListView()
    private var navView = MainNavigationView()
    private var navBackgroundView = UIView()
    private let contextMenuBackgroundView = UIView()
    private var initAnalytic = false
    
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
        setupAddItem()
        setupContextMenu()
        makeConstraints()
        updateAddItemConstraints()
        self.selectedViewController = viewModel.initialViewController
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
        navView.configure(with: .list)
        updateUserInfo()
    }
    
    private func setupAddItem() {
        addItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAddItem)))
        addItem.setColor(background: R.color.primaryDark(),
                         image: R.color.primaryDark())
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
    
    @objc
    private func tapAddItem() {
        viewModel.tappedAddItem(state: .list)
    }
    
    @objc
    private func menuTapAction() {
        contextMenu.fadeOut()
        contextMenuBackgroundView.isHidden = true
    }
    
    /// метод  для будущих изменений, возможно будет в настройках свитч для левшей)
    /// переместит кнопку Создания листа влево/вправо в зависимости от isRightHanded
    private func updateAddItemConstraints() {
        self.viewControllers = viewModel.getViewControllers()
        addItem.updateView(isRightHanded: viewModel.getIsRightHanded())
        
        guard viewModel.getIsRightHanded() else {
            addItem.snp.updateConstraints {
                $0.trailing.equalToSuperview().offset(-235)
                $0.leading.equalToSuperview().offset(-5)
            }
            return
        }
        addItem.snp.updateConstraints {
            $0.leading.equalToSuperview().offset(235)
            $0.trailing.equalToSuperview().offset(5)
        }
    }
    
    private func makeConstraints() {
        self.tabBar.addSubview(addItem)
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
        
        addItem.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(235)
            $0.trailing.equalToSuperview().offset(5)
            $0.top.equalToSuperview().offset(-1)
            $0.bottom.equalToSuperview().offset(5)
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
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
#if RELEASE
        if (viewController is MainRecipeViewController) && !Apphud.hasActiveSubscription() {
            return false
        }
#endif
        if viewController is ListViewController {
            navView.configure(with: .list)
        }
        if viewController is PantryViewController {
            navView.configure(with: .pantry)
        }
        if viewController is MainRecipeViewController {
            navView.configure(with: .recipe)
        }
        return !(viewController is StopperViewController)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let selectedIndex = self.tabBar.items?.firstIndex(of: item) else {
            return
        }
        
#if RELEASE
        let recipeIndex = viewModel.getIsRightHanded() ? 2 : 4
        if selectedIndex == recipeIndex && !Apphud.hasActiveSubscription() {
            viewModel.showPaywall()
        }
#endif
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

extension MainTabBarController: MainTabBarViewModelDelegate {
    func updateRecipeUI(_ recipe: Recipe?) {
        recipeDelegate?.updateRecipeUI(recipe)
    }
}

extension MainTabBarController.Items {
    var title: String {
        switch self {
        case .list:     return R.string.localizable.list()
        case .pantry:   return R.string.localizable.pantry()
        case .recipe:   return R.string.localizable.recipe().trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    var image: UIImage? {
        switch self {
        case .list:     return R.image.list_tabbar_inactive()
        case .pantry:   return R.image.pantry_tabbar_inactive()
        case .recipe:   return R.image.recipe_tabbar_inactive()
        }
    }
    
    var selectImage: UIImage? {
        switch self {
        case .list:     return R.image.list_tabbar_active()
        case .pantry:   return R.image.pantry_tabbar_active()
        case .recipe:   return R.image.recipe_tabbar_active()
        }
    }
    
    var imageInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
    }
    
    var titleOffset: UIOffset {
        switch self {
        case .list:     return UIOffset(horizontal: 15, vertical: 8)
        case .pantry:   return UIOffset(horizontal: 0, vertical: 8)
        case .recipe:   return UIOffset(horizontal: -15, vertical: 8)
        }
    }
}

// Заглушка для таб бара
final class StopperViewController: UIViewController { }
