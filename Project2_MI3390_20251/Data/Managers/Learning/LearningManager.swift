//
//  LearningManager.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 17/12/25.
//


import Foundation
import SwiftData

import Foundation
import SwiftData

@MainActor
class LearningManager {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Hàm tìm User hiện tại (Tạm thời lấy User đầu tiên hoặc tạo mới nếu chưa có)
    private func getCurrentUser() -> User {
        let descriptor = FetchDescriptor<User>()
        if let users = try? modelContext.fetch(descriptor), let user = users.first {
            return user
        }
        // Nếu chưa có user nào, tạo user mặc định
        let newUser = User(name: "Default User", phone: "")
        modelContext.insert(newUser)
        return newUser
    }
    
    // MARK: - Logic Cập Nhật Tiến Độ
    func updateProgress(wordID: PersistentIdentifier, isCorrect: Bool) {
        // 1. Tìm lại object Word từ ID
        guard let word = modelContext.model(for: wordID) as? Word else { return }
        let user = getCurrentUser()
        
        // 2. Tìm StudyRecord cũ hoặc tạo mới
        let record: StudyRecord
        if let existingRecord = word.studyRecords.first(where: { $0.user == user }) {
            record = existingRecord
        } else {
            record = StudyRecord(user: user, word: word)
            modelContext.insert(record)
            // Gán quan hệ
            record.word = word
            record.user = user
        }
        
        // 3. Thuật toán tăng giảm Level (SRS đơn giản)
        if isCorrect {
            if record.memoryLevel < 5 {
                record.memoryLevel += 1
            }
            // Tính ngày ôn tiếp theo: Level càng cao, ngày ôn càng xa
            let daysToAdd = getInterval(level: record.memoryLevel)
            record.nextReview = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date()
        } else {
            // Trả lời sai: Reset về 1 hoặc giữ nguyên tùy độ khó bạn muốn
            record.memoryLevel = 1
            record.nextReview = Date() // Ôn lại ngay
        }
        
        record.lastReview = Date()
        record.updatedAt = Date()
        
        // 4. Lưu vào DB
        try? modelContext.save()
        print("Đã lưu tiến độ cho từ: \(word.english) - Level mới: \(record.memoryLevel)")
    }
    
    private func getInterval(level: Int) -> Int {
        switch level {
        case 1: return 1   // 1 ngày
        case 2: return 3   // 3 ngày
        case 3: return 7   // 1 tuần
        case 4: return 14  // 2 tuần
        case 5: return 30  // 1 tháng
        default: return 0
        }
    }
}
