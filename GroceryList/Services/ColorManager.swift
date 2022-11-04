//
//  ColorManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

class ColorManager {
    
    static var shared = ColorManager()
    
    private let rawGradientColors: [(UIColor, UIColor)] = [
        (#colorLiteral(red: 0.5964680314, green: 0.6769827008, blue: 0.262544632, alpha: 1), #colorLiteral(red: 0.9746959805, green: 0.9846407771, blue: 0.9152638316, alpha: 1)), (#colorLiteral(red: 0.3484649658, green: 0.7023465037, blue: 0.4103045464, alpha: 1), #colorLiteral(red: 0.9467965961, green: 1, blue: 0.9576880336, alpha: 1)), (#colorLiteral(red: 0.2056294382, green: 0.6560960412, blue: 0.6127375364, alpha: 1), #colorLiteral(red: 0.9125298858, green: 0.9826145768, blue: 0.9771273732, alpha: 1)), (#colorLiteral(red: 0.4845610261, green: 0.6276196241, blue: 0.4771710634, alpha: 1), #colorLiteral(red: 0.9662304521, green: 1, blue: 0.9660263658, alpha: 1)),
        (#colorLiteral(red: 0.8959152102, green: 0.5820475221, blue: 0.1992429197, alpha: 1), #colorLiteral(red: 0.9925770164, green: 0.9677901864, blue: 0.9466624856, alpha: 1)), (#colorLiteral(red: 0.9137657881, green: 0.54308635, blue: 0.3368409872, alpha: 1), #colorLiteral(red: 0.984182775, green: 0.9396517873, blue: 0.91455549, alpha: 1)), (#colorLiteral(red: 0.9685983062, green: 0.4218371511, blue: 0.3666750193, alpha: 1), #colorLiteral(red: 0.9889338613, green: 0.9394780397, blue: 0.9360722899, alpha: 1)), (#colorLiteral(red: 0.9077350497, green: 0.2906029224, blue: 0.3712849617, alpha: 1), #colorLiteral(red: 0.9992346168, green: 0.9350280762, blue: 0.9491462111, alpha: 1)), (#colorLiteral(red: 0.7740916014, green: 0.3520812988, blue: 0.7029502988, alpha: 1), #colorLiteral(red: 0.98250705, green: 0.9478417039, blue: 0.9785855412, alpha: 1)),
        (#colorLiteral(red: 0.2915844321, green: 0.5553463697, blue: 0.7754161358, alpha: 1), #colorLiteral(red: 0.9396953583, green: 0.9696019292, blue: 0.9948672652, alpha: 1)), (#colorLiteral(red: 0.280202508, green: 0.6593298912, blue: 0.7820600867, alpha: 1), #colorLiteral(red: 0.9086049199, green: 0.9786931872, blue: 0.9989845157, alpha: 1)), (#colorLiteral(red: 0.352160573, green: 0.4700081348, blue: 0.7707169652, alpha: 1), #colorLiteral(red: 0.9210007191, green: 0.9459127784, blue: 1, alpha: 1)), (#colorLiteral(red: 0.5589365959, green: 0.3514359593, blue: 0.7729610205, alpha: 1), #colorLiteral(red: 0.9612006545, green: 0.9364186525, blue: 0.9884141088, alpha: 1)), (#colorLiteral(red: 0.3956821561, green: 0.5934939384, blue: 0.629126668, alpha: 1), #colorLiteral(red: 0.927007854, green: 0.9619172215, blue: 0.9656152129, alpha: 1)),
        (#colorLiteral(red: 0.617266953, green: 0.4520972371, blue: 0.5074846148, alpha: 1), #colorLiteral(red: 0.9446584582, green: 0.9248225093, blue: 0.9337915778, alpha: 1)), (#colorLiteral(red: 0.5423686504, green: 0.5127075911, blue: 0.6284357905, alpha: 1), #colorLiteral(red: 0.9302908182, green: 0.9253249764, blue: 0.9383242726, alpha: 1)), (#colorLiteral(red: 0.4553088546, green: 0.4953843355, blue: 0.5247161388, alpha: 1), #colorLiteral(red: 0.9541888833, green: 0.9691187739, blue: 0.9817628264, alpha: 1)), (#colorLiteral(red: 0.5462152362, green: 0.4677112699, blue: 0.4301403165, alpha: 1), #colorLiteral(red: 0.9502868056, green: 0.9205604196, blue: 0.9081587791, alpha: 1))
    ]
    
    var gradientsCount: Int {
        rawGradientColors.count
    }
    
    func getGradient(index: Int) -> (UIColor, UIColor) {
        guard index < gradientsCount else { return (UIColor.white, UIColor.white) }
        
        return rawGradientColors[index]
    }
    
    func getIndex(gradient: (UIColor, UIColor)) -> Int? {
        rawGradientColors.firstIndex(where: { $0.0 == gradient.0 && $0.1 == gradient.1 })
    }
    
}
