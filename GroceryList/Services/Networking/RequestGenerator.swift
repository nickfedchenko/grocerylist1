//
//  RequestGenerator.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.06.2023.
//

import Alamofire
import Foundation

enum RequestGenerator: Codable {
    case getProducts
    case getReciepts
    case getItems
    case getProductCategories
    case getItemCategories
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
    case updateGroceryList(userToken: String, listId: String)
    case userProduct
    case feedback
    
    case sharePantryList(userToken: String, listId: String?)
    case pantryListRelease(userToken: String, sharingToken: String)
    case pantryListDelete(userToken: String, listId: String)
    case pantryListUpdate(userToken: String, listId: String)
    case pantryListUserDelete(userToken: String, listId: String)
    case fetchMyPantryLists(userToken: String)
    case fetchPantryListUsers(userToken: String, listId: String)
    
    case fetchFAQState

    private var bearerToken: String {
        return "Bearer yKuSDC3SQUQNm1kKOA8s7bfd0eQ0WXOTAc8QsfHQ"
    }
    
    /// обычный реквест
    var request: URLRequest {
        switch self {
        case .getProducts:
            return requestCreator(basicURL: getUrlForProducts(), method: .get) { _ in }
        case .getReciepts:
            return requestCreator(basicURL: getUrlForReciepts(), method: .get, needsToken: false) { _ in }
        case .getItems:
            return requestCreator(basicURL: getUrlForItems(), method: .get) { _ in }
        case .getProductCategories:
            return requestCreator(basicURL: getUrlForProductCategories(), method: .get) { _ in }
        case .getItemCategories:
            return requestCreator(basicURL: getUrlForItemCategories(), method: .get) { _ in }
        case .logIn(let email, let password):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/user/login", method: .post) { components in
                injectEmailAndPassword(in: &components, email: email, password: password)
            }
        case .createUser(let email, let password):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/user/register", method: .post) { components in
                injectEmailAndPassword(in: &components, email: email, password: password)
            }
        case .updateUsername(let userToken, let newName):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/user/name", method: .post) { components in
                injectUserTokenAndNewName(in: &components, userToken: userToken, newName: newName)
            }
        case .checkEmail(email: let email):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/user/email", method: .get) { components in
                injectEmail(in: &components, email: email)
            }
        case .resendVerification(let email):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/user/register/resend", method: .post) { components in
                injectEmail(in: &components, email: email)
            }
        case .passwordReset(let email):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/user/password/request", method: .post) { components in
                injectEmail(in: &components, email: email)
            }
        case .updatePassword(let newPassword, let resetToken):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/user/password/update", method: .post) { components in
                injectNewPasswordAndResetToken(in: &components, newPassword: newPassword, resetToken: resetToken)
            }
        case .deleteUser(userToken: let userToken):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/user/delete", method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
            }
        case .groceryListRelease(userToken: let userToken, sharingToken: let sharingToken):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/groceryList/release", method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectSharingToken(in: &components, sharingToken: sharingToken)
            }
        case .groceryListDelete(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/groceryList/delete", method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectListId(in: &components, listId: listId)
            }
        case .fetchMyGroceryLists(userToken: let userToken):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/groceryList/fetch",
                                  method: .get) { components in
                injectUserToken(in: &components, userToken: userToken)
            }
        case .fetchGroceryListUsers(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/groceryList/fetch/users",
                                  method: .get) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectListId(in: &components, listId: listId)
            }
        case .groceryListUserDelete(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/groceryList/users/delete",
                                  method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectListId(in: &components, listId: listId)
            }
        case .shareGroceryList(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/groceryList/share",
                                  method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                if let listId = listId {
                    injectListId(in: &components, listId: listId)
                }
            }
        case .updateGroceryList(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/groceryList/update",
                                  method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectListId(in: &components, listId: listId)
            }
        case .uploadAvatar:
            fatalError("use multiformRequestObject")
        case .userProduct:
            return requestCreator(basicURL: "https://ketodietapplication.site/api/item2",
                                  method: .post) { _ in }
        case .feedback:
            return requestCreator(basicURL: "https://ketodietapplication.site/api/feedback",
                                  method: .post) { _ in }
            
        case .sharePantryList(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/pantryList/share",
                                  method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                if let listId = listId {
                    injectPantryListId(in: &components, listId: listId)
                }
            }
        case .pantryListRelease(userToken: let userToken, sharingToken: let sharingToken):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/pantryList/release", method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectSharingToken(in: &components, sharingToken: sharingToken)
            }
        case .pantryListDelete(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/pantryList/delete", method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectPantryListId(in: &components, listId: listId)
            }
        case .pantryListUpdate(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/pantryList/update",
                                  method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectPantryListId(in: &components, listId: listId)
            }
        case .pantryListUserDelete(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/pantryList/users/delete",
                                  method: .post) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectPantryListId(in: &components, listId: listId)
            }
        case .fetchMyPantryLists(userToken: let userToken):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/pantryList/fetch",
                                  method: .get) { components in
                injectUserToken(in: &components, userToken: userToken)
            }
        case .fetchPantryListUsers(userToken: let userToken, listId: let listId):
            return requestCreator(basicURL: "https://ketodietapplication.site/api/pantryList/fetch/users",
                                  method: .get) { components in
                injectUserToken(in: &components, userToken: userToken)
                injectPantryListId(in: &components, listId: listId)
            }
        case .fetchFAQState:
            return requestCreator(basicURL: "https://ketodietapplication.site/api/faq/state", method: .get) { _ in }
        }
    }
    
    /// реквест для отправки  данных на сервер
    var multiformRequestObject: (MultipartFormData, URL) {
        switch self {
        case .uploadAvatar(let token, let data):
            guard var components = URLComponents(string: "https://ketodietapplication.site/api/user/avatar") else {
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
            return "https://ketodietapplication.site/api/fetchBasicAndDished?langCode=\(currentLocale.rawValue)"
        } else {
            return "https://ketodietapplication.site/api/fetchBasicAndDished?langCode=en"
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
    
    private func getUrlForItems() -> String {
        guard let locale = Locale.current.languageCode else { return "" }
        if let currentLocale = CurrentLocale(rawValue: locale) {
            return "https://ketodietapplication.site/api/items?langCode=\(currentLocale.rawValue)"
        } else {
            return "https://ketodietapplication.site/api/items?langCode=en"
        }
    }
    
    private func getUrlForProductCategories() -> String {
        guard let locale = Locale.current.languageCode else { return "" }
        if let currentLocale = CurrentLocale(rawValue: locale) {
            return "https://ketodietapplication.site/api/product/categories?langCode=\(currentLocale.rawValue)"
        } else {
            return "https://ketodietapplication.site/api/product/categories?langCode=en"
        }
    }
    
    private func getUrlForItemCategories() -> String {
        guard let locale = Locale.current.languageCode else { return "" }
        if let currentLocale = CurrentLocale(rawValue: locale) {
            return "https://ketodietapplication.site/api/items/categories?langCode=\(currentLocale.rawValue)"
        } else {
            return "https://ketodietapplication.site/api/items/categories?langCode=en"
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
    
    private func injectPantryListId(in components: inout URLComponents, listId: String) {
        let queries: [URLQueryItem] = [
            .init(name: "pantry_list_id", value: listId)
        ]
        insert(queries: queries, components: &components)
    }
}
