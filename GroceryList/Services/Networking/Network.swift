//
//  Network.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 11.11.2022.
//

import Alamofire
import UIKit

protocol NetworkDataProvider {
    func getAllProducts(completion: @escaping GetAllProductsResult)
}

typealias GetAllProductsResult = (Result<GetAllProductsResponse, AFError>) -> Void

enum RequestGenerator: Codable {
    
    private var token: String {
        return "yKuSDC3SQUQNm1kKOA8s7bfd0eQ0WXOTAc8QsfHQ"
    }

    case getPosts
    
    var request: URLRequest {
        switch self {
            
        case .getPosts:
            guard var components = URLComponents(
                string: "https://newketo.finanse.space/api/shoppingList/fetchProducts") else {
                    fatalError("FatalError")
                }
            injectLocale(in: &components)
            guard let url = components.url else {
                fatalError("Error resolving URL")
            }
            var request = URLRequest(url: url)
            request.method = .get
            request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            return request
            
        }
    }
    
    private func injectLocale(in components: inout URLComponents) {
        var locale = Locale.current.languageCode
        
        locale = locale == "ru" ? "ru" : "en"
        
        if components.queryItems == nil {
            components.queryItems = [.init(name: "langCode", value: locale)]
        } else {
            components.queryItems?.append(.init(name: "langCode", value: locale))
        }
    }
}

final class NetworkEngine {
 
    private func performDecodableRequest<T: Decodable>(
        request: RequestGenerator,
        completion: @escaping ((Result<T, AFError>) -> Void)
    ) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        AF.request(request.request)
            .validate()
            .responseDecodable(
                of: T.self,
                queue: .global(qos: .userInitiated),
                decoder: decoder
            ) { result in
                guard let data = result.value else {
                    if let error = result.error {
                        
                        completion(.failure(error))
                    }
                    return
                }
                completion(.success(data))
            }
    }
}

extension NetworkEngine: NetworkDataProvider {
   
    func getAllProducts(completion: @escaping GetAllProductsResult) {
        performDecodableRequest(request: .getPosts, completion: completion)
    }
    
}
