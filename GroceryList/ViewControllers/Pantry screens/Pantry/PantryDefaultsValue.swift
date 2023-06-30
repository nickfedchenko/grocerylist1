//
//  PantryDefaultsValue.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 30.06.2023.
//

import UIKit

extension PantryDataSource.DefaultsPantry {
    var title: String {
        switch self {
        case .fridge:       return R.string.localizable.fridge()
        case .grocery:      return R.string.localizable.grocery()
        case .spicesHerbs:  return R.string.localizable.spicesHerbs()
        case .beautyHealth: return R.string.localizable.beautyHealth()
        case .household:    return R.string.localizable.household()
        case .hobby:        return R.string.localizable.hobby()
        }
    }
    
    var color: Int {
        switch self {
        case .fridge:       return 9
        case .grocery:      return 5
        case .spicesHerbs:  return 3
        case .beautyHealth: return 7
        case .household:    return 12
        case .hobby:        return 2
        }
    }
    
    var imageData: Data? {
        switch self {
        case .fridge:       return R.image.defaults_pantry_list_Fridge()?.pngData()
        case .grocery:      return R.image.defaults_pantry_list_Grocery()?.pngData()
        case .spicesHerbs:  return R.image.defaults_pantry_list_SpicesHerbs()?.pngData()
        case .beautyHealth: return R.image.defaults_pantry_list_BeautyHealth()?.pngData()
        case .household:    return R.image.defaults_pantry_list_Household()?.pngData()
        case .hobby:        return R.image.defaults_pantry_list_Hobby()?.pngData()
        }
    }
}

extension PantryDataSource.DefaultsFridgeStocks {
    var netProductId: Int? {
        switch self {
        case .milk:             return 130833
        case .mayonnaise:       return 112605
        case .tomatoes:         return 112159
        case .lettuce:          return 130866
        case .creamCheese:      return 130837
        case .parmesan:         return 130306
        case .smokedBacon:      return 112493
        case .butterUnsalted:   return 112422 // тут просто масло
        case .chickenFillet:    return nil
        case .frozenVegetables: return nil
        case .frozenMushrooms:  return nil
        case .frozenBroccoli:   return nil
        }
    }
    
    var title: String {
        switch self {
        case .milk:             return R.string.localizable.milk()
        case .mayonnaise:       return R.string.localizable.mayonnaise()
        case .tomatoes:         return R.string.localizable.tomatoes()
        case .lettuce:          return R.string.localizable.lettuce()
        case .creamCheese:      return R.string.localizable.creamCheese()
        case .parmesan:         return R.string.localizable.parmesan()
        case .smokedBacon:      return R.string.localizable.smokedBacon()
        case .butterUnsalted:   return R.string.localizable.butterUnsalted()
        case .chickenFillet:    return R.string.localizable.chickenFillet()
        case .frozenVegetables: return R.string.localizable.frozenVegetables()
        case .frozenMushrooms:  return R.string.localizable.frozenMushrooms()
        case .frozenBroccoli:   return R.string.localizable.frozenBroccoli()
        }
    }

    var imageData: Data? {
        switch self {
        case .milk:             return R.image.fridge_Milk()?.pngData()
        case .mayonnaise:       return R.image.fridge_Mayonnaise()?.pngData()
        case .tomatoes:         return R.image.fridge_Tomatoes()?.pngData()
        case .lettuce:          return R.image.fridge_Lettuce()?.pngData()
        case .creamCheese:      return R.image.fridge_CreamCheese()?.pngData()
        case .parmesan:         return R.image.fridge_Parmesan()?.pngData()
        case .smokedBacon:      return R.image.fridge_SmokedBacon()?.pngData()
        case .butterUnsalted:   return R.image.fridge_Butter()?.pngData()
        case .chickenFillet:    return R.image.fridge_ChickenFillet()?.pngData()
        case .frozenVegetables: return R.image.fridge_FrozenVegetables()?.pngData()
        case .frozenMushrooms:  return R.image.fridge_FrozenMushrooms()?.pngData()
        case .frozenBroccoli:   return R.image.fridge_FrozenBroccoli()?.pngData()
        }
    }
    
    var quantity: Double? {
        switch self {
        case .milk:             return 1
        case .mayonnaise:       return 1
        case .tomatoes:         return 10
        case .lettuce:          return 1
        case .creamCheese:      return nil
        case .parmesan:         return 250
        case .smokedBacon:      return 250
        case .butterUnsalted:   return 1
        case .chickenFillet:    return 1
        case .frozenVegetables: return 1
        case .frozenMushrooms:  return 1
        case .frozenBroccoli:   return nil
        }
    }
    
    var unitId: UnitSystem? {
        switch self {
        case .milk:             return .bottle
        case .mayonnaise:       return .can
        case .tomatoes:         return .piece
        case .lettuce:          return .piece
        case .creamCheese:      return nil
        case .parmesan:         return .gram
        case .smokedBacon:      return .gram
        case .butterUnsalted:   return .pack
        case .chickenFillet:    return .kilogram
        case .frozenVegetables: return .pack
        case .frozenMushrooms:  return .pack
        case .frozenBroccoli:   return nil
        }
    }
    
    var isAvailability: Bool {
        switch self {
        case .milk, .tomatoes, .parmesan, .butterUnsalted, .chickenFillet:
            return true
            
        default:
            return false
        }
    }
    
    var description: String? {
        switch self {
        case .creamCheese:      return nil
        case .frozenBroccoli:   return R.string.localizable.bigPack()
        default:
            var description = ""
            if let quantity = self.quantity {
                let quantityString = String(format: "%.\(quantity.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", quantity)
                description = quantityString
            }
            
            if let unit = self.unitId?.title {
                description += (description.isEmpty ? "" : " ") + "\(unit)"
            }
            
            return description.isEmpty ? nil : description
        }
    }
}

extension PantryDataSource.DefaultsGroceryStocks {
    var netProductId: Int? {
        switch self {
        case .oliveOil:             return 112537
        case .cannedCorn:           return nil
        case .spaghetti:            return 130568
        case .breakfastCereal:      return 130898 // просто злаки
        case .longShelfLifeMilk:    return nil
        case .groundCoffee:         return nil
        case .greenTeaBags:         return 112221 // просто челеный чай
        case .oatmeal:              return 130483
        case .honey:                return 130432
        case .tunaChunks:           return 112484 // Тунец в собственном соку (консервированный)
        case .eggs:                 return 130834
        case .wheatFlour:           return 130357
        }
    }
    
    var title: String {
        switch self {
        case .oliveOil:             return R.string.localizable.oliveOil()
        case .cannedCorn:           return R.string.localizable.cannedCorn()
        case .spaghetti:            return R.string.localizable.spaghetti()
        case .breakfastCereal:      return R.string.localizable.breakfastCereal()
        case .longShelfLifeMilk:    return R.string.localizable.longShelfLifeMilk()
        case .groundCoffee:         return R.string.localizable.groundCoffee()
        case .greenTeaBags:         return R.string.localizable.greenTeaBags()
        case .oatmeal:              return R.string.localizable.oatmealMediumSize()
        case .honey:                return R.string.localizable.honey()
        case .tunaChunks:           return R.string.localizable.tunaChunks()
        case .eggs:                 return R.string.localizable.eggs()
        case .wheatFlour:           return R.string.localizable.wheatFlour()
        }
    }
    
    var imageData: Data? {
        switch self {
        case .oliveOil:             return R.image.grocery_OliveOil()?.pngData()
        case .cannedCorn:           return R.image.grocery_CannedCorn()?.pngData()
        case .spaghetti:            return R.image.grocery_Spaghetti()?.pngData()
        case .breakfastCereal:      return R.image.grocery_Breakfast()?.pngData()
        case .longShelfLifeMilk:    return R.image.grocery_Long()?.pngData()
        case .groundCoffee:         return R.image.grocery_Ground()?.pngData()
        case .greenTeaBags:         return R.image.grocery_Green()?.pngData()
        case .oatmeal:              return R.image.grocery_Oatmeal()?.pngData()
        case .honey:                return R.image.grocery_Honey()?.pngData()
        case .tunaChunks:           return R.image.grocery_Tuna()?.pngData()
        case .eggs:                 return R.image.grocery_Eggs()?.pngData()
        case .wheatFlour:           return R.image.grocery_Wheat()?.pngData()
        }
    }
    
    var quantity: Double? {
        switch self {
        case .oliveOil:             return 2
        case .cannedCorn:           return 4
        case .spaghetti:            return 3
        case .breakfastCereal:      return 2
        case .longShelfLifeMilk:    return 4
        case .groundCoffee:         return 2
        case .greenTeaBags:         return 2
        case .oatmeal:              return 2
        case .honey:                return nil
        case .tunaChunks:           return 3
        case .eggs:                 return 20
        case .wheatFlour:           return 2
        }
    }
    
    var unitId: UnitSystem? {
        switch self {
        case .oliveOil:             return .bottle
        case .cannedCorn:           return .can
        case .spaghetti:            return .pack
        case .breakfastCereal:      return .pack
        case .longShelfLifeMilk:    return .pack
        case .groundCoffee:         return .pack
        case .greenTeaBags:         return .pack
        case .oatmeal:              return .pack
        case .honey:                return nil
        case .tunaChunks:           return .can
        case .eggs:                 return .piece
        case .wheatFlour:           return .kilogram
        }
    }
    
    var isAvailability: Bool {
        switch self {
        case .spaghetti, .breakfastCereal, .honey:
            return false
            
        default:
            return true
        }
    }
    
    var description: String? {
        switch self {
        case .honey:      return nil
        default:
            var description = ""
            if let quantity = self.quantity {
                let quantityString = String(format: "%.\(quantity.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", quantity)
                description = quantityString
            }
            
            if let unit = self.unitId?.title {
                description += (description.isEmpty ? "" : " ") + "\(unit)"
            }
            
            return description.isEmpty ? nil : description
        }
    }
}

extension PantryDataSource.DefaultsSpicesHerbsStocks {
    var netProductId: Int? {
        switch self {
        case .salt:     return 130418
        case .pepper:   return 130242
        case .garlic:   return nil // есть Чесночная приправа 130244
        case .chili:    return nil
        case .paprika:  return nil
        case .cinnamon: return 130274
        }
    }
    
    var title: String {
        switch self {
        case .salt:     return R.string.localizable.seaSalt()
        case .pepper:   return R.string.localizable.groundBlackPepper()
        case .garlic:   return R.string.localizable.garlicPowder()
        case .chili:    return R.string.localizable.redChiliFlakes()
        case .paprika:  return R.string.localizable.paprika()
        case .cinnamon: return R.string.localizable.cinnamon()
        }
    }

    var imageData: Data? {
        switch self {
        case .salt:     return R.image.spices_Sea()?.pngData()
        case .pepper:   return R.image.spices_Ground()?.pngData()
        case .garlic:   return R.image.spices_Garlic()?.pngData()
        case .chili:    return R.image.spices_Red()?.pngData()
        case .paprika:  return R.image.spices_Paprika()?.pngData()
        case .cinnamon: return R.image.spices_Cinnamon()?.pngData()
        }
    }
}

extension PantryDataSource.DefaultsBeautyHealthStocks {
    var netProductId: Int? {
        switch self {
        case .toiletPaper:  return 51
        case .cottonPads:   return 44
        case .cottonBuds:   return 45
        case .liquidSoap:   return 35
        case .toothpaste:   return 4
        case .showerGel:    return 36
        }
    }
    
    var title: String {
        switch self {
        case .toiletPaper:  return R.string.localizable.toiletPaper()
        case .cottonPads:   return R.string.localizable.cottonPads()
        case .cottonBuds:   return R.string.localizable.cottonBuds()
        case .liquidSoap:   return R.string.localizable.liquidSoap()
        case .toothpaste:   return R.string.localizable.toothpaste()
        case .showerGel:    return R.string.localizable.showerGel()
        }
    }

    var imageData: Data? {
        switch self {
        case .toiletPaper:  return R.image.beauty_Toilet()?.pngData()
        case .cottonPads:   return R.image.beauty_Cotton()?.pngData()
        case .cottonBuds:   return R.image.beauty_CottonBuds()?.pngData()
        case .liquidSoap:   return R.image.beauty_Liquid()?.pngData()
        case .toothpaste:   return R.image.beauty_Toothpaste()?.pngData()
        case .showerGel:    return R.image.beauty_Shower()?.pngData()
        }
    }
}

extension PantryDataSource.DefaultsHouseholdStocks{
    var netProductId: Int? {
        switch self {
        case .sponges:          return 9
        case .dishwashing:      return 8
        case .paperTowels:      return 10
        case .toiletPaper:      return 51
        case .trashBags:        return nil
        case .fabricSoftener:   return nil
        case .cleaningCloth:    return nil
        case .batteries:        return 18
        }
    }
    
    var title: String {
        switch self {
        case .sponges:          return R.string.localizable.kitchenScrubSponges()
        case .dishwashing:      return R.string.localizable.dishwashingLiquid()
        case .paperTowels:      return R.string.localizable.paperTowels()
        case .toiletPaper:      return R.string.localizable.toiletPaper()
        case .trashBags:        return R.string.localizable.trashBags()
        case .fabricSoftener:   return R.string.localizable.fabricSoftener()
        case .cleaningCloth:    return R.string.localizable.cleaningCloth()
        case .batteries:        return R.string.localizable.aaBatteries()
        }
    }

    var imageData: Data? {
        switch self {
        case .sponges:          return R.image.household_Kitchen()?.pngData()
        case .dishwashing:      return R.image.household_Dishwashing()?.pngData()
        case .paperTowels:      return R.image.household_Paper()?.pngData()
        case .toiletPaper:      return R.image.household_Toilet()?.pngData()
        case .trashBags:        return R.image.household_Trash()?.pngData()
        case .fabricSoftener:   return R.image.household_Fabric()?.pngData()
        case .cleaningCloth:    return R.image.household_Cleaning()?.pngData()
        case .batteries:        return R.image.household_AA()?.pngData()
        }
    }
    
    var isAvailability: Bool {
        switch self {
        case .trashBags, .batteries:
            return false
        default:
            return true
        }
    }
}
