//
//  KeychainManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 16.02.2023.
//
public let kSecAccountsContainerServiceKey = "com.accounts.container"
import Foundation
enum KeychainErrorDomain: Error {
    case failedToEncodeSensitiveData
    case errorRetrievingSensitivedata
    case noCridentialsSavedForProvidedUser
    case failedToDecodeSensitiveData
    
    var description: String {
        switch self {
        case .failedToEncodeSensitiveData:
            return "Error serializating email/password pair"
        case .errorRetrievingSensitivedata:
            return "Error getting data"
        case .noCridentialsSavedForProvidedUser:
            return "There is now technical problems, just nothing saved"
        case .failedToDecodeSensitiveData:
            return "Got some data, but cannot properly decode it"
        }
    }
}

class KeyChainManager {
    enum AuthState: String {
        case email = "emailForAuth"
        case password = "passwordForAuth"
    }
    
    @available(*, deprecated, message: "Use saveCridentials(password: String, userID: String, e-mail: String) instead")
    class func save(password: Data, appleId: String, email: String) -> OSStatus {
        var query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrService as String : appleId,
            kSecAttrAccount as String : email,
            kSecValueData as String   : password] as [String : Any]
        query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }

    @available(*, deprecated, message: "Use loadCridentials(userID : String) -> Result<[String: String], KeychainErrorDomain> instead")
    class func load(appleId: String, email: String) -> Data? {
        var query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : appleId,
            kSecAttrAccount as String : email,
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
    
    class func loadCridentials(userID : String) -> Result<[String: String], KeychainErrorDomain> {
        var query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : kSecAccountsContainerServiceKey,
            kSecAttrAccount as String : userID,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
        query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        var dataTypeRef: AnyObject?

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            guard
                let data = dataTypeRef as? Data,
                let deserializedData: [String: String] = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
                return .failure(.errorRetrievingSensitivedata)
            }
            return .success(deserializedData)
        } else {
            return.failure(.errorRetrievingSensitivedata)
        }
    }
    
    class func saveCridentials(password: String, userdID: String, email: String) -> Result<OSStatus, KeychainErrorDomain> {
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        
        guard  let encodedData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            return .failure(.failedToEncodeSensitiveData)
        }
        var query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrService as String : kSecAccountsContainerServiceKey,
            kSecAttrAccount as String : userdID,
            kSecValueData as String   : encodedData
        ] as [String : Any]
        query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        SecItemDelete(query as CFDictionary)

        return .success(SecItemAdd(query as CFDictionary, nil))
    }
    
    class func deletePassword(key: AuthState) -> OSStatus {
        let query: [String: Any] = [
            kSecAttrAccount as String : key.rawValue,
            kSecClass as String       : kSecClassGenericPassword
        ]
        
        return SecItemDelete(query as CFDictionary)
    }
    
    class func migrateOldCridentialsIfNeeded(for appleID: String) {
        guard
            let emailData = load(key: .email),
            let email = String(data: emailData, encoding: .utf8),
            let passwordData = load(key: .password),
            let password = String(data: passwordData, encoding: .utf8) else {
            return
        }
        _ = saveCridentials(password: password, userdID: appleID, email: email)
        _ = deletePassword(key: .email)
        _ = deletePassword(key: .password)
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
