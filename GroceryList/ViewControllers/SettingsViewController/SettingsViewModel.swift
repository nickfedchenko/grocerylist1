//
//  SettingsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import Foundation
import UIKit

protocol SettingsViewModelDelegate: AnyObject {

}

class SettingsViewModel {
    
    weak var delegate: SettingsViewModelDelegate?
    weak var router: RootRouter?
   
}
