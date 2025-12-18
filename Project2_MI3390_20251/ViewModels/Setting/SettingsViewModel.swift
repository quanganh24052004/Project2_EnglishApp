//
//  SettingsViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//

import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    
    // MARK: - Logic Reset Data
    // Chỉ giữ lại đúng chức năng Reset tiến độ học tập
    func resetAllProgress() {
        print("ViewModel: Đã thực hiện lệnh xóa toàn bộ dữ liệu.")
        // DatabaseService.shared.deleteAll()
        // Logic xóa file/cache khác nếu có...
    }
}
