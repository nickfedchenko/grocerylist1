//
//  KeychainManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 16.02.2023.
//

import Foundation

class KeyChainManager {
    enum AuthState: String {
        case email = "emailForAuth"
        case password = "passwordForAuth"
    }
   
    @discardableResult
    class func save(key: AuthState, data: Data) -> OSStatus {
        var query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key.rawValue,
            kSecValueData as String   : data ] as [String : Any]
        query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: AuthState) -> Data? {
        var query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key.rawValue,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
        query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        var dataTypeRef: AnyObject?

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
}
