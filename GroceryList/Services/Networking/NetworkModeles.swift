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

struct NetworkProductModel: Codable {
    let title: String
    let marketCategory: MarketCategory
    let units: [Unit]
    let photo: String
}

struct Unit: Codable {
    let title: String?
    let value: Double
}

struct MarketCategory: Codable {
    let id: Int
    let title: String
}
