//
//  CreateNewStoreViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 18.04.2023.
//

import UIKit

class CreateNewStoreViewController: CreateNewCategoryViewController {
    
    var storeViewModel: CreateNewStoreViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStore()
    }

    override func saveAction() {
        let text = textField.text ?? ""
        storeViewModel?.saveNewStore(name: text)
        hidePanel()
    }
    
    override func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            storeViewModel?.dissmisStore()
        }
        super.swipeDownAction(recognizer)
    }
    
    override func tappedOnView() {
        storeViewModel?.dissmisStore()
        hidePanel()
    }
    
    override func textField(_ textField: UITextField,
                            shouldChangeCharactersIn range: NSRange,
                            replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if newLength > 2 {
            readyToSave()
        } else {
            notReadyToSave()
        }
        return newLength <= 16
    }
}
