//
//  NumberExtensions.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.02.2023.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Int {
    var asString: String {
        return "\(self)"
    }
    
    var asInt64: Int64 {
        Int64(self)
    }
    
    var asUUID: UUID {
        var number = self
        let numberData = Data(bytes: &number, count: MemoryLayout<Int64>.size)

        let bytes = [UInt8](numberData)

        let tuple: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0,
                             bytes[0], bytes[1], bytes[2], bytes[3],
                             bytes[4], bytes[5], bytes[6], bytes[7])
        return UUID(uuid: tuple)
    }
}

extension Double {
    var asString: String {
        return String(format: "%.\(self.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", self)
    }
    
    var asInt: Int {
        return Int(self)
    }
}

extension Int64 {
    var uuid: UUID {
        var number = self
        let numberData = Data(bytes: &number, count: MemoryLayout<Int64>.size)

        let bytes = [UInt8](numberData)

        let tuple: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0,
                             bytes[0], bytes[1], bytes[2], bytes[3],
                             bytes[4], bytes[5], bytes[6], bytes[7])
        return UUID(uuid: tuple)
    }
    
    var boolValue: Bool {
        self > 0
    }
    
    var asInt: Int {
        Int(self)
    }
}

extension Bool {
    var asInt64: Int64 {
        return self == true ? 1 : 0
    }
}
