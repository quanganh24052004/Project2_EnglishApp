//
//  SettingsViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//


import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    
    // MARK: - Business Logic
    
    /// Hàm xử lý xóa toàn bộ dữ liệu học tập
    func resetAllProgress() {
        // 1. Xóa trong CoreData / Realm / SQLite
        // DatabaseService.shared.deleteAll() -> Giả định bạn có service này
        
        // 2. Xóa các file cache nếu cần
        
        // 3. Log để debug
        print("ViewModel: Đã thực hiện lệnh xóa toàn bộ dữ liệu.")
    }
    
    // NOTE: Với @AppStorage (UserDefaults), ta thường giữ ở View cho tiện lợi vì nó hỗ trợ Binding trực tiếp.
    // Tuy nhiên, nếu logic phức tạp, bạn có thể tạo một UserPreferencesService riêng.
}

extension Bundle {
    // Lấy số phiên bản hiển thị (Version - ví dụ: 1.0.0)
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    // Lấy số Build (Build number - ví dụ: 1, 2, 20231025)
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }
    
    // Lấy chuỗi đầy đủ: "1.0.0 (1)"
    var fullAppVersion: String {
        return "\(appVersion) (\(buildNumber))"
    }
}
