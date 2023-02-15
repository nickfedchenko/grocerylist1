//
//  ResetPasswordModelManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 15.02.2023.
//

import Foundation

class ResetPasswordModelManager {
    
    static var shared = ResetPasswordModelManager()

    func getResetPasswordModel() -> ResetPasswordModel? {
        guard let domainModel = CoreDataManager.shared.getResetPasswordModel() else { return nil }
        return getLocalModel(domainModel: domainModel)
    }
    
    func deleteResetPasswordModel() {
        CoreDataManager.shared.deleteResetPasswordModel()
    }
    
    func saveResetPasswordModel(model: ResetPasswordModel) {
        CoreDataManager.shared.saveResetPasswordModel(resetPasswordModel: model)
    }
    
    func checkTokenExpiration() {
        
    }
    
    private func getLocalModel(domainModel: DomainResetPasswordModel) -> ResetPasswordModel {
        ResetPasswordModel(email: domainModel.email ?? "",
                           resetToken: domainModel.resetToken ?? "",
                           dateOfExpiration: domainModel.dateOfExpiration ?? Date())
    }
}
