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
        case .exception:                return R.string.localizable.exception()
        case .diet:                     return R.string.localizable.diet()
        case .typeOfDish:               return R.string.localizable.typeOfDish()
        case .cookingMethod:            return R.string.localizable.cookingMethod()
        case .caloriesPerServing:       return R.string.localizable.caloriesPerServingKcal()
        case .cookingTime:              return R.string.localizable.cookingTimeMin()
        case .quantityOfIngredients:    return R.string.localizable.quantityOfIngredients()
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
    case gluten             = 3
    case peanuts            = 2
    case eggs               = 17
    case fish               = 15
    case dairy              = 9
    case treeNuts           = 11
    case soy                = 16
    case seafood            = 10
    case honey              = 18
    case meat               = 4
    case poultry            = 12
    case starchyVegetables  = 8
    
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
        case .gluten:               return R.string.localizable.gluten()
        case .peanuts:              return R.string.localizable.peanuts()
        case .eggs:                 return R.string.localizable.eggs()
        case .fish:                 return R.string.localizable.fish()
        case .dairy:                return R.string.localizable.dairy()
        case .treeNuts:             return R.string.localizable.treeNuts()
        case .soy:                  return R.string.localizable.soy()
        case .seafood:              return R.string.localizable.seafood()
        case .honey:                return R.string.localizable.honey()
        case .meat:                 return R.string.localizable.meat()
        case .poultry:              return R.string.localizable.poultry()
        case .starchyVegetables:    return R.string.localizable.starchyVegetables()
        }
    }
}

enum DietFilter: Int, RecipeTag, CaseIterable {
    case lowCarb        = 32
    case highProtein    = 33
    case lowFat         = 34
    case keto           = 35
    case pescatarian    = 38
    case vegetarian     = 39
    case vegan          = 40
    
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
        case .lowCarb:      return R.string.localizable.lowCarb()
        case .highProtein:  return R.string.localizable.highProtein()
        case .lowFat:       return R.string.localizable.lowFat()
        case .keto:         return R.string.localizable.keto()
        case .pescatarian:  return R.string.localizable.pescatarian()
        case .vegetarian:   return R.string.localizable.vegetarian()
        case .vegan:        return R.string.localizable.vegan()
        }
    }
}

enum TypeOfDishFilter: Int, RecipeTag, CaseIterable {
    case salad          = 13
    case sideDish       = 12
    case soup           = 14
    case beverage       = 15
    case pizza          = 18
    case bakeryProducts = 16
    case sandwich       = 17
    case appetizer      = 19
    case sauce          = 42
    case dessert        = 46
    
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
        case .salad:            return R.string.localizable.salad()
        case .sideDish:         return R.string.localizable.sideDish()
        case .soup:             return R.string.localizable.soup()
        case .beverage:         return R.string.localizable.beverage()
        case .pizza:            return R.string.localizable.pizza()
        case .bakeryProducts:   return R.string.localizable.bakeryProducts()
        case .sandwich:         return R.string.localizable.sandwich()
        case .appetizer:        return R.string.localizable.appetizer()
        case .sauce:            return R.string.localizable.sauce()
        case .dessert:          return R.string.localizable.dessert()
        }
    }
}

enum CookingMethodFilter: Int, RecipeTag, CaseIterable {
    case withoutHeatTreatment   = 20
    case boil                   = 21
    case bake                   = 22
    case steam                  = 23
    case fry                    = 24
    case stew                   = 25
    case microwave              = 26
    case onTheCoals             = 27
    case deepFrying             = 41
    case sousVide               = 43
    case airFryer               = 44
    case multicooker            = 45
    
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
        case .withoutHeatTreatment: return R.string.localizable.withoutHeatTreatment()
        case .boil:                 return R.string.localizable.boil()
        case .bake:                 return R.string.localizable.bake()
        case .steam:                return R.string.localizable.steam()
        case .fry:                  return R.string.localizable.fry()
        case .stew:                 return R.string.localizable.stew()
        case .microwave:            return R.string.localizable.microwave()
        case .onTheCoals:           return R.string.localizable.onTheCoals()
        case .deepFrying:           return R.string.localizable.deepFrying()
        case .sousVide:             return R.string.localizable.sousVide()
        case .airFryer:             return R.string.localizable.airFryer()
        case .multicooker:          return R.string.localizable.multicooker()
        }
    }
}

enum CaloriesPerServingFilter: Int, RecipeTag, CaseIterable {
    case from50To100    = -101
    case from100To200   = -102
    case from200To300   = -103
    case from300To400   = -104
    case from400To500   = -105
    case from500To600   = -106
    case from600To700   = -107
    case from700        = -108
    
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
    case time10OrLess   = -111
    case time15OrLess   = -112
    case time20OrLess   = -113
    case time25OrLess   = -114
    case time30OrLess   = -115
    case time40OrLess   = -116
    case time50OrLess   = -117
    case time60OrLess   = -118
    
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
        case .time10OrLess: return R.string.localizable.orLess("10")
        case .time15OrLess: return R.string.localizable.orLess("15")
        case .time20OrLess: return R.string.localizable.orLess("20")
        case .time25OrLess: return R.string.localizable.orLess("25")
        case .time30OrLess: return R.string.localizable.orLess("30")
        case .time40OrLess: return R.string.localizable.orLess("40")
        case .time50OrLess: return R.string.localizable.orLess("50")
        case .time60OrLess: return R.string.localizable.orLess("60")
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
    case ingredients3OrLess     = -121
    case ingredients4OrLess     = -122
    case ingredients5OrLess     = -123
    case ingredients6OrLess     = -124
    case ingredients7OrLess     = -125
    case ingredients8OrLess     = -126
    case ingredients9OrLess     = -127
    case ingredients10OrLess    = -128
    
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
        case .ingredients3OrLess:   return R.string.localizable.orLess("3")
        case .ingredients4OrLess:   return R.string.localizable.orLess("4")
        case .ingredients5OrLess:   return R.string.localizable.orLess("5")
        case .ingredients6OrLess:   return R.string.localizable.orLess("6")
        case .ingredients7OrLess:   return R.string.localizable.orLess("7")
        case .ingredients8OrLess:   return R.string.localizable.orLess("8")
        case .ingredients9OrLess:   return R.string.localizable.orLess("9")
        case .ingredients10OrLess:  return R.string.localizable.orLess("10")
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
