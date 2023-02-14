//
//  RegistrationResponse.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 06.02.2023.
//

import Foundation

struct CreateUserResponse: Codable {
    var error: Bool
    var messages: [String]
    var user: User
}

struct LogInResponse: Codable {
    var error: Bool
    var messages: [String]
    var user: User?
}

struct User: Codable {
    var id: Int
    var userName: String?
    var avatar: String?
    var email: String
    var token: String
    var password: String?
    var avatarAsData: Data?
    var passwordResetToken: String?
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

struct PasswordResetResponse: Codable {
    var error: Bool
    var messages: [String]
    var result: PasswordResetStatus
}

struct PasswordResetStatus: Codable {
    var status: String
    var passwordResetToken: String
    var dateOfTokenExpiration: String
    
    enum CodingKeys: String, CodingKey {
        case status, passwordResetToken = "password_reset_token", dateOfTokenExpiration = "password_reset_token_expired_at"
    }
}

struct PasswordUpdateResponse: Codable {
    var error: Bool
    var messages: [String]
    var user: User?
}

struct UpdateUsernameResponse: Codable {
    var error: Bool
    var messages: [String]
    var user: User?
}

struct UploadAvatarResponse: Codable {
    var error: Bool
    var messages: [String]
    var user: User?
}

struct DeleteUserResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
}
