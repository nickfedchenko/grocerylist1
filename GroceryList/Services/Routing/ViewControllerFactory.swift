//
//  ViewControllerFactory.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import UIKit

protocol ViewControllerFactoryProtocol {
    func createOnboardingController(router: RootRouter) -> UIViewController?
    func createMainController(router: RootRouter) -> UIViewController?
    func createCreateNewListController(router: RootRouter, compl: @escaping () -> Void) -> UIViewController?
    func createProductsController(model: GroseryListsModel,router: RootRouter,
                                  compl: @escaping () -> Void) -> UIViewController?
    func createProductsSettingsController(router: RootRouter, compl: @escaping () -> Void) -> UIViewController?
}
    
// MARK: - Factory

final class ViewControllerFactory: ViewControllerFactoryProtocol {
    
    func createOnboardingController(router: RootRouter) -> UIViewController? {
        let viewController = OnboardingViewController()
        viewController.router = router
        return viewController
    }
    
    func createMainController(router: RootRouter) -> UIViewController? {
        let viewController = MainScreenViewController()
        let viewModel = MainScreenViewModel()
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createCreateNewListController(router: RootRouter, compl: @escaping () -> Void) -> UIViewController? {
        let viewController = CreateNewListViewController()
        let viewModel = CreateNewListViewModel()
        viewModel.valueChangedCallback = compl
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createProductsController(model: GroseryListsModel, router: RootRouter,
                                  compl: @escaping () -> Void) -> UIViewController? {
        let viewController = ProductsViewController()
        let viewModel = ProductsViewModel(model: model)
        let dataSource = ProductsDataManager(supplays: model.supplays)
        viewModel.valueChangedCallback = compl
        viewController.viewModel = viewModel
        viewModel.router = router
        viewModel.dataSource = dataSource
        return viewController
    }
    
    func createProductsSettingsController(router: RootRouter, compl: @escaping () -> Void) -> UIViewController? {
        let viewController = ProductsSettingsViewController()
        let viewModel = ProductsSettingsViewModel()
        viewModel.valueChangedCallback = compl
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    private func createNavigationViewController(controller: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        return navigationController
    }
}
