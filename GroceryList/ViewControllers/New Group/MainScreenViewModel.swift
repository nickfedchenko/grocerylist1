//
//  MainScreenViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 03.11.2022.
//

import Foundation
import UIKit

protocol MainScreenViewModelDelegate: AnyObject {
    func getTitleForHeader(at ind: Int) -> String
    func getNumberOfSections() -> Int
    func getNumberOfCells() -> Int
    func getNameOfList(at ind: Int) -> String
    func getBGColor(at ind: Int) -> UIColor
    func isTopRounded(at ind: Int) -> Bool
    func isBottomRounded(at ind: Int) -> Bool
}

class MainScreenViewModel: MainScreenViewModelDelegate {
    
    private let dataSource = MainScreenDataSource()
    
    private var model: [GroseryListsModel] {
        dataSource.coldStartModel
    }
   
    func getNumberOfSections() -> Int {
        return
    }
    
    func getTitleForHeader(at ind: Int) -> String {
        return "la la la"
    }

    func getNumberOfCells() -> Int {
        return 3
    }
    
    func getNameOfList(at ind: Int) -> String {
        return "sadfsdf"
    }
    
    func getBGColor(at ind: Int) -> UIColor {
        return UIColor.blue
    }
    
    func isTopRounded(at ind: Int) -> Bool {
        return true
    }
    
    func isBottomRounded(at ind: Int) -> Bool {
        return false
    }
}

class MainScreenDataSource {
    let coldStartModel = [
        GroseryListsModel(section: .favorite, lists: [List(name: "Supermarket".localized, items: "0/0")]),
        GroseryListsModel(section: .today, lists: [List(name: "dfasdas".localized, items: "0334")])
    ]
}

struct GroseryListsModel {
    var section: GroceryListsCellSection
    var lists: [List]
}

struct List {
    var name: String
    var items: String
}

enum GroceryListsCellSection: String {
    case favorite = ""
    case today = "Today"
    case sevenDays = "SevenDays"
    case month = "OneMonth"
}
