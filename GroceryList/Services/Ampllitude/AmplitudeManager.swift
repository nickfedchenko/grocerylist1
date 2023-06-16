//
//  AmplitudeManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.02.2023.
//

import Amplitude
import ApphudSDK
import Foundation

class AmplitudeManager {
    
    private init() {
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().initializeApiKey("b199f09c9cddea79687c52f8a0c77e6b", userId: Apphud.userID())
    }
    
    static let shared = AmplitudeManager()

    private func logEvent(_ eventName: String, properties: [String: Any]? = nil) {
        if let properties = properties {
            Amplitude.instance().logEvent(eventName, withEventProperties: properties)
        } else {
            Amplitude.instance().logEvent(eventName)
        }
    }

    func logEvent(_ event: EventName, properties: [String: String]? = nil) {
        logEvent(event.rawValue, properties: properties)
    }
    
    func setUserProperty(properties: [AnyHashable: Any]) {
        Amplitude.instance().setUserProperties(properties)
    }
}

enum EventName: String {
    case feedbackScreenOpen = "FeedbackScreenOpen"
    // Core
    case listsCountStart = "lists_count_start"
    case itemsCountStart = "items_count_start"
    case itemsCheckedCountStart = "items_checked_count_start"
    case listsPinned = "lists_pinned"
    case itemsPinned = "items_pinned"
    case listsChanged = "lists_changed"
    case itemsChanged = "items_changed"
    case itemAdd = "item_add"
    case itemChecked = "item_checked"
    case itemDelete = "item_delete"
    case listCreate = "list_create"
    case listDelete = "list_delete"
    case categoryChange = "category_change"
    case categoryNew = "category_new"
    case listSendedText = "Shoppinglist_Sended_text"
    
    // CreateItem
    case photoAdd = "photo_add"
    case secondInputManual = "second_input_manual"
    case photoDelete = "photo_delete"
    case itemQuantityButtons = "item_quantity_buttons"
    case itemUnitsButton = "item_units_button"
    case itemPredictAdd = "item_predict_add"
    
    // Sharing
    case signInEmail = "sign_in_email"
    case sendInvite = "send_invite"
    case acceptedInvite = "accepted_invite"     // нет этого функционала - юзер принял входящее приглашение
    case sharedLists = "shared_lists"
    case sharedUsersMaxCount = "shared_users_max_count"
    case sharedDeleteUser = "shared_delete_user"    // нет этого функционала - Юзер нажал на перестать делиться
    case registerFromLink = "register_from_link"
    case sharedListLoading = "SharedListLoading"
    
    // Recipes
    case recipeSection = "recipe_section"
    case recipeAddFavorites = "recipe_add_favorites"
    case recipeAddToList = "recipe_add_to_list"
    case itemCheckedFromRecipe = "item_checked_from_recipe"
    case recipeServingChange = "recipe_serving_change"
    
    // Other
    case problemTell = "problem_tell"
    case paywallClose = "paywall_close"
    case subscribtionBuy = "subscribtion_buy"
    
    // EditList
    case editList = "edit_list"
    case editCheckItem = "edit_check_item"
    case editSelectAllItems = "edit_select_all_items"
    case editMoveItems = "edit_move_items"
    case editCopyItems = "edit_copy_items"
    case editDeleteItems = "edit_delete_items"
    case editDeselectAll = "edit_deselect_all"
    case editDeleteDone = "edit_delete_done"
    
    // ListSettings
    case setFix = "set_fix"
    case setRename = "set_rename"
    case inputRename = "input_rename"
    case setInvite = "set_invite"
    case setSortCategory = "set_sort_category"
    case setSortTime = "set_sort_time"
    case setSortRecipe = "set_sort_recipe"
    case setSortAbc = "set_sort_abc"
    case setColor = "set_color"
    case setAutoimageToggle = "set_autoimage_toggle"
    case setSendAsText = "set_send_as_text"
    case setPrint = "set_print"
    case setDelete = "set_delete"
    
    // ShopPrice
    case shopPriceToggle = "shop_price_toggle"
    case shopStoreBtn = "shop_store_btn"
    case shopCostBtn = "shop_cost_btn"
    case shopShopSelectet = "shop_shop_selectet"
    case shopNewShop = "shop_new_shop"
    case shopSaveNewShop = "shop_save_new_shop"
    case shopSavePrice = "shop_save_price"
    
    // Preferences
    case prefUnits = "pref_units"
    case prefHapticToggle = "pref_haptic_toggle"
    case prefPictureToggle = "pref_picture_toggle"
    case prefLike = "pref_like"
    
    // Pantry
    case pantryListCreated = "pantry_list_created"
    case pantryLinkListCreated = "pantry_link_list_created"
    case pantryLinkListInside = "pantry_link_list_inside" // при редактировании?
    case pantryMenuEdit = "pantry_menu_edit"
    case pantryMenuRename = "pantry_menu_rename"
    case pantryMenuAddUser = "pantry_menu_add_user"
    case pantryMenuSend = "pantry_menu_send"
    case pantryMenuShopsToggle = "pantry_menu_shops_toggle"
    case pantryMenuColor = "pantry_menu_color"
    case pantryImageMatchToggle = "pantry_image_match_toggle"
    case pantryMenuDelete = "pantry_menu_delete"
    case pantryListRearrage = "pantry_list_rearrage"
    case pantryCopyItems = "pantry_copy_items"
    case pantryMoveItems = "pantry_move_items"
    case pantryOutButton = "pantry_out_button"
    case pantryItemInStock = "pantry_item_in_stock"
    case pantryRepeatDaily = "pantry_repeat_daily"
    case pantryRepeatWeekly = "pantry_repeat_weekly"
    case pantryRepeatMonthly = "pantry_repeat_monthly"
    case pantryRepeatYearly = "pantry_repeat_yearly"
    case pantryRepeatCustom = "pantry_repeate_custom"
    case pantryRepeatReminder = "pantry_repeate_reminder"
    case pantryCreateItem = "pantry_create_item"
    case pantryCreateItemShop = "pantry_create_item_shop"
    case pantryCreateItemPrice = "pantry_create_item_price"
    case pantryCreateItemQty = "pantry_create_item_qty"
    case pantryCreateItemUnits = "pantry_create_item_units"
    case pantryCreateItemUncheck = "pantry_create_item_uncheck"
    case pantryCreateItemPhoto = "pantry_create_item_photo"
    case pantryCreateItemAutoPhoto = "pantry_create_item_autoPhoto"
    case pantryCreateItemDeletePhoto = "pantry_create_item_delete_photo"
    case pantryReminderWorked = "pantry_reminder_worked"
    case pantryReminderCheckbox = "pantry_reminder_checkbox"
    case pantryReminderAddToList = "pantry_reminder_add_to_list"
    case pantryContextDelete = "pantry_context_delete"
    case pantryContextEdit = "pantry_context_edit"
    
}

typealias PropertyKey = String
extension PropertyKey {
    static let value = "value"
    static let accountType = "account type"
    static let source = "source"
    static let subscribtionType = "subscribtion type"
    static let count = "count"
    static let isActive = "isActive"
    static let time = "Time"
}

typealias PropertyValue = String
extension PropertyValue {
    static let like = "like"
    static let dislike = "dislike"
    static let email = "email"
    static let apple = "apple"
    static let mainScreen = "main screen"
    static let recipe = "recipe"
    
    static let yearly = "yearly"
    static let monthly = "monthly"
    static let weekly = "weekly"
    
    static let yes = "yes"
    static let valueNo = "no"
    
    static let valueOn = "on"
    static let off = "off"
}

var idsOfChangedLists = Set<UUID>()
var idsOfChangedProducts = Set<UUID>()
