//
//  Functionallity.swift
//  LeoChat
//
//  Created by Roman Shveda on 4/24/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import Foundation
import UserNotifications
import CoreData
import UIKit

class Functionallity {
    static var counter = 0
    
    static func setNotification(with message: Message) {
        let identifier = Functionallity.counter
        Functionallity.counter+=1
        let content = UNMutableNotificationContent()
        content.title = (message.userTo?.login)!
        content.body = message.text!
        content.badge = 1
        content.sound = UNNotificationSound.default()
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(identifier)", content: content, trigger: triger)
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("Notification wasn't set")
            } else {
                // Request was added successfully
                print("notification added successfully")
            }
        }
        
    }
    
    static func getContext() ->NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return NSManagedObjectContext()}
        return appDelegate.persistentContainer.viewContext
    }
}
