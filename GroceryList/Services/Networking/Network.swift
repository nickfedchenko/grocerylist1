//
//  Network.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 11.11.2022.
//

import Alamofire
import Gzip
import UIKit

protocol NetworkDataProvider {
    func getAllProducts(completion: @escaping GetAllProductsResult)
    func getAllRecipes(completion: @escaping AllDishesResult)
}

typealias GetAllProductsResult = (Result<[NetworkProductModel], AFError>) -> Void
typealias AllDishesResult = (Result<[Recipe], AFError>) -> Void

enum RequestGenerator: Codable {
    case getProducts
    case getReciepts

    var request: URLRequest {
        switch self {

        case .getProducts:
            guard let components = URLComponents(
                string: getUrlForProducts()) else {
                    fatalError("FatalError")
                }

            guard let url = components.url else {
                fatalError("Error resolving URL")
            }
            var request = URLRequest(url: url)
            request.method = .get
            return request
        case .getReciepts:
            guard let components = URLComponents(
                string: getUrlForReciepts()) else {
                    fatalError("FatalError")
                }

            guard let url = components.url else {
                fatalError("Error resolving URL")
            }
            var request = URLRequest(url: url)
            request.method = .get
            return request
        }
    }
    
    private func getUrlForProducts() -> String {
        guard let locale = Locale.current.languageCode else { return "" }
        if let currentLocale = CurrentLocale(rawValue: locale) {
            return "https://newketo.finanse.space/storage/json/products_\(currentLocale.rawValue).json.gz"
        } else {
            return "https://newketo.finanse.space/storage/json/products_en.json.gz"
        }
    }
    
    private func getUrlForReciepts() -> String {
        guard let locale = Locale.current.languageCode else { return "" }
        if let currentLocale = CurrentLocale(rawValue: locale) {
            return "https://newketo.finanse.space/storage/json/dish_\(currentLocale.rawValue).json.gz"
        } else {
            return "https://newketo.finanse.space/storage/json/dish_it.json.gz"
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
            .responseData { result in
                guard let data = result.value else {
                    if let error = result.error {
                        
                        completion(.failure(error))
                    }
                    return
                }
                
                if data.isGzipped {
                    DispatchQueue.global().async {
                        guard let decopmressedData = try? data.gunzipped() else { return }
                        guard let unzippedDishes = try? decoder.decode(T.self, from: decopmressedData) else {
                            print("errModel")
                            return
                        }
                        completion(.success(unzippedDishes))
                    }
                   
                }
            }
    }
}


extension NetworkEngine: NetworkDataProvider {
   
    func getAllProducts(completion: @escaping GetAllProductsResult) {
        performDecodableRequest(request: .getProducts, completion: completion)
    }
    
    func getAllRecipes(completion: @escaping AllDishesResult) {
        performDecodableRequest(request: .getReciepts, completion: completion)
    }
    
}


enum CurrentLocale: String {
    case en
    case ru
    case de
    case fr
    case sp
    case it
}
