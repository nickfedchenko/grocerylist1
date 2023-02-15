//
//  UserAccountManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 13.02.2023.
//

import Foundation

class UserAccountManager {
    
    static var shared = UserAccountManager()

    func getUser() -> User? {
        guard let domainUser = CoreDataManager.shared.getUser() else { return nil }
        return getLocalModel(domainModel: domainUser)
    }
    
    func deleteUser() {
        CoreDataManager.shared.deleteUser()
    }
    
    func saveUser(user: User) {
        CoreDataManager.shared.saveUser(user: user)
    }
    
    func checkTokenExpiration() {
        
    }
    
    func getLocalModel(domainModel: DomainUser) -> User {
        User(id: Int(domainModel.id),
             username: domainModel.name,
             avatar: domainModel.avatarUrl,
             email: domainModel.mail ?? "",
             token: domainModel.token ?? "",
             password: domainModel.password,
             avatarAsData: domainModel.avatarAsData)
    }
}
