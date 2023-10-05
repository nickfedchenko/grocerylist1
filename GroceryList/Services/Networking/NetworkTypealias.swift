//
//  NetworkTypealias.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.06.2023.
//

import Alamofire
import Foundation

typealias GetAllProductsResult = (Result<GetAllProductsResponse, AFError>) -> Void
typealias AllDishesResult = (Result<[Recipe], AFError>) -> Void
typealias GetAllItemsResult = (Result<GetAllItemsResponse, AFError>) -> Void
typealias GetCategoriesResult = (Result<GetCategoriesResponse, AFError>) -> Void
typealias FetchCollectionResult = (Result<NetworkCollectionResponse, AFError>) -> Void

typealias FetchArchiveListResult = (Result<FetchArchiveListResponse, AFError>) -> Void

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
typealias UpdateGroceryListResult = (Result<UpdateGroceryListResponse, AFError>) -> Void

typealias UserProductResult = (Result<UserProductResponse, AFError>) -> Void
typealias FeedbackResult = (Result<FeedbackResponse, AFError>) -> Void

typealias SharePantryResult = (Result<SharePantryResponse, AFError>) -> Void
typealias PantryListReleaseResult = (Result<PantryListReleaseResponse, AFError>) -> Void
typealias PantryListDeleteResult = (Result<PantryListDeleteResponse, AFError>) -> Void
typealias UpdatePantryResult = (Result<UpdatePantryResponse, AFError>) -> Void
typealias PantryListUserDeleteResult = (Result<PantryListUserDeleteResponse, AFError>) -> Void
typealias FetchMyPantryListsResult = (Result<FetchMyPantryListsResponse, AFError>) -> Void
typealias FetchPantryListUsersResult = (Result<FetchPantryListUsersResponse, AFError>) -> Void

typealias FetchFAQStateResult = (Result<FetchFAQStateResponse, AFError>) -> Void
typealias SendMailResult = (Result<String, AFError>) -> Void
