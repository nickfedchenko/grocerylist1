//
//  RegistrationResponse.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 06.02.2023.
//

import Foundation

struct RegistrationResponse: Codable {
    var error: Bool?
    var messages: [String]?
    var user: User?
}

struct User: Codable {
    var id: Int?
    var userName: String?
    var avatar: String?
    var email: String?
    var token: String?
    var isConfirmed: Bool?
    var password: String?
    var avatarAsData: Data?
    
    enum CodingKeys: String, CodingKey {
        case id, userName, avatar, email, token, isConfirmed = "is_confirmed", password
    }
    
}

struct ChangeUsernameResponse: Codable {
    var error: Bool
    var messages: [String]
    var sucsess: Bool
}

struct MailExistResponse: Codable {
    var error: Bool
    var messages: [String]
    var isExist: Bool
    
    enum CodingKeys: String, CodingKey {
        case error, messages, isExist = "is_exists"
    }
}


struct ResendVerificationResponse: Codable {
    var error: Bool
    var messages: [String]
    var status: String?
}
