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
    func createCreateNewListController(model: GroceryListsModel?, router: RootRouter,
                                       compl: @escaping (GroceryListsModel) -> Void) -> UIViewController?
    func createProductsController(model: GroceryListsModel,router: RootRouter,
                                  compl: @escaping () -> Void) -> UIViewController?
    func createProductsSettingsController(snapshot: UIImage?, model: GroceryListsModel,
                                          router: RootRouter, compl: @escaping (GroceryListsModel) -> Void) -> UIViewController?
    func createActivityController(image: [Any]) -> UIViewController?
    func createPrintController(image: UIImage) -> UIPrintInteractionController?
    func createAlertController(title: String, message: String) -> UIAlertController?
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
    
    func createCreateNewListController(model: GroceryListsModel?, router: RootRouter,
                                       compl: @escaping (GroceryListsModel) -> Void) -> UIViewController? {
        let viewController = CreateNewListViewController()
        let viewModel = CreateNewListViewModel()
        viewModel.valueChangedCallback = compl
        viewController.viewModel = viewModel
        viewModel.router = router
        viewModel.model = model
        return viewController
    }
    
    func createProductsController(model: GroceryListsModel, router: RootRouter,
                                  compl: @escaping () -> Void) -> UIViewController? {
        let viewController = ProductsViewController()
        let dataSource = ProductsDataManager(products: model.products)
        let viewModel = ProductsViewModel(model: model, dataSource: dataSource)
        viewModel.valueChangedCallback = compl
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createProductsSettingsController(snapshot: UIImage?, model: GroceryListsModel,
                                          router: RootRouter, compl: @escaping (GroceryListsModel) -> Void) -> UIViewController? {
        let viewController = ProductsSettingsViewController()
        let viewModel = ProductsSettingsViewModel(model: model, snapshot: snapshot)
        viewModel.delegate = viewController
        viewModel.valueChangedCallback = compl
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createActivityController(image: [Any]) -> UIViewController? {
        let viewController = UIActivityViewController(activityItems: image, applicationActivities: nil)
        return viewController
    }
    
    func createPrintController(image: UIImage) -> UIPrintInteractionController? {
        let information = UIPrintInfo(dictionary: nil)
        information.outputType = UIPrintInfo.OutputType.general
        information.jobName = "Grocery List".localized
       
        let viewController = UIPrintInteractionController.shared
        viewController.printInfo = information
        viewController.printingItem = image
        return viewController
    }
    
    func createAlertController(title: String, message: String) -> UIAlertController? {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(alertAction)
        return alert
    }
    
    private func createNavigationViewController(controller: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        return navigationController
    }
}
