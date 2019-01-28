//  LocalNotification.swift
//  Birthday 2nd Edition
//  Copyright © 2017 Dmitry Alexandrov. All rights reserved.
//
import Foundation
import UserNotifications
import NotificationCenter

class LocalNotification
{
    private var content = UNMutableNotificationContent()
    private var request : UNNotificationRequest
    
    init(withTitle title : String = "Birthday", withSubTitle subTitle : String = "Don't Forget about the Event!", withText body : String = "", _ notificationID : String = "Birthday.EventReminder") {
        self.content.title = title
        self.content.subtitle = subTitle
        self.content.body = body
        self.content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        self.request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        // Schedule the notification
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func addNotif(withText body : String = "") {
        self.content.body = body
        // Schedule the notification
        UNUserNotificationCenter.current().add(self.request, withCompletionHandler: nil)
    }
    
//    convenience init(_ withText : String = "") {
//        self.init(withText)
//    }
    
}
