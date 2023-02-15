//
//  DomainResetPasswordModel+CoreDataProperties.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 15.02.2023.
//
//

import Foundation
import CoreData


extension DomainResetPasswordModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DomainResetPasswordModel> {
        return NSFetchRequest<DomainResetPasswordModel>(entityName: "DomainResetPasswordModel")
    }

    @NSManaged public var resetToken: String?
    @NSManaged public var email: String?
    @NSManaged public var dateOfExpiration: Date?
    @NSManaged public var id: Int64

}

extension DomainResetPasswordModel : Identifiable {

}
