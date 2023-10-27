//
//  NetworkModeles.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 29.11.2022.
//

import Foundation

struct GetAllProductsResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [NetworkProductModel]
}

struct GetAllItemsResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [NetworkProductModel]
}

struct GetCategoriesResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [NetworkCategory]
}

// MARK: - Category
struct NetworkCategory: Codable {
    let id: Int
    let title: String
    var netId: String?
}

// MARK: - Продукты пользователя
struct UserProduct: Codable {
    let userToken: String
    let country: String?
    let lang: String?
    let modelType: String?
    let modelId: String?
    let modelTitle: String
    let categoryId: String?
    let categoryTitle: String
    let new: Bool
    let version: String
}

struct UserProductResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
}

// MARK: - Feedback
struct Feedback: Codable {
    let userToken: String
    let stars: Int
    let totalLists: Int
    let isAutoCategory: Bool
    let text: String?
}

struct FeedbackResponse: Codable {
    var error: Bool
    var messages: [String]
    var data: [String]
}

// MARK: - Вкл/выкл FAQ в админке
struct FetchFAQStateResponse: Codable {
    var error: Bool
    var messages: [String]
    var enabled: Bool
}

// MARK: - для получения ссылки на полный архив рецептов
struct FetchArchiveListResponse: Codable {
    var error: Bool
    var messages: [String]
    var links: [FetchArchiveList]
}

struct FetchArchiveList: Codable {
    let url: String
    let totalRecords: Int
    let lang: String
    let archiveType: String
    let updatedAt: String
}

// MARK: - SendMail
struct SendMail: Codable {
    let name: String
    let email: String
    var appCode = "grl23"
    let subject: String
    let message: String
}

// MARK: - Ссылка на картинку
struct UploadImageResponse: Codable {
    var error: Bool
    var messages: [String]
    var data: ImageBackUrl
}

struct ImageBackUrl: Codable {
    let url: String
}
