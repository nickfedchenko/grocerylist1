//
//  DBRecipe+CoreDataProperties.swift
//  
//
//  Created by Vladimir Banushkin on 03.12.2022.
//
//

import Foundation
import CoreData


extension DBRecipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBRecipe> {
        return NSFetchRequest<DBRecipe>(entityName: "DBRecipe")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var recipeDescription: String?
    @NSManaged public var cookingTime: Int32
    @NSManaged public var totalServings: Int16
    @NSManaged public var dishWeight: Double
    @NSManaged public var dishWeightType: Int16
    @NSManaged public var countries: Data?
    @NSManaged public var instructions: Data?
    @NSManaged public var eatingTags: Data?
    @NSManaged public var dishTypeTags: Data?
    @NSManaged public var processingTypeTags: Data?
    @NSManaged public var additionalTags: Data?
    @NSManaged public var dietTags: Data?
    @NSManaged public var exceptionTags: Data?
    @NSManaged public var photo: String?
    @NSManaged public var isDraft: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var ingredients: Data?
    @NSManaged public var localCollection: Data?
    
    static func prepare(fromPlainModel model: Recipe, context: NSManagedObjectContext) -> DBRecipe {
        let recipe = DBRecipe(context: context)
        recipe.id = Int32(model.id)
        recipe.title = model.title
        recipe.cookingTime = Int32(model.cookingTime ?? -1)
        recipe.totalServings = Int16(model.totalServings)
        recipe.dishWeight = model.dishWeight ?? -1.0
        recipe.dishWeightType = Int16(model.dishWeightType ?? -1)
        recipe.countries = encodeOptionalStringArray(array: model.countries)
        recipe.instructions = encodeOptionalStringArray(array: model.instructions)
        recipe.eatingTags = try? JSONEncoder().encode(model.eatingTags)
        recipe.dishTypeTags = try? JSONEncoder().encode(model.dishTypeTags)
        recipe.processingTypeTags = try? JSONEncoder().encode(model.processingTypeTags)
        recipe.additionalTags = try? JSONEncoder().encode(model.additionalTags)
        recipe.dietTags = try? JSONEncoder().encode(model.dietTags)
        recipe.exceptionTags = try? JSONEncoder().encode(model.exceptionTags)
        recipe.photo = model.photo
        recipe.isDraft = model.isDraft
        recipe.createdAt = model.createdAt
        recipe.ingredients = try? JSONEncoder().encode(model.ingredients)
        if let localCollection = model.localCollection {
            recipe.localCollection = try? JSONEncoder().encode(localCollection)
        } else if !UserDefaults.standard.bool(forKey: "Recipe\(model.id)") {
            var collections: [CollectionModel] = []
            model.eatingTags.forEach { tag in
                collections.append(CollectionModel(id: tag.id, title: tag.title))
            }
            recipe.localCollection = try? JSONEncoder().encode(collections)
            UserDefaults.standard.setValue(true, forKey: "Recipe\(model.id)")
        }
        return recipe
    }
    
    private static func encodeOptionalStringArray(array: [String]?) -> Data? {
        guard let array = array else { return nil }
        let description = array.description
        let data = description.data(using: .utf8)
        return data
    }
    
     
}
