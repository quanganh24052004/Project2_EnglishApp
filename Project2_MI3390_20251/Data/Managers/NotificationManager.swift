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
        
    // 1. Xin quyền thông báo (Gọi ở App init)
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // 2. Lên lịch thông báo ôn tập
    func scheduleReviewNotification(for word: Word, at date: Date) {
        // Hủy thông báo cũ của từ này (nếu có) để tránh trùng lặp
        cancelNotification(for: word)
        
        let content = UNMutableNotificationContent()
        content.title = "Đến giờ ôn bài rồi! ⏰"
        content.body = "Từ vựng '\(word.english)' đang chờ bạn ôn lại để ghi nhớ lâu hơn."
        content.sound = .default
        
        // Tạo Trigger theo ngày giờ cụ thể
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // ID duy nhất dựa trên ID của từ vựng
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
    
    // 3. Hủy thông báo (Khi user đã học xong hoặc reset)
    func cancelNotification(for word: Word) {
        let identifier = "\(word.persistentModelID)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // 4. (Tùy chọn) Hủy tất cả
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    // 1. Xin quyền thông báo
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // 2. Kiểm tra trạng thái hiện tại (Đã cấp, Từ chối, hay Chưa hỏi)
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // 3. Mở Cài đặt của iPhone (Dành cho trường hợp user đã chặn trước đó)
    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // 4. Hủy hết thông báo đang chờ (Khi user tắt toggle)
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Đã hủy toàn bộ lịch nhắc nhở")
    }
}
