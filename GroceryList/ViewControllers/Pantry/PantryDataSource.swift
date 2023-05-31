//
//  PantryDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.05.2023.
//

import Foundation

final class PantryDataSource {
    
    var reloadData: (() -> Void)?
    
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
                        isShowImage: .itsTrue, isVisibleCost: false)
        ]
    }
    
    func getPantries() -> [PantryModel] {
        pantries
    }
    
    func updatePantriesAfterMove(updatedPantries: [PantryModel]) {
        pantries = updatedPantries
    }
    
    func addPantry(_ pantry: PantryModel) {
        if pantries.contains(where: { $0.id == pantry.id }) {
            pantries.removeAll { pantry.id == $0.id }
        }
        pantries.append(pantry)
        reloadData?()
    }
    
    func movePantry(source: Int, destination: Int) {
        let item = pantries.remove(at: source)
        pantries.insert(item, at: destination)
    }
    
    func delete(pantry: PantryModel) {
        pantries.removeAll { pantry.id == $0.id }
        reloadData?()
    }
}
