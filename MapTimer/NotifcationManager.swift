//
//  NotifcationManager.swift
//  MapTimer
//
//  Created by Jack Kroll on 4/4/25.
//

import UserNotifications
import SwiftUI



class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .badge, .sound])
        }
}

func addNotification(time: Double, title: String, subtitle: String, body: String) {
    let center = UNUserNotificationCenter.current()

    let addRequest = {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    center.getNotificationSettings { settings in
        if settings.authorizationStatus == .authorized {
            addRequest()
        } else {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    addRequest()
                } else {
                    print("Authorization declined")
                }
            }
        }
    }
}
