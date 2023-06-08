//
//  ColorManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

struct Theme: Hashable {
    var dark: UIColor
    var medium: UIColor
    var light: UIColor
}

class ColorManager {
    
    static var shared = ColorManager()
    
    private let rawGradientColors: [Theme] = [
        Theme(dark: UIColor(hex: "#6F8617"), medium: UIColor(hex: "#A5B957"), light: UIColor(hex: "#FCFFF3")), // 0 - 9
        Theme(dark: UIColor(hex: "#278337"), medium: UIColor(hex: "#58B168"), light: UIColor(hex: "#F4FFF6")), // 1 - 1
        Theme(dark: UIColor(hex: "#007474"), medium: UIColor(hex: "#35A7A7"), light: UIColor(hex: "#F2FFFF")), // 2 - 5
        Theme(dark: UIColor(hex: "#587557"), medium: UIColor(hex: "#86A385"), light: UIColor(hex: "#F2F8F2")), // 3 - 12
        Theme(dark: UIColor(hex: "#92550B"), medium: UIColor(hex: "#EE982F"), light: UIColor(hex: "#FFF6EA")), // 4 - 2
        Theme(dark: UIColor(hex: "#C64E0A"), medium: UIColor(hex: "#E88E5C"), light: UIColor(hex: "#FFF6F0")), // 5 - 6
        Theme(dark: UIColor(hex: "#A12B1B"), medium: UIColor(hex: "#EF7463"), light: UIColor(hex: "#FFF2F0")), // 6 - 4
        Theme(dark: UIColor(hex: "#AE182B"), medium: UIColor(hex: "#E45366"), light: UIColor(hex: "#FFF0F2")), // 7 - 8
        Theme(dark: UIColor(hex: "#9B2789"), medium: UIColor(hex: "#CA5DB8"), light: UIColor(hex: "#FFF7FE")), // 8 - 10
        Theme(dark: UIColor(hex: "#0F5B99"), medium: UIColor(hex: "#4E98D4"), light: UIColor(hex: "#F0F8FF")), // 9 - 3
        Theme(dark: UIColor(hex: "#196F8A"), medium: UIColor(hex: "#46A5C3"), light: UIColor(hex: "#EDF7FB")), // 10 - 18
        Theme(dark: UIColor(hex: "#304099"), medium: UIColor(hex: "#6C7AC8"), light: UIColor(hex: "#F4F6FF")), // 11 - 7
        Theme(dark: UIColor(hex: "#5A33AE"), medium: UIColor(hex: "#8667C7"), light: UIColor(hex: "#F7F4FF")), // 12 - 11
        Theme(dark: UIColor(hex: "#3C6E77"), medium: UIColor(hex: "#6597A0"), light: UIColor(hex: "#F2F7F8")), // 13 - 17
        Theme(dark: UIColor(hex: "#635057"), medium: UIColor(hex: "#A19096"), light: UIColor(hex: "#FBF9FB")), // 14 - 14
        Theme(dark: UIColor(hex: "#595959"), medium: UIColor(hex: "#9B9B9B"), light: UIColor(hex: "#F3F3F3")), // 15 - 15
        Theme(dark: UIColor(hex: "#5C6E73"), medium: UIColor(hex: "#95A7AC"), light: UIColor(hex: "#F7F9FC")), // 16 - 16
        Theme(dark: UIColor(hex: "#66493C"), medium: UIColor(hex: "#95776A"), light: UIColor(hex: "#FFFBF9"))  // 17 - 13
    ]
    
    private let emptyCellColors: [UIColor] = [
        #colorLiteral(red: 0.87116611, green: 0.9110933542, blue: 0.910405457, alpha: 1), #colorLiteral(red: 0.8280456662, green: 0.9286016822, blue: 0.9183422923, alpha: 1), #colorLiteral(red: 0.8989184499, green: 0.8939521909, blue: 0.8940405846, alpha: 1)
    ]
    
    var gradientsCount: Int {
        rawGradientColors.count
    }
    
    func getGradient(index: Int) -> Theme {
        guard index < gradientsCount else {
            return Theme(dark: .white, medium: .white, light: .white)
        }
        return rawGradientColors[index]
    }
    
    func getEmptyCellColor(index: Int) -> UIColor {
        guard index < emptyCellColors.count else {
            return UIColor.white
        }
        return emptyCellColors[index]
    }
    
}
