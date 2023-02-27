//
//  UIViewControllerExtension.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import UIKit

extension UIViewController {
    func alertOk(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// установка базового навигейшн бара
    func setupNavigationBar(titleText: String) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        title = titleText
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.SFProRounded.bold(size: 22).font ?? .systemFont(ofSize: 28),
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#19645A")
        ]
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "#19645A")
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.SFProRounded.semibold(size: 17).font ?? .systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#19645A")
        ]
        
        let backItem = UIBarButtonItem()
        backItem.title = titleText
        backItem.setTitleTextAttributes(
            [
                NSAttributedString.Key.font : UIFont.SFProRounded.semibold(size: 17).font ?? .systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor : UIColor(hex: "#19645A")
            ],
            for: .normal)
        navigationItem.backBarButtonItem = backItem
    }
}
