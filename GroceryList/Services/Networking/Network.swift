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
typealias ChangeUserNameResult = (Result<ChangeUsernameResponse, AFError>) -> Void
typealias MailExistsResult = (Result<MailExistResponse, AFError>) -> Void
typealias ResendVerificationCodeResult = (Result<ResendVerificationResponse, AFError>) -> Void

enum RequestGenerator: Codable {
    case getProducts
    case getReciepts
    case createUser(email: String, password: String)
    case logIn(email: String, password: String)
    case updateUsername(userToken: String, newName: String)
    case uploadAvatar(userToken: String, imageData: Data)
    case checkEmail(email: String)
    case resendVerification(email: String)
    
    private var bearerToken: String {
        return "Bearer yKuSDC3SQUQNm1kKOA8s7bfd0eQ0WXOTAc8QsfHQ"
    }

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
        case .logIn(let email, let password):
            guard var components = URLComponents(string: "https://newketo.finanse.space/api/user/login") else {
                fatalError("Error With Creating Components")
            }
            
            injectEmailAndPassword(in: &components, email: email, password: password)
            print(components)
            
            guard let url = components.url else {
                fatalError("Error resolving URL")
            }
            var request = URLRequest(url: url)
            request.method = .post
            request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
            return request
        case .createUser(let email, let password):
            guard var components = URLComponents(string: "https://newketo.finanse.space/api/user/register") else {
                fatalError("Error With Creating Components")
            }
            
            injectEmailAndPassword(in: &components, email: email, password: password)
            print(components)
            
            guard let url = components.url else {
                fatalError("Error resolving URL")
            }
            var request = URLRequest(url: url)
            request.method = .post
            request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
            return request
        case .updateUsername(let userToken, let newName):
            guard var components = URLComponents(string: "https://newketo.finanse.space/api/user/name") else {
                fatalError("Error With Creating Components")
            }
            
            injectUserTokenAndNewName(in: &components, userToken: userToken, newName: newName)
            
            guard let url = components.url else {
                fatalError("Error resolving URL")
            }
            var request = URLRequest(url: url)
            request.method = .post
            request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
            return request
        case .checkEmail(email: let email):
            guard var components = URLComponents(string: "https://newketo.finanse.space/api/user/email") else {
                fatalError("Error With Creating Components")
            }
            injectEmail(in: &components, email: email)
          
            guard let url = components.url else {
                fatalError("Error resolving URL")
            }
            var request = URLRequest(url: url)
            request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
            request.method = .get
            return request
        case .resendVerification(email: let email):
            guard var components = URLComponents(string: "https://newketo.finanse.space/api/user/register/resend") else {
                fatalError("Error With Creating Components")
            }
            injectEmail(in: &components, email: email)
    
            guard let url = components.url else {
                fatalError("Error resolving URL")
            }
            var request = URLRequest(url: url)
            request.method = .post
            request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
            return request
        case .uploadAvatar:
            fatalError("use multiformRequestObject")
        }
        
    }
    
    var multiformRequestObject: (MultipartFormData, URL) {
        switch self {
        case .uploadAvatar(let token, let data):
  
            guard var components = URLComponents(string: "https://newketo.finanse.space/api/user/avatar") else {
                fatalError("Error With Creating Components")
            }
            
            injectUserToken(in: &components, userToken: token)

            guard
                let url = components.url
            else { fatalError("Error resolving URL")
            }
            let imageData = data
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
    
    private func injectEmailAndPassword(in components: inout URLComponents, email: String, password: String) {
        let queries: [URLQueryItem] = [
            .init(name: "email", value: email),
            .init(name: "password", value: password)
        ]
        
        if components.queryItems == nil {
            components.queryItems = queries
        } else {
            components.queryItems?.append(contentsOf: queries)
        }
    }
    
    
    private func injectUserParametrs(in components: inout URLComponents, userModel: User?) {
        guard let userModel = userModel else { return }
        let queries: [URLQueryItem] = [
            .init(name: "email", value: userModel.email),
            .init(name: "password", value: userModel.password),
            .init(name: "username", value: userModel.userName)
        ]
        
        if components.queryItems == nil {
            components.queryItems = queries
        } else {
            components.queryItems?.append(contentsOf: queries)
        }
    }
    
    private func injectUserTokenAndNewName(in components: inout URLComponents, userToken: String, newName: String) {
        let queries: [URLQueryItem] = [
            .init(name: "user_token", value: userToken),
            .init(name: "username", value: newName)
        ]
        
        if components.queryItems == nil {
            components.queryItems = queries
        } else {
            components.queryItems?.append(contentsOf: queries)
        }
    }
    
    private func injectEmail(in components: inout URLComponents, email: String) {
        let queries: [URLQueryItem] = [
            .init(name: "email", value: email)
        ]
        
        if components.queryItems == nil {
            components.queryItems = queries
        } else {
            components.queryItems?.append(contentsOf: queries)
        }
    }
    
    private func injectUserToken(in components: inout URLComponents, userToken: String) {
        let queries: [URLQueryItem] = [
            .init(name: "user_token", value: userToken)
        ]
        
        if components.queryItems == nil {
            components.queryItems = queries
        } else {
            components.queryItems?.append(contentsOf: queries)
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
                   
                } else {
                    guard let dataModel = try? decoder.decode(T.self, from: data) else {
                        print("errModel")
                        return
                    }
                    completion(.success(dataModel))
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
    
    func registerUser(email: String, password: String, completion: @escaping RegistrationResult) {
        performDecodableRequest(request: .createUser(email: email, password: password), completion: completion)
    }
    
    func logIn(email: String, password: String, completion: @escaping RegistrationResult) {
        performDecodableRequest(request: .logIn(email: email, password: password), completion: completion)
    }
    
    func updateUserName(userToken: String, newName: String, completion: @escaping RegistrationResult) {
        performDecodableRequest(request: .updateUsername(userToken: userToken, newName: newName), completion: completion)
    }
    
    func uploadAvatar(userToken: String, imageData: Data, completion: @escaping RegistrationResult) {
        performDecodableUploadRequest(request: .uploadAvatar(userToken: userToken, imageData: imageData), completion: completion)
    }
    
    func checkEmail(email: String, completion: @escaping MailExistsResult) {
        performDecodableRequest(request: .checkEmail(email: email), completion: completion)
    }
    
    func resendVerificationCode(email: String, completion: @escaping ResendVerificationCodeResult) {
        performDecodableRequest(request: .resendVerification(email: email), completion: completion)
    }
    
}
