//
//  NotificationManager.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//

import Foundation
import UserNotifications
import UIKit
import SwiftData

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
        
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleReviewNotification(for word: Word, at date: Date) {
        cancelNotification(for: word)
        
        let content = UNMutableNotificationContent()
        content.title = "Đến giờ ôn bài rồi! ⏰"
        content.body = "Từ vựng '\(word.english)' đang chờ bạn ôn lại để ghi nhớ lâu hơn."
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "\(word.persistentModelID)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Lỗi đặt thông báo: \(error.localizedDescription)")
            } else {
                print("📅 Đã hẹn giờ ôn '\(word.english)' vào lúc: \(date.formatted())")
            }
        }
    }
    
    func cancelNotification(for word: Word) {
        let identifier = "\(word.persistentModelID)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Đã hủy toàn bộ lịch nhắc nhở")
    }
}
