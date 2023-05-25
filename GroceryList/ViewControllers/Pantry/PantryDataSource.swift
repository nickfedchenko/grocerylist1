//
//  PantryDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.05.2023.
//

import Foundation

final class PantryDataSource {
    
    private var pantries: [PantryModel] = []
    
    init() {
        let stockTest1: [Stock] = [
            Stock(pantryId: UUID(), name: "ssfsf", isAvailability: true, isAutoRepeat: false, dateOfCreation: Date()),
            Stock(pantryId: UUID(), name: "dfdfdf", isAvailability: false, isAutoRepeat: false, dateOfCreation: Date())
        ]
        let icon = R.image.whiteCross()?.pngData()
        
        self.pantries = [
            PantryModel(name: "test1", color: 2, stock: stockTest1, dateOfCreation: Date(),
                        sharedId: "", isShared: false, isSharedListOwner: false,
                        isShowImage: .itsTrue, isVisibleCost: false),
            PantryModel(name: "test2", color: 5, icon: icon, stock: [], dateOfCreation: Date(),
                        sharedId: "", isShared: false, isSharedListOwner: false,
                        isShowImage: .itsTrue, isVisibleCost: false),
            PantryModel(name: "test3", color: 4, icon: icon, stock: [], dateOfCreation: Date(),
                        sharedId: "", isShared: false, isSharedListOwner: false,
                        isShowImage: .itsTrue, isVisibleCost: false),
            PantryModel(name: "eree", color: 6, icon: icon, stock: [], dateOfCreation: Date(),
                        sharedId: "", isShared: false, isSharedListOwner: false,
                        isShowImage: .itsTrue, isVisibleCost: false),
            PantryModel(name: "xcvxcvxcv", color: 9, icon: icon, stock: [], dateOfCreation: Date(),
                        sharedId: "", isShared: false, isSharedListOwner: false,
                        isShowImage: .itsTrue, isVisibleCost: false),
            PantryModel(name: "fgjfgj", color: 11, icon: icon, stock: [], dateOfCreation: Date(),
                        sharedId: "", isShared: false, isSharedListOwner: false,
                        isShowImage: .itsTrue, isVisibleCost: false)
        ]
    }
    
    func getPantries() -> [PantryModel] {
        pantries
    }
    
    func updatePantriesAfterMove(updatedPantries: [PantryModel]) {
        pantries = updatedPantries
    }
    
    func movePantry(source: Int, destination: Int) {
        let item = pantries.remove(at: source)
        pantries.insert(item, at: destination)
    }
}
