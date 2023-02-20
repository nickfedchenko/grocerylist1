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
typealias CreateUserResult = (Result<CreateUserResponse, AFError>) -> Void
typealias ChangeUserNameResult = (Result<ChangeUsernameResponse, AFError>) -> Void
typealias MailExistsResult = (Result<MailExistResponse, AFError>) -> Void
typealias ResendVerificationCodeResult = (Result<ResendVerificationResponse, AFError>) -> Void
typealias PasswordResetResult = (Result<PasswordResetResponse, AFError>) -> Void
typealias PasswordUpdateResult = (Result<PasswordUpdateResponse, AFError>) -> Void
typealias UpdateUsernameResult = (Result<UpdateUsernameResponse, AFError>) -> Void
typealias UploadAvatarResult = (Result<UploadAvatarResponse, AFError>) -> Void
typealias LogInResult = (Result<LogInResponse, AFError>) -> Void
typealias DeleteUserResult = (Result<DeleteUserResponse, AFError>) -> Void
typealias GroceryListReleaseResult = (Result<GroceryListReleaseResponse, AFError>) -> Void
typealias GroceryListDeleteResult = (Result<GroceryListDeleteResponse, AFError>) -> Void
typealias FetchMyGroceryListsResult = (Result<FetchMyGroceryListsResponse, AFError>) -> Void
typealias FetchGroceryListUsersResult = (Result<FetchGroceryListUsersResponse, AFError>) -> Void
typealias GroceryListUserDeleteResult = (Result<GroceryListUserDeleteResponse, AFError>) -> Void
typealias ShareGroceryListResult = (Result<ShareGroceryListResponse, AFError>) -> Void

enum RequestGenerator: Codable {
    case getProducts
    case getReciepts
    case createUser(email: String, password: String)
    case logIn(email: String, password: String)
    case updateUsername(userToken: String, newName: String)
    case uploadAvatar(userToken: String, imageData: Data)
    case checkEmail(email: String)
    case resendVerification(email: String)
    case passwordReset(email: String)
    case updatePassword(newPassword: String, resetToken: String)
    case deleteUser(userToken: String)
    case groceryListRelease(userToken: String, sharingToken: String)
    case groceryListDelete(userToken: String, listId: String)
    case fetchMyGroceryLists(userToken: String)
    case fetchGroceryListUsers(userToken: String, listId: String)
    case groceryListUserDelete(userToken: String, listId: String)
    case shareGroceryList(userToken: String, listId: String?)
    
    private var bearerToken: String {
        return "Bearer yKuSDC3SQUQNm1kKOA8s7bfd0eQ0WXOTAc8QsfHQ"
    }
    
    /// обычный реквест
    var request: URLRequest {
        switch self {
        case .getProducts:
            return requestCreator(basicURL:getUrlForProducts(), method: .get, needsToken: false) { _ in }
        case .getReciepts:
            return requestCreator(basicURL: getUrlForReciepts(), method: .get, needsToken: false) { _ in }
        case .logIn(let email, let password):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/user/login", method: .post) { components in
                injectEmailAndPassword(in: &components, email: email, password: password)
            }
        case .createUser(let email, let password):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/user/register", method: .post) { components in
                injectEmailAndPassword(in: &components, email: email, password: password)
            }
        case .updateUsername(let userToken, let newName):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/user/name", method: .post) { components in
                injectUserTokenAndNewName(in: &components, userToken: userToken, newName: newName)
            }
        case .checkEmail(email: let email):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/user/email", method: .get) { components in
                injectEmail(in: &components, email: email)
            }
        case .resendVerification(let email):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/user/register/resend", method: .post) { components in
                injectEmail(in: &components, email: email)
            }
        case .passwordReset(let email):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/user/password/request", method: .post) { components in
                injectEmail(in: &components, email: email)
            }
        case .updatePassword(let newPassword, let resetToken):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/user/password/update", method: .post) { components in
                injectNewPasswordAndResetToken(in: &components, newPassword: newPassword, resetToken: resetToken)
            }
        case .deleteUser(userToken: let userToken):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/user/delete", method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
            }
        case .groceryListRelease(userToken: let userToken, sharingToken: let sharingToken):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/groceryList/release", method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectSharingToken(in: &components, sharingToken: sharingToken)
            }
        case .groceryListDelete(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/groceryList/delete", method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectListId(in: &components, listId: listId)
            }
        case .fetchMyGroceryLists(userToken: let userToken):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/groceryList/fetch",
                                  method: .get) { components in
                injectUserToken(in: &components, userToken: userToken)
            }
        case .fetchGroceryListUsers(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/groceryList/fetch/users",
                                  method: .get) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectListId(in: &components, listId: listId)
            }
        case .groceryListUserDelete(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/groceryList/users/delete",
                                  method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectListId(in: &components, listId: listId)
            }
        case .shareGroceryList(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://newketo.finanse.space/api/groceryList/share",
                                  method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
            }
        case .uploadAvatar:
            fatalError("use multiformRequestObject")
        }
    }
    
    /// реквест для отправки  данных на сервер
    var multiformRequestObject: (MultipartFormData, URL) {
        switch self {
        case .uploadAvatar(let token, let data):
            guard var components = URLComponents(string: "https://newketo.finanse.space/api/user/avatar") else {
                fatalError("Error With Creating Components")
            }
            
            injectUserToken(in: &components, userToken: token)
            
            guard let url = components.url else {
                fatalError("Error resolving URL")
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

    /// метод сборки реквеста
    private func requestCreator(basicURL: String,
                                method: HTTPMethod,
                                needsToken: Bool = true,
                                injecton: ((inout URLComponents) -> Void)) -> URLRequest {
        guard var components = URLComponents( string: basicURL) else {
            fatalError("FatalError")
        }
        
        injecton(&components)
        
        guard let url = components.url else {
            fatalError("Error resolving URL")
        }
        
        var request = URLRequest(url: url)
        request.method = method
        
        if needsToken {
            request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
        }
        
        return request
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
    
    private func insert(queries: [URLQueryItem], components: inout URLComponents) {
        if components.queryItems == nil {
            components.queryItems = queries
        } else {
            components.queryItems?.append(contentsOf: queries)
        }
    }
    
    private func injectEmailAndPassword(in components: inout URLComponents, email: String, password: String) {
        let queries: [URLQueryItem] = [
            .init(name: "email", value: email),
            .init(name: "password", value: password)
        ]
        insert(queries: queries, components: &components)
    }
    
    private func injectUserParametrs(in components: inout URLComponents, userModel: User?) {
        guard let userModel = userModel else { return }
        let queries: [URLQueryItem] = [
            .init(name: "email", value: userModel.email),
            .init(name: "password", value: userModel.password),
            .init(name: "username", value: userModel.username)
        ]
        insert(queries: queries, components: &components)
    }
    
    private func injectUserTokenAndNewName(in components: inout URLComponents, userToken: String, newName: String) {
        let queries: [URLQueryItem] = [
            .init(name: "user_token", value: userToken),
            .init(name: "username", value: newName)
        ]
        insert(queries: queries, components: &components)
    }
    
    private func injectEmail(in components: inout URLComponents, email: String) {
        let queries: [URLQueryItem] = [
            .init(name: "email", value: email)
        ]
        insert(queries: queries, components: &components)
    }
    
    private func injectUserToken(in components: inout URLComponents, userToken: String) {
        let queries: [URLQueryItem] = [
            .init(name: "user_token", value: userToken)
        ]
        insert(queries: queries, components: &components)
    }
    
    private func injectSharingToken(in components: inout URLComponents, sharingToken: String) {
        let queries: [URLQueryItem] = [
            .init(name: "sharing_token", value: sharingToken)
        ]
        insert(queries: queries, components: &components)
    }
    
    private func injectListId(in components: inout URLComponents, listId: String) {
        let queries: [URLQueryItem] = [
            .init(name: "grocery_list_id", value: listId)
        ]
        insert(queries: queries, components: &components)
    }
    
    private func injectNewPasswordAndResetToken(in components: inout URLComponents, newPassword: String, resetToken: String) {
        let queries: [URLQueryItem] = [
            .init(name: "new_password", value: newPassword),
            .init(name: "reset_token", value: resetToken)
        ]
        insert(queries: queries, components: &components)
    }
}

final class NetworkEngine {
    /// метод отправки реквеста с данными
    private func performDecodableUploadRequest<T: Decodable>(
        request: RequestGenerator,
        completion: @escaping ((Result<T, AFError>) -> Void)
    ) {
        
        let headers = [
            "Authorization": "Bearer yKuSDC3SQUQNm1kKOA8s7bfd0eQ0WXOTAc8QsfHQ",
            "Content-Type": "multipart/form-data"
        ]
        
        let decoder = createDecoder()
        let mfObject = request.multiformRequestObject
        
        AF.upload(multipartFormData: mfObject.0, to: mfObject.1,
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
        let decoder = createDecoder()
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
    
    private func performDecodableRequestSend<T: Decodable>(
        request: RequestGenerator,
        listModel: GroceryListsModel,
        completion: @escaping ((Result<T, AFError>) -> Void)
    ) {
        let decoder = createDecoder()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer yKuSDC3SQUQNm1kKOA8s7bfd0eQ0WXOTAc8QsfHQ",
            "Content-Type": "application/json"
        ]

        AF.request(request.request.url!, method: .post, parameters: ["grocery_list": [listModel]],
                   encoder: JSONParameterEncoder.default, headers: headers, interceptor: nil, requestModifier: nil)
        .validate()
        .responseData { result in
            guard let data = result.value else {
                if let error = result.error {
                    completion(.failure(error))
                }
                return
            }
            
            guard let dataModel = try? decoder.decode(T.self, from: data) else {
                print("errModel")
                return
            }
            completion(.success(dataModel))
        }
    }
    
    private func createDecoder() -> JSONDecoder {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}

extension NetworkEngine: NetworkDataProvider {
    
    func getAllProducts(completion: @escaping GetAllProductsResult) {
        performDecodableRequest(request: .getProducts, completion: completion)
    }
    
    func getAllRecipes(completion: @escaping AllDishesResult) {
        performDecodableRequest(request: .getReciepts, completion: completion)
    }
    /// регистрация юзера
    func createUser(email: String, password: String, completion: @escaping CreateUserResult) {
        performDecodableRequest(request: .createUser(email: email, password: password), completion: completion)
    }
    /// вход юзера, возвращает юзера с его данными
    func logIn(email: String, password: String, completion: @escaping LogInResult) {
        performDecodableRequest(request: .logIn(email: email, password: password), completion: completion)
    }
    /// меняем или создаем имя юзера
    func updateUserName(userToken: String, newName: String, completion: @escaping UpdateUsernameResult) {
        performDecodableRequest(request: .updateUsername(userToken: userToken, newName: newName), completion: completion)
    }
    /// загружаем аватар
    func uploadAvatar(userToken: String, imageData: Data, completion: @escaping UploadAvatarResult) {
        performDecodableUploadRequest(request: .uploadAvatar(userToken: userToken, imageData: imageData), completion: completion)
    }
    /// проверка существует ли в базе имейл
    func checkEmail(email: String, completion: @escaping MailExistsResult) {
        performDecodableRequest(request: .checkEmail(email: email), completion: completion)
    }
    /// повторная отправка кода верификации
    func resendVerificationCode(email: String, completion: @escaping ResendVerificationCodeResult) {
        performDecodableRequest(request: .resendVerification(email: email), completion: completion)
    }
    
    /// запрос на смену пароля - отправляет ссылку на почту для подтверждения сброса пароля
    /// там мы ловим диплинк и переходив внутрь апы и уже меняем пароль методом  updatePassword(newPassword: String....
    func passwordReset(email: String, completion: @escaping PasswordResetResult) {
        performDecodableRequest(request: .passwordReset(email: email), completion: completion)
    }
    
    /// метод фактической смены пароля
    func updatePassword(newPassword: String, resetToken: String, completion: @escaping PasswordUpdateResult) {
        performDecodableRequest(request: .updatePassword(newPassword: newPassword, resetToken: resetToken), completion: completion)
    }
    
    /// метод фактической смены пароля
    func deleteUser(userToken: String, completion: @escaping DeleteUserResult) {
        performDecodableRequest(request: .deleteUser(userToken: userToken), completion: completion)
    }
    
    ///  подключение юзера к листу
    func groceryListRelease(userToken: String, sharingToken: String, completion: @escaping GroceryListReleaseResult) {
        performDecodableRequest(request: .groceryListRelease(userToken: userToken,
                                                             sharingToken: sharingToken), completion: completion)
    }
    
    ///   удаление листа - может только овнер
    func groceryListDelete(userToken: String, listId: String, completion: @escaping GroceryListDeleteResult) {
        performDecodableRequest(request: .groceryListDelete(userToken: userToken, listId: listId), completion: completion)
    }
    
    ///   получение листов на которые подписан юзер
    func fetchMyGroceryLists(userToken: String, completion: @escaping FetchMyGroceryListsResult) {
        performDecodableRequest(request: .fetchMyGroceryLists(userToken: userToken), completion: completion)
    }
    
    ///   получить список юзеров подписанных на лист
    func fetchGroceryListUsers(userToken: String, listId: String, completion: @escaping FetchGroceryListUsersResult) {
        performDecodableRequest(request: .fetchGroceryListUsers(userToken: userToken, listId: listId), completion: completion)
    }
    
    ///   отписать юзера от листа
    func groceryListUserDelete(userToken: String, listId: String, completion: @escaping GroceryListUserDeleteResult) {
        performDecodableRequest(request: .groceryListUserDelete(userToken: userToken, listId: listId), completion: completion)
    }
    
    ///   отписать юзера от листа
    func shareGroceryList(userToken: String, listId: String, listModel: GroceryListsModel, completion: @escaping ShareGroceryListResult) {
        performDecodableRequestSend(request: .shareGroceryList(userToken: userToken, listId: listId), listModel: listModel, completion: completion)
    }
}

struct SharedList: Codable {
    var hello: String
    var param: String
}
