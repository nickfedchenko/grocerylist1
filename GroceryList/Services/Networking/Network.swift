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
typealias RegistrationResult = (Result<RegistrationResponse, AFError>) -> Void

enum RequestGenerator: Codable {
    case getProducts
    case getReciepts
    case createUser(userModel: User?)

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
        case .createUser:
            fatalError("use myltiformObject")
        }
    }
    
    var multiformRequestObject: (MultipartFormData, URL) {
        switch self {
        case .createUser(userModel: let user):
            print("createUser")
            guard var components = URLComponents(string: "https://newketo.finanse.space/api/user/register") else {
                fatalError("Error With Creating Components")
            }
            
            injectUserParametrs(in: &components, userModel: user)
        
            guard
                let url = components.url,
                let imageData = user?.avatarAsData
            else { fatalError("Error resolving URL")
            }
            let boundary = UUID().uuidString
            let mfData = MultipartFormData(fileManager: .default, boundary: boundary)
            mfData.append(
                imageData,
                withName: "avatar",
                fileName: "avatar.jpg",
                mimeType: "avatar/jpg"
            )
            
            return (mfData, url)
        default:
            fatalError("Use request property instead")
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
    
    private func injectUserParametrs(in components: inout URLComponents, userModel: User?) {
        guard let userModel = userModel else { return }
        let motivationQueries: [URLQueryItem] = [
            .init(name: "email", value: userModel.email),
            .init(name: "password", value: userModel.password),
            .init(name: "username", value: userModel.userName)
        ]
        
        if components.queryItems == nil {
            components.queryItems = motivationQueries
        } else {
            components.queryItems?.append(contentsOf: motivationQueries)
        }
    }
}

final class NetworkEngine {
    
    private func performDecodableUploadRequest<T: Decodable>(
        request: RequestGenerator,
        completion: @escaping ((Result<T, AFError>) -> Void)
    ) {
        
        let headers = [
            "Authorization": "Bearer yKuSDC3SQUQNm1kKOA8s7bfd0eQ0WXOTAc8QsfHQ",
            "Content-Type": "multipart/form-data"
        ]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        let mfObject = request.multiformRequestObject
        print(mfObject)
        AF
            .upload(multipartFormData: mfObject.0, to: mfObject.1,
                    method: .post, headers: .init(headers))
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
    
    func registerUser(completion: @escaping RegistrationResult) {
        performDecodableUploadRequest(request: .createUser(userModel: User(id: 2, userName: "dfdf", email: "fdfdf",
                                                                           token: "dfd", isConfirmed: false, password: "fgfg",
                                                                           avatarAsData: UIImage(systemName: "trash")?.jpegData(compressionQuality: 1)
                                                                          )), completion: completion)
    }
    
}
