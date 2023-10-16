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

typealias UserProductResult = (Result<UserProductResponse, AFError>) -> Void
typealias FeedbackResult = (Result<FeedbackResponse, AFError>) -> Void

typealias FetchFAQStateResult = (Result<FetchFAQStateResponse, AFError>) -> Void
typealias SendMailResult = (Result<String, AFError>) -> Void
typealias UploadImageResult = (Result<UploadImageResponse, AFError>) -> Void

// Share
typealias ListReleaseResult = (Result<ListReleaseResponse, AFError>) -> Void
typealias ShareSuccessResult = (Result<ShareSuccessResponse, AFError>) -> Void
typealias FetchMyGroceryListsResult = (Result<FetchMyGroceryListsResponse, AFError>) -> Void
typealias FetchListUsersResult = (Result<FetchListUsersResponse, AFError>) -> Void
typealias ShareGroceryListResult = (Result<ShareGroceryListResponse, AFError>) -> Void

typealias SharePantryResult = (Result<SharePantryResponse, AFError>) -> Void
typealias FetchMyPantryListsResult = (Result<FetchMyPantryListsResponse, AFError>) -> Void

typealias ShareMealPlanResult = (Result<ShareMealPlanResponse, AFError>) -> Void
typealias FetchMyMealPlanResult = (Result<FetchMyMealPlansResponse, AFError>) -> Void
