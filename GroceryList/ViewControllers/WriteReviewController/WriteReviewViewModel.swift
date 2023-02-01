//
//  WriteReviewViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.02.2023.
//

import Foundation
import MessageUI

protocol WriteReviewViewModelDelegate: AnyObject, MFMailComposeViewControllerDelegate {
    func presentMail(controller: UIViewController)
}

class WriteReviewViewModel {
    weak var delegate: WriteReviewViewModelDelegate?
    weak var router: RootRouter?
    
    func yesButtonTapped() {
        guard let
                url = URL(string: "itms-apps://itunes.apple.com/app/id1659848939?action=write-review"),
              UIApplication.shared.canOpenURL(url)
        else { return }
        UIApplication.shared.open(url)
    }
    
    func noButtonTapped() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = delegate
            mail.setToRecipients(["ksennn.vasko0222@yandex.ru"])
            mail.setMessageBody("<p>Hey! I have some questions!</p>", isHTML: true)
            delegate?.presentMail(controller: mail)
        } else {
            print("Send mail not allowed")
        }
    }
}
