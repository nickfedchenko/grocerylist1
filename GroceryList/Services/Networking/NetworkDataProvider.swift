//
//  NetworkDataProvider.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.08.2023.
//

import Foundation

protocol NetworkDataProvider {
    func getAllProducts(completion: @escaping GetAllProductsResult)
    func getAllRecipes(completion: @escaping AllDishesResult)
    func getAllItems(completion: @escaping GetAllItemsResult)
    func getProductCategories(completion: @escaping GetCategoriesResult)
    func getItemCategories(completion: @escaping GetCategoriesResult)
}

extension NetworkEngine: NetworkDataProvider {
    
    func getAllProducts(completion: @escaping GetAllProductsResult) {
        performDecodableRequest(request: .getProducts, completion: completion)
    }
    
    func getAllRecipes(completion: @escaping AllDishesResult) {
        performDecodableRequest(request: .getRecipes, completion: completion)
    }
    
    func fetchArchiveList(type: String, completion: @escaping FetchArchiveListResult) {
        performDecodableRequest(request: .fetchArchiveList(type: type), completion: completion)
    }
    
    func getArchiveRecipe(url: String, completion: @escaping AllDishesResult) {
        performDecodableRequest(request: .getArchive(url: url), completion: completion)
    }
    
    func getAllItems(completion: @escaping GetAllItemsResult) {
        performDecodableRequest(request: .getItems, completion: completion)
    }
    
    func getProductCategories(completion: @escaping GetCategoriesResult) {
        performDecodableRequest(request: .getProductCategories, completion: completion)
    }
    
    func getItemCategories(completion: @escaping GetCategoriesResult) {
        performDecodableRequest(request: .getItemCategories, completion: completion)
    }
    
    func fetchCollections(completion: @escaping FetchCollectionResult) {
        performDecodableRequest(request: .fetchCollections, completion: completion)
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
    func groceryListRelease(userToken: String, sharingToken: String, completion: @escaping ListReleaseResult) {
        performDecodableRequest(request: .groceryListRelease(userToken: userToken,
                                                             sharingToken: sharingToken), completion: completion)
    }
    
    ///   удаление листа - может только овнер
    func groceryListDelete(userToken: String, listId: String, completion: @escaping ShareSuccessResult) {
        performDecodableRequest(request: .groceryListDelete(userToken: userToken, listId: listId), completion: completion)
    }
    
    ///   получение листов на которые подписан юзер
    func fetchMyGroceryLists(userToken: String, completion: @escaping FetchMyGroceryListsResult) {
        performDecodableRequest(request: .fetchMyGroceryLists(userToken: userToken), completion: completion)
    }
    
    ///   получить список юзеров подписанных на лист
    func fetchGroceryListUsers(userToken: String, listId: String, completion: @escaping FetchListUsersResult) {
        performDecodableRequest(request: .fetchGroceryListUsers(userToken: userToken, listId: listId), completion: completion)
    }
    
    ///   отписать юзера от листа
    func groceryListUserDelete(userToken: String, listId: String, completion: @escaping ShareSuccessResult) {
        performDecodableRequest(request: .groceryListUserDelete(userToken: userToken, listId: listId), completion: completion)
    }
    
    ///   зашарить список
    func shareGroceryList(userToken: String, listId: String?, listModel: GroceryListsModel, completion: @escaping ShareGroceryListResult) {
        let param = ["grocery_list": listModel]
        performDecodableRequestSend(request: .shareGroceryList(userToken: userToken, listId: listId), params: param, completion: completion)
    }
    
    ///   зашарить список
    func updateGroceryList(userToken: String, listId: String, listModel: GroceryListsModel,
                           completion: @escaping ShareSuccessResult) {
        let param = ["grocery_list": listModel]
        performDecodableRequestSend(request: .updateGroceryList(userToken: userToken, listId: listId), params: param, completion: completion)
    }
    
    ///   товар, который пользователь добавляет в список
    func userProduct(userToken: String, product: UserProduct, completion: @escaping UserProductResult) {
        performDecodableRequestSend(request: .userProduct,
                                    params: product,
                                    completion: completion)
    }
    
    ///   фидбек от пользователей
    func sendFeedback(feedback: Feedback, completion: @escaping FeedbackResult) {
        performDecodableRequestSend(request: .feedback,
                                    params: feedback,
                                    completion: completion)
    }
    
    ///   зашарить Pantry список
    func sharePantry(userToken: String, pantryId: String?, pantryModel: PantryModel,
                     completion: @escaping SharePantryResult) {
        let param = ["pantry_list": pantryModel]
        performDecodableRequestSend(request: .sharePantryList(userToken: userToken, listId: pantryId),
                                    params: param, completion: completion)
    }
    
    ///  подключение юзера к Pantry листу
    func pantryListRelease(userToken: String, sharingToken: String,
                           completion: @escaping ListReleaseResult) {
        performDecodableRequest(request: .pantryListRelease(userToken: userToken, sharingToken: sharingToken),
                                completion: completion)
    }
    
    ///   удаление Pantry листа - может только владелец
    func pantryListDelete(userToken: String, pantryId: String, completion: @escaping ShareSuccessResult) {
        performDecodableRequest(request: .pantryListDelete(userToken: userToken, listId: pantryId),
                                completion: completion)
    }
    
    ///   обновить зашаренный Pantry список
    func updatePantry(userToken: String, pantryId: String, pantryModel: PantryModel,
                      completion: @escaping ShareSuccessResult) {
        let param = ["pantry_list": pantryModel]
        performDecodableRequestSend(request: .pantryListUpdate(userToken: userToken, listId: pantryId),
                                    params: param, completion: completion)
    }
    
    ///   отписать юзера от Pantry листа
    func pantryListUserDelete(userToken: String, pantryId: String, completion: @escaping ShareSuccessResult) {
        performDecodableRequest(request: .pantryListUserDelete(userToken: userToken, listId: pantryId),
                                completion: completion)
    }
    
    ///   получение Pantry листов на которые подписан юзер
    func fetchMyPantryLists(userToken: String, completion: @escaping FetchMyPantryListsResult) {
        performDecodableRequest(request: .fetchMyPantryLists(userToken: userToken),
                                completion: completion)
    }
    
    ///   получить список юзеров подписанных на Pantry лист
    func fetchPantryListUsers(userToken: String, pantryId: String, completion: @escaping FetchListUsersResult) {
        performDecodableRequest(request: .fetchPantryListUsers(userToken: userToken, listId: pantryId),
                                completion: completion)
    }
    
    ///   получение состояние FAQ - скрыть/показать
    func fetchFAQState(completion: @escaping FetchFAQStateResult) {
        performDecodableRequest(request: .fetchFAQState, completion: completion)
    }
    
    ///   запас, который пользователь добавляет в список
    func saveUserPantryList(pantryTitle: String, stockTitle: String, completion: @escaping UserProductResult) {
        performDecodableRequest(request: .saveUserPantryList(pantryTitle: pantryTitle, stockTitle: stockTitle),
                                completion: completion)
    }
    
    ///   oтправка фидбека юзера через наше API
    func sendMail(sendMail: SendMail, completion: @escaping SendMailResult) {
        performDecodableRequestSend(request: .sendMail,
                                    params: sendMail,
                                    completion: completion)
    }
    
    ///   oтправка картинки на сервер
    func uploadImage(imageData: Data, completion: @escaping UploadImageResult) {
        performDecodableUploadRequest(request: .uploadImage(imageData: imageData),
                                      completion: completion)
    }
    
    ///   зашарить Meal Plan
    func shareMealPlan(userToken: String, mealList: MealList,
                       completion: @escaping ShareMealPlanResult) {
        let param = ["meal_list": mealList]
        performDecodableRequestSend(request: .shareMealPlanList(userToken: userToken, mealListId: mealList.mealListId),
                                    params: param, completion: completion)
    }
    
    ///  подключение юзера к Meal Plan
    func mealPlanRelease(userToken: String, sharingToken: String,
                         completion: @escaping ListReleaseResult) {
        performDecodableRequest(request: .mealPlanRelease(userToken: userToken, sharingToken: sharingToken),
                                completion: completion)
    }
    
    ///  обновить зашаренный Meal Plan
    func updateMealPlan(userToken: String, mealList: MealList,
                        completion: @escaping ShareSuccessResult) {
        let param = ["meal_list": mealList]
        performDecodableRequestSend(request: .mealPlanUpdate(userToken: userToken, mealListId: mealList.mealListId),
                                    params: param, completion: completion)
    }
    
    ///   отписать юзера от Meal Plan-a
    func mealPlanUserDelete(userToken: String, mealListId: String, completion: @escaping ShareSuccessResult) {
        performDecodableRequest(request: .mealPlanUserDelete(userToken: userToken, mealListId: mealListId),
                                completion: completion)
    }

    ///   получение Meal Plan-ов на которые подписан юзер
    func fetchMyMealPlans(userToken: String, completion: @escaping FetchMyMealPlanResult) {
        performDecodableRequest(request: .fetchMyMealPlanLists(userToken: userToken),
                                completion: completion)
    }

    ///   получить список юзеров подписанных на Meal Plan
    func fetchMealPlanUsers(userToken: String, mealListId: String, completion: @escaping FetchListUsersResult) {
        performDecodableRequest(request: .fetchMealPlanUsers(userToken: userToken, mealListId: mealListId),
                                completion: completion)
    }
}
