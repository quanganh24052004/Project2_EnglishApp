//
//  SettingsViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//

import SwiftUI
import Combine
import SwiftData

class SettingsViewModel: ObservableObject {
    @AppStorage("isMusicEnabled") var isMusicEnabled: Bool = true
    @AppStorage("musicVolume") var musicVolume: Double = 0.5
    // MARK: - Logic Reset Data
    func resetAllProgress() {
        print("ViewModel: Đã thực hiện lệnh xóa toàn bộ dữ liệu.")

    }
    
    func resetAllProgress(modelContext: ModelContext) {
        do {
            // 1. Xóa tất cả StudyRecord (Dữ liệu từ vựng đã học)
            try modelContext.delete(model: StudyRecord.self)
            
            // 2. Xóa tất cả LessonRecord (Tiến độ bài học)
            try modelContext.delete(model: LessonRecord.self)
            
            // 3. Lưu thay đổi vào Database
            try modelContext.save()
            
            // 4. Reset trạng thái Onboarding (để App coi như người dùng mới)
            UserDefaults.standard.set(false, forKey: "isOnboardingDone")
            
            // 5. Hủy toàn bộ thông báo nhắc nhở ôn tập
            NotificationManager.shared.cancelAllPendingNotifications()
            
            print("✅ Đã reset toàn bộ tiến độ học tập thành công!")
            
        } catch {
            print("❌ Lỗi khi reset dữ liệu: \(error.localizedDescription)")
        }
    }
}
