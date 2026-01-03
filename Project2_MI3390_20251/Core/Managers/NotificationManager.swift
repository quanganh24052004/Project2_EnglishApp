//
//  NotificationManager.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//  Refactored for Aggregated Notifications (Group by Time)
//

import Foundation
import UserNotifications
import UIKit
import SwiftData

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
        
    // MARK: - Permissions
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Scheduling
    
    /// Lên lịch thông báo ôn tập (Tự động gộp các từ có cùng giờ ôn thành 1 thông báo)
    /// - Parameters:
    ///   - word: Từ vựng cần ôn (dùng để log hoặc mở rộng sau này)
    ///   - date: Thời gian ôn tập
    func scheduleReviewNotification(for word: Word, at date: Date) {
        // 1. Làm tròn thời gian về phút (bỏ giây) để gom nhóm các từ cùng phút
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.second = 0
        
        guard let normalizedDate = calendar.date(from: components) else { return }
        let timestamp = Int(normalizedDate.timeIntervalSince1970)
        
        // Identifier dựa trên thời gian (Thay vì ID của từ)
        let identifier = "REVIEW_SESSION_\(timestamp)"
        
        // Key để lưu số lượng từ cho khung giờ này trong UserDefaults
        let countKey = "NOTIF_COUNT_\(timestamp)"
        
        // 2. Tăng biến đếm số lượng từ cho khung giờ này
        // Sử dụng UserDefaults để xử lý đồng bộ, tránh lỗi race condition khi vòng lặp chạy nhanh
        let currentCount = UserDefaults.standard.integer(forKey: countKey)
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: countKey)
        
        // 3. Tạo nội dung thông báo mới
        let content = UNMutableNotificationContent()
        content.title = "⏰ Đã tới giờ ôn tập!"
        content.body = "Có \(newCount) từ cần ôn trong phiên này. Hãy vào học ngay nhé!"
        content.sound = .default
        // Lưu lại timestamp để xử lý logic khi người dùng bấm vào (nếu cần)
        content.userInfo = ["timestamp": timestamp]
        
        // 4. Tạo Trigger theo thời gian
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // 5. Tạo Request (Ghi đè lên thông báo cũ cùng ID để cập nhật số lượng)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Lỗi khi hẹn giờ: \(error.localizedDescription)")
            } else {
                print("📅 Đã cập nhật lịch ôn: \(normalizedDate.formatted()) | Tổng số: \(newCount) từ")
            }
        }
    }
    
    // MARK: - Management
    
    /// Hủy thông báo của một khung giờ cụ thể (nếu cần)
    func cancelNotification(at date: Date) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.second = 0
        
        guard let normalizedDate = calendar.date(from: components) else { return }
        let timestamp = Int(normalizedDate.timeIntervalSince1970)
        let identifier = "REVIEW_SESSION_\(timestamp)"
        
        // Xóa thông báo pending
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // Reset count trong UserDefaults
        let countKey = "NOTIF_COUNT_\(timestamp)"
        UserDefaults.standard.removeObject(forKey: countKey)
    }
    
    /// Hủy toàn bộ thông báo và reset bộ đếm
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Xóa các key đếm trong UserDefaults (Lọc theo prefix "NOTIF_COUNT_")
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key.hasPrefix("NOTIF_COUNT_") {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        
        print("🗑️ Đã hủy toàn bộ lịch nhắc nhở và reset bộ đếm.")
    }

    // MARK: - Helpers & Settings
    
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
}
