//
//  UUIDExtension.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

extension UUID {
    // UUID is 128-bit, we need two 64-bit values to represent it
    var integer: (Int) {
        var uuid: UInt64 = 0
        uuid |= UInt64(self.uuid.0)
        uuid |= UInt64(self.uuid.1) << 8
        uuid |= UInt64(self.uuid.2) << (8 * 2)
        uuid |= UInt64(self.uuid.3) << (8 * 3)
        uuid |= UInt64(self.uuid.4) << (8 * 4)
        uuid |= UInt64(self.uuid.5) << (8 * 5)
        uuid |= UInt64(self.uuid.6) << (8 * 6)
        uuid |= UInt64(self.uuid.7) << (8 * 7)
        
        return (Int(Int64(bitPattern: uuid)))
    }
}
