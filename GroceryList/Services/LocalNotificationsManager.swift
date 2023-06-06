//
//  LocalNotificationsManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 05.06.2023.
//

import Foundation
import UserNotifications

class LocalNotificationsManager {
    
    static var shared = LocalNotificationsManager()
    
    struct NotificationRequestModel {
        let id: String
        let title: String
        let subtitle: String
        let autoRepeat: StockAutoRepeat
        let times: Int?
        let weekday: Int?
        let period: RepeatPeriods?
    }
    
    private(set) var isAllowedNotifications = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestUserNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                print("Error on notification setup: \(error.localizedDescription)")
            }
        }
    }
    
    func addNotification(_ request: NotificationRequestModel) {
        let content = UNMutableNotificationContent()
        content.title = request.title
        content.subtitle = request.subtitle
        content.sound = .default
        
        var triggerNotify: UNNotificationTrigger?
        switch request.autoRepeat {
        case .custom:
            triggerNotify = setTimeTrigger(request: request)
        default:
            triggerNotify = setCalendarTrigger(request: request)
        }
        
        let request = UNNotificationRequest(identifier: request.id, content: content, trigger: triggerNotify)
        notificationCenter.add(request)
    }
    
    func checkAllowedNotifications() {
        notificationCenter.getNotificationSettings { (settings) in
            self.isAllowedNotifications = settings.authorizationStatus == .authorized
        }
    }
    
    func removeNotification(with id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func removeAllNotification() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    private func setCalendarTrigger(request: NotificationRequestModel) -> UNCalendarNotificationTrigger? {
        var date = DateComponents()
        date.hour = 10
        switch request.autoRepeat {
        case .daily:
            break
        case .weekly:
            date.weekday = Date().dayNumberOfWeek
        case .monthly:
            date.day = Date().day
        case .yearly:
            date.month = Date().month
            date.day = Date().day
        case .custom:
            return nil
        }
        
        return UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
    }
    
    private func setTimeTrigger(request: NotificationRequestModel) -> UNTimeIntervalNotificationTrigger? {
        guard request.autoRepeat == .custom,
              let period = request.period else {
            return nil
        }
        var timeInterval = TimeInterval()
        let times = request.times ?? 1
        let secInDay = 60 * 60 * 24
        switch period {
        case .days:
            timeInterval = TimeInterval(times * secInDay)
        case .weeks:
            timeInterval = TimeInterval(times * 7 * secInDay)
        case .months:
            timeInterval = TimeInterval(times * 30 * secInDay)
        case .years:
            timeInterval = TimeInterval(times * 365 * secInDay)
        }
        return UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
    }
}
