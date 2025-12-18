//
//  NotificationManager.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
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
