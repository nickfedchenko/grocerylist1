//
//  DomainUser+CoreDataProperties.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 13.02.2023.
//
//

import Foundation
import CoreData


extension DomainUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DomainUser> {
        return NSFetchRequest<DomainUser>(entityName: "DomainUser")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var mail: String?
    @NSManaged public var token: String?
    @NSManaged public var password: String?
    @NSManaged public var passwordResetToken: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var avatarAsData: Data?
    @NSManaged public var passwordResetTokenDate: Date?
}

extension DomainUser : Identifiable {

}
