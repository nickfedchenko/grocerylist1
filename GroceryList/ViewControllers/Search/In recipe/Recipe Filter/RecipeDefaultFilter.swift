//
//  RecipeDefaultFilter.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 06.07.2023.
//

import Foundation

struct Filter {
    let filter: RecipeFilter
    var tags: [RecipeTag]
}

protocol RecipeTag {
    var id: Int { get }
    var title: String { get }
    var isTag: Bool { get }
    var filter: RecipeFilter { get }
}

enum RecipeFilter: Int, CaseIterable {
    case exception
    case diet
    case typeOfDish
    case cookingMethod
    case caloriesPerServing
    case cookingTime
    case quantityOfIngredients
    
    var title: String {
        switch self {
        case .exception:                return "exception"
        case .diet:                     return "DIET"
        case .typeOfDish:               return "Type of dish"
        case .cookingMethod:            return "Cooking method"
        case .caloriesPerServing:       return "calories PER SERVING (KCAL)"
        case .cookingTime:              return "Cooking time (min)"
        case .quantityOfIngredients:    return "Quantity of ingredients"
        }
    }
    
    var tags: [RecipeTag] {
        switch self {
        case .exception:                return ExceptionFilter.allCases
        case .diet:                     return DietFilter.allCases
        case .typeOfDish:               return TypeOfDishFilter.allCases
        case .cookingMethod:            return CookingMethodFilter.allCases
        case .caloriesPerServing:       return CaloriesPerServingFilter.allCases
        case .cookingTime:              return CookingTimeFilter.allCases
        case .quantityOfIngredients:    return QuantityOfIngredientsFilter.allCases
        }
    }
}



enum ExceptionFilter: Int, RecipeTag, CaseIterable {
    case gluten = 3
    case peanuts = 2
    case eggs = 17
    case fish = 15
    case dairy = 9
    case treeNuts = 11
    case soy = 16
    case seafood = 10
    case honey = 18
    case meat = 4
    case poultry = 12
    case starchyVegetables = 8
    
    var id: Int {
        self.rawValue
    }
    
    var isTag: Bool {
        true
    }
    
    var filter: RecipeFilter {
        .exception
    }
    
    var title: String {
        switch self {
        case .gluten:               return "Gluten"
        case .peanuts:              return "Peanuts"
        case .eggs:                 return "Eggs"
        case .fish:                 return "Fish"
        case .dairy:                return "Dairy"
        case .treeNuts:             return "Tree Nuts"
        case .soy:                  return "Soy"
        case .seafood:              return "Seafood"
        case .honey:                return "Honey"
        case .meat:                 return "Meat"
        case .poultry:              return "Poultry"
        case .starchyVegetables:    return "Starchy vegetables"
        }
    }
}

enum DietFilter: Int, RecipeTag, CaseIterable {
    case lowCarb = 32
    case highProtein = 33
    case lowFat = 34
    case keto = 35
    case pescatarian = 38
    case vegetarian = 39
    case vegan = 40
    
    var id: Int {
        self.rawValue
    }
    
    var isTag: Bool {
        true
    }
    
    var filter: RecipeFilter {
        .diet
    }
    
    var title: String {
        switch self {
        case .lowCarb:      return "Low carb"
        case .highProtein:  return "High protein"
        case .lowFat:       return "Low fat"
        case .keto:         return "Keto"
        case .pescatarian:  return "Pescatarian"
        case .vegetarian:   return "Vegetarian"
        case .vegan:        return "Vegan"
        }
    }
}

enum TypeOfDishFilter: Int, RecipeTag, CaseIterable {
    case salad = 13
    case sideDish = 12
    case soup = 14
    case beverage = 15
    case pizza = 18
    case bakeryProducts = 16
    case sandwich = 17
    case appetizer = 19
    case sauce = 42
    case dessert = 46
    
    var id: Int {
        self.rawValue
    }
    
    var isTag: Bool {
        true
    }
    
    var filter: RecipeFilter {
        .typeOfDish
    }
    
    var title: String {
        switch self {
        case .salad:            return "Salad"
        case .sideDish:         return "Side Dish"
        case .soup:             return "Soup"
        case .beverage:         return "Beverage"
        case .pizza:            return "Pizza"
        case .bakeryProducts:   return "Bakery products"
        case .sandwich:         return "Sandwich"
        case .appetizer:        return "Appetizer"
        case .sauce:            return "Sauce"
        case .dessert:          return "Dessert"
        }
    }
}

enum CookingMethodFilter: Int, RecipeTag, CaseIterable {
    case withoutHeatTreatment = 20
    case boil = 21
    case bake = 22
    case steam = 23
    case fry = 24
    case stew = 25
    case microwave = 26
    case onTheCoals = 27
    case deepFrying = 41
    case sousVide = 43
    case airFryer = 44
    case multicooker = 45
    
    var id: Int {
        self.rawValue
    }
    
    var isTag: Bool {
        true
    }
    
    var filter: RecipeFilter {
        .cookingMethod
    }
    
    var title: String {
        switch self {
        case .withoutHeatTreatment: return "Without heat treatment"
        case .boil:                 return "Boil"
        case .bake:                 return "Bake"
        case .steam:                return "Steam"
        case .fry:                  return "Fry"
        case .stew:                 return "Stew"
        case .microwave:            return "Microwave"
        case .onTheCoals:           return "On the coals"
        case .deepFrying:           return "Deep frying"
        case .sousVide:             return "Sous vide"
        case .airFryer:             return "Air Fryer"
        case .multicooker:          return "Multicooker"
        }
    }
}

enum CaloriesPerServingFilter: Int, RecipeTag, CaseIterable {
    case from50To100
    case from100To200
    case from200To300
    case from300To400
    case from400To500
    case from500To600
    case from600To700
    case from700
    
    var id: Int {
        self.rawValue
    }
    
    var isTag: Bool {
        false
    }
    
    var filter: RecipeFilter {
        .caloriesPerServing
    }
    
    var title: String {
        switch self {
        case .from50To100:  return "50...100"
        case .from100To200: return "100...200"
        case .from200To300: return "200...300"
        case .from300To400: return "300...400"
        case .from400To500: return "400...500"
        case .from500To600: return "500...600"
        case .from600To700: return "600...700"
        case .from700:      return "700 +"
        }
    }
    
    var minMaxValue: (min: Int, max: Int) {
        switch self {
        case .from50To100:  return (50, 100)
        case .from100To200: return (100, 200)
        case .from200To300: return (200, 300)
        case .from300To400: return (300, 400)
        case .from400To500: return (400, 500)
        case .from500To600: return (500, 600)
        case .from600To700: return (600, 700)
        case .from700:      return (700, 10000)
        }
    }
}

enum CookingTimeFilter: Int, RecipeTag, CaseIterable {
    case time10OrLess
    case time15OrLess
    case time20OrLess
    case time25OrLess
    case time30OrLess
    case time40OrLess
    case time50OrLess
    case time60OrLess
    
    var id: Int {
        self.rawValue
    }
    
    var isTag: Bool {
        false
    }
    
    var filter: RecipeFilter {
        .cookingTime
    }
    
    var title: String {
        switch self {
        case .time10OrLess: return "10 or less"
        case .time15OrLess: return "15 or less"
        case .time20OrLess: return "20 or less"
        case .time25OrLess: return "25 or less"
        case .time30OrLess: return "30 or less"
        case .time40OrLess: return "40 or less"
        case .time50OrLess: return "50 or less"
        case .time60OrLess: return "60 or less"
        }
    }
    
    var maxTime: Int {
        switch self {
        case .time10OrLess: return 10
        case .time15OrLess: return 15
        case .time20OrLess: return 20
        case .time25OrLess: return 25
        case .time30OrLess: return 30
        case .time40OrLess: return 40
        case .time50OrLess: return 50
        case .time60OrLess: return 60
        }
    }
}

enum QuantityOfIngredientsFilter: Int, RecipeTag, CaseIterable {
    case ingredients3OrLess
    case ingredients4OrLess
    case ingredients5OrLess
    case ingredients6OrLess
    case ingredients7OrLess
    case ingredients8OrLess
    case ingredients9OrLess
    case ingredients10OrLess
    
    var id: Int {
        self.rawValue
    }
    
    var isTag: Bool {
        false
    }
    
    var filter: RecipeFilter {
        .quantityOfIngredients
    }
    
    var title: String {
        switch self {
        case .ingredients3OrLess:   return "3 or less"
        case .ingredients4OrLess:   return "4 or less"
        case .ingredients5OrLess:   return "5 or less"
        case .ingredients6OrLess:   return "6 or less"
        case .ingredients7OrLess:   return "7 or less"
        case .ingredients8OrLess:   return "8 or less"
        case .ingredients9OrLess:   return "9 or less"
        case .ingredients10OrLess:  return "10 or less"
        }
    }
    
    var maxIngredients: Int {
        switch self {
        case .ingredients3OrLess:   return 3
        case .ingredients4OrLess:   return 4
        case .ingredients5OrLess:   return 5
        case .ingredients6OrLess:   return 6
        case .ingredients7OrLess:   return 7
        case .ingredients8OrLess:   return 8
        case .ingredients9OrLess:   return 9
        case .ingredients10OrLess:  return 10
        }
    }
}

