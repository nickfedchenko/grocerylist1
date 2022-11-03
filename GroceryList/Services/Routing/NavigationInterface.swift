//
//  NavigationInterface.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import UIKit

// MARK: - Navigation Interface

protocol NavigationInterface: AnyObject {
    var navigationController: UINavigationController? { get }
    var viewController: UIViewController? { get set }
    var topViewController: UIViewController? { get }
    
    var viewControllerFactory: ViewControllerFactoryProtocol { get }
        
    func navigationPresent(_ viewController: UIViewController, style: UIModalPresentationStyle, animated: Bool)
    func navigationDismiss(_ viewController: UIViewController)
    
    func navigationPushViewController(_ viewController: UIViewController, animated: Bool)
    func navigationPopViewController(animated: Bool)
    func navigationPopToRootViewController(animated: Bool)
    func navigationPop(at ind: Int, animated: Bool)
}

extension NavigationInterface {
    
    var topViewController: UIViewController? {
        self.viewController?.presentedViewController
    }
    
    func navigationPresent(_ viewController: UIViewController,
                           style: UIModalPresentationStyle = .overCurrentContext, animated: Bool) {
        viewController.modalPresentationStyle = style
        
        if let selfVS = self.viewController {
            selfVS.present(viewController, animated: animated)
            return
        }
        navigationController?.present(viewController, animated: animated)
    }
    
    func navigationDismiss(_ viewController: UIViewController) {
        if let presented = topViewController,
           presented == viewController {
            DispatchQueue.main.async {
                presented.dismiss(animated: true)
            }
        }
    }
    
    func navigationPushViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func navigationPopViewController(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    func navigationPopToRootViewController(animated: Bool) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    func navigationPop(at ind: Int, animated: Bool) {
        guard let navigationController = navigationController else { return }
        navigationController.popToViewController(navigationController.viewControllers[ind], animated: true)
    }

}
