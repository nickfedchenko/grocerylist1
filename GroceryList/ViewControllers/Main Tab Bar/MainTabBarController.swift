//
//  MainTabBarController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 18.05.2023.
//

import UIKit

final class MainTabBarController: UITabBarController {

    enum Items {
        case list
        case pantry
        case recipe
    }
    
    private var viewModel: MainTabBarViewModel
    private let addItem = AddListView()
    private let appearance = UITabBarAppearance()
    
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
        setupAddItem()
        makeConstraints()
    }
    
    private func setupTabBar() {       
        self.delegate = self
        self.tabBar.backgroundColor = .white
        self.viewControllers = viewModel.getViewControllers()
    }
    
    private func setupAddItem() {
        addItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAddItem)))
        addItem.setColor(background: R.color.primaryDark(),
                         image: R.color.primaryDark())
    }
    
    @objc
    private func tapAddItem() {
        viewModel.tappedAddItem(state: .list)
    }
    
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
        
        addItem.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(235)
            $0.trailing.equalToSuperview().offset(5)
            $0.top.equalToSuperview().offset(-1)
            $0.bottom.equalToSuperview().offset(5)
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
        return !(viewController is StopperViewController)
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
