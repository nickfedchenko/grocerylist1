//
//  RecipeWebsites.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 31.07.2023.
//

import Foundation

enum RecipeWebsite: CaseIterable {
    case twelveTomatoes
    case allrecipes
    case bbcGoodFood
    case blissfulBasil
    case cookingClassy
    case damnDelicious
    case delish
    case dietDoctor
    case eatingWell
    case epicurious
    case foodNetwork
    case gypsyplate
    case iowaGirlEats
    case izzycooking
    case lowCarbYum
    case marthaStewart
    case myFitnessPalBlog
    case myRecipes
    case naturallyElla
    case newYorkTimesCooking
    case ohSheGlows
    case ruledMe
    case sallysBakingRecipes
    case saveur
    case seriousEats
    case simplyRecipes
    case skinnytaste
    case smittenKitchen
    case tasteOfHome
    case tasty
    case tastyKitchen
    case theGirlWhoAteEverything
    case thePioneerWoman
    case wholeSomeYam
    
    var title: String {
        switch self {
        case .twelveTomatoes:           return "12 Tomatoes"
        case .allrecipes:               return "Allrecipes"
        case .bbcGoodFood:              return "BBC Good Food"
        case .blissfulBasil:            return "Blissful Basil"
        case .cookingClassy:            return "Cooking Classy"
        case .damnDelicious:            return "Damn Delicious"
        case .delish:                   return "Delish"
        case .dietDoctor:               return "Diet Doctor"
        case .eatingWell:               return "EatingWell"
        case .epicurious:               return "Epicurious"
        case .foodNetwork:              return "Food Network"
        case .gypsyplate:               return "Gypsyplate"
        case .iowaGirlEats:             return "Iowa Girl Eats"
        case .izzycooking:              return "Izzycooking"
        case .lowCarbYum:               return "LowCarbYum"
        case .marthaStewart:            return "Martha Stewart"
        case .myFitnessPalBlog:         return "MyFitnessPal Blog"
        case .myRecipes:                return "MyRecipes"
        case .naturallyElla:            return "Naturally Ella"
        case .newYorkTimesCooking:      return "New York Times Cooking"
        case .ohSheGlows:               return "Oh She Glows"
        case .ruledMe:                  return "Ruled.me"
        case .sallysBakingRecipes:      return "Sally's Baking Recipes"
        case .saveur:                   return "Saveur"
        case .seriousEats:              return "Serious Eats"
        case .simplyRecipes:            return "Simply Recipes"
        case .skinnytaste:              return "Skinnytaste"
        case .smittenKitchen:           return "Smitten Kitchen"
        case .tasteOfHome:              return "Taste of Home"
        case .tasty:                    return "Tasty"
        case .tastyKitchen:             return "Tasty Kitchen"
        case .theGirlWhoAteEverything:  return "The Girl Who Ate Everything"
        case .thePioneerWoman:          return "The Pioneer Woman"
        case .wholeSomeYam:             return "WholeSome Yam"
        }
    }
    
    var urlString: String {
        switch self {
        case .twelveTomatoes:           return "https://12tomatoes.com"
        case .allrecipes:               return "https://www.allrecipes.com"
        case .bbcGoodFood:              return "https://www.bbcgoodfood.com"
        case .blissfulBasil:            return "https://www.blissfulbasil.com"
        case .cookingClassy:            return "https://www.cookingclassy.com"
        case .damnDelicious:            return "https://damndelicious.net"
        case .delish:                   return "https://www.delish.com"
        case .dietDoctor:               return "https://www.dietdoctor.com"
        case .eatingWell:               return "https://www.eatingwell.com"
        case .epicurious:               return "https://www.epicurious.com"
        case .foodNetwork:              return "https://www.foodnetwork.com"
        case .gypsyplate:               return "https://gypsyplate.com"
        case .iowaGirlEats:             return "https://iowagirleats.com"
        case .izzycooking:              return "https://izzycooking.com"
        case .lowCarbYum:               return "https://lowcarbyum.com/recipes"
        case .marthaStewart:            return "https://www.marthastewart.com"
        case .myFitnessPalBlog:         return "https://blog.myfitnesspal.com/category/eat/recipes"
        case .myRecipes:                return "https://www.myrecipes.com"
        case .naturallyElla:            return "https://naturallyella.com"
        case .newYorkTimesCooking:      return "https://cooking.nytimes.com"
        case .ohSheGlows:               return "https://ohsheglows.com"
        case .ruledMe:                  return "https://www.ruled.me"
        case .sallysBakingRecipes:      return "https://sallysbakingaddiction.com"
        case .saveur:                   return "https://www.saveur.com"
        case .seriousEats:              return "https://www.seriouseats.com"
        case .simplyRecipes:            return "https://www.simplyrecipes.com"
        case .skinnytaste:              return "https://www.skinnytaste.com"
        case .smittenKitchen:           return "https://smittenkitchen.com"
        case .tasteOfHome:              return "https://www.tasteofhome.com"
        case .tasty:                    return "https://tasty.co"
        case .tastyKitchen:             return "https://tastykitchen.com"
        case .theGirlWhoAteEverything:  return "https://www.the-girl-who-ate-everything.com"
        case .thePioneerWoman:          return "https://www.thepioneerwoman.com"
        case .wholeSomeYam:             return "https://www.wholesomeyum.com"
        }
    }
}
