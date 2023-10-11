//
//  StringExtension.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import UIKit

extension String {
    var localized: String {
        let value = NSLocalizedString(self, comment: "")
        if value != self || NSLocale.preferredLanguages.first == "en" {
            return value
        }
        
        guard
            let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
            let bundle = Bundle(path: path)
        else { return value }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    
    var asInt: Int? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self)?.intValue
    }
    
    var asDouble: Double? {
        let newStr = self.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
        return Double(newStr)
    }
    
    func toDate(withFormat format: String = "dd.MM.yyyy HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
}

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
    
    func firstCharacterUpperCase() -> String {
        if self.count == 0 { return self }
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
    
    func attributed(font: UIFont, color: UIColor) -> NSMutableAttributedString {
        NSMutableAttributedString(string: self, attributes: [.font: font, .foregroundColor: color])
    }
}

extension String {
    func getTitleWithout(symbols: [String]) -> String {
        var result: String = self
        symbols.forEach {
            result = result.replacingOccurrences(of: $0, with: "")
        }
        return result
    }
    
    func smartContains(_ other: String) -> Bool {
        let array : [String] = other.lowercased().components(separatedBy: " ").filter { !$0.isEmpty }
        return array.allSatisfy { (self.lowercased().range(of: $0) != nil) }
    }
    
    func prepareForSearch() -> String {
        return self.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).getTitleWithout(symbols: ["(", ")"])
    }
}
