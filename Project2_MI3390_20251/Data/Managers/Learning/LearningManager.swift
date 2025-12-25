//
//  LearningManager.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 17/12/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class LearningManager {
    let modelContext: ModelContext
    
    // Cache user để tối ưu hiệu năng
    private var cachedUser: User?
    
        
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - 1. Helper: Định nghĩa thời gian cho từng cấp
    // Cấp 0 -> 1: 10 phút
    // Cấp 1 -> 2: 1 tiếng
    // Cấp 2 -> 3: 1 ngày
    // Cấp 3 -> 4: 3 ngày
    // Cấp 4 -> 5: 7 ngày
    private func getInterval(forCurrentLevel level: Int) -> TimeInterval {
        switch level {
        case 0: return 1 * 60          // 10 phút
        case 1: return 60 * 60          // 1 tiếng
        case 2: return 24 * 60 * 60     // 1 ngày
        case 3: return 3 * 24 * 60 * 60 // 3 ngày
        case 4: return 7 * 24 * 60 * 60 // 7 ngày
        case 5: return 7 * 24 * 60 * 60 // Max level: giữ nguyên 7 ngày (hoặc lâu hơn tùy bạn)
        default: return 10 * 60
        }
    }
    
    // MARK: - 2. Xử lý khi Học xong bài mới (Learn Mode)
    func markAsLearned(wordID: PersistentIdentifier) {
        guard let word = modelContext.model(for: wordID) as? Word else { return }
        
        // Kiểm tra xem đã tồn tại record chưa
        let descriptor = FetchDescriptor<StudyRecord>(
            predicate: #Predicate { $0.word?.persistentModelID == wordID }
        )
        
        if let existingRecord = try? modelContext.fetch(descriptor).first {
            // Nếu đã tồn tại thì không reset về 0, giữ nguyên tiến độ cũ
            print("ℹ️ Từ '\(word.english)' đã tồn tại ở Level \(existingRecord.memoryLevel).")
            return
        }
        
        // Nếu chưa có -> Tạo mới Level 0
        let user = getCurrentUser()
        let newRecord = StudyRecord(user: user, word: word)
        newRecord.memoryLevel = 0
        newRecord.lastReview = Date()
        
        // Hẹn giờ ôn tập lần đầu: Sau 10 phút (từ Cấp 0 -> 1)
        let nextDate = Date().addingTimeInterval(getInterval(forCurrentLevel: 0))
        newRecord.nextReview = nextDate
        
        modelContext.insert(newRecord)
        
        // Lưu DB và Đặt thông báo
        saveContext()
        
        // 🔔 THÔNG BÁO: Hẹn giờ nhắc nhở lần đầu
        NotificationManager.shared.scheduleReviewNotification(for: word, at: nextDate)
        print("🔔 Đã hẹn giờ ôn '\(word.english)' sau 10 phút.")
    }
    
    // MARK: - 3. Xử lý khi Ôn tập (Review Mode)
        func processReviewResult(record: StudyRecord, isCorrect: Bool) {
        let now = Date()
        record.lastReview = now
        
        if isCorrect {
            // RULE: Trả lời đúng -> Tăng 1 cấp và setup thời gian ôn tập
            // Nếu đang là 0 -> lên 1. Tính thời gian từ 1 -> 2
            let currentLevel = record.memoryLevel
            let nextLevel = min(currentLevel + 1, 5) // Max là 5
            
            record.memoryLevel = nextLevel
            
            // Tính thời gian dựa trên cấp VỪA ĐẠT ĐƯỢC
            // Ví dụ: Vừa lên Level 1 -> Cần đợi 1 tiếng để lên Level 2
            // Logic của bạn: Cấp 1 -> 2: 1 tiếng.
            // Lưu ý: interval function tôi viết nhận vào "Current Level" để tính next deadline
            record.nextReview = now.addingTimeInterval(getInterval(forCurrentLevel: nextLevel))
            
            print("✅ Đúng: '\(record.word?.english ?? "")' lên Level \(nextLevel)")
            
        } else {
            // RULE: Trả lời sai -> Giữ nguyên cấp và reset lại thời gian
            let currentLevel = record.memoryLevel
            
            // Cấp giữ nguyên, nhưng phải ôn lại.
            // Thời gian chờ = Thời gian quy định của cấp hiện tại
            record.nextReview = now.addingTimeInterval(getInterval(forCurrentLevel: currentLevel))
            
            print("❌ Sai: '\(record.word?.english ?? "")' giữ Level \(currentLevel)")
        }
        
        saveContext()
    }
    
    private func saveContext() {
        do { try modelContext.save() } catch { print("Save error: \(error)") }
    }
    // MARK: - Helper lấy User
    private func getCurrentUser() -> User {
        if let cached = cachedUser { return cached }
        
        let descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            self.cachedUser = user
            return user
        }
        
        let newUser = User(name: "Learner", phone: "")
        modelContext.insert(newUser)
        try? modelContext.save()
        self.cachedUser = newUser
        return newUser
    }
    
    // MARK: - Main Function: Update Progress
    func updateProgress(wordID: PersistentIdentifier, isCorrect: Bool) {
        // 1. Tìm từ trong DB
        guard let word = modelContext.model(for: wordID) as? Word else {
            print("❌ Error: Word not found for ID \(wordID)")
            return
        }
        
        let user = getCurrentUser()
        
        // 2. Tìm hoặc Tạo StudyRecord
        let record: StudyRecord
        // So sánh ID an toàn hơn so sánh object
        if let existingRecord = word.studyRecords.first(where: { $0.user?.persistentModelID == user.persistentModelID }) {
            record = existingRecord
        } else {
            record = StudyRecord(user: user, word: word)
            modelContext.insert(record)
            record.word = word
            record.user = user
        }
        
        // 3. Tính toán ngày ôn tiếp theo (Logic mới theo giờ/ngày)
        calculateNextReview(for: record, isCorrect: isCorrect)
        
        // 4. Lưu xuống DB
        do {
            try modelContext.save()
            print("✅ Saved: \(word.english) | Level: \(record.memoryLevel) | Next: \(record.nextReview.formatted())")
        } catch {
            print("❌ Error saving progress: \(error.localizedDescription)")
        }
    }
    
    // MARK: - SRS Logic (Refactored)
    private func calculateNextReview(for record: StudyRecord, isCorrect: Bool) {
        record.lastReview = Date()
        record.updatedAt = Date()
        
        if isCorrect {
            record.memoryLevel = min(record.memoryLevel + 1, 5)
            
            record.nextReview = getNextReviewDate(currentLevel: record.memoryLevel)
            
        } else {
            record.memoryLevel = 1
            
            record.nextReview = Date()
        }
    }
    
    // MARK: - Logic Thời Gian (Core Changes)
    private func getNextReviewDate(currentLevel: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch currentLevel {
        case 2: // Vừa lên Level 2 -> Ôn lại sau 1 GIỜ
            return calendar.date(byAdding: .hour, value: 1, to: now) ?? now
            
        case 3: // Vừa lên Level 3 -> Ôn lại sau 12 GIỜ
            return calendar.date(byAdding: .hour, value: 12, to: now) ?? now
            
        case 4: // Vừa lên Level 4 -> Ôn lại sau 1 NGÀY
            return calendar.date(byAdding: .day, value: 1, to: now) ?? now
            
        case 5: // Vừa lên Level 5 -> Ôn lại sau 5 NGÀY
            return calendar.date(byAdding: .day, value: 5, to: now) ?? now
            
        default:
            return calendar.date(byAdding: .minute, value: 10, to: now) ?? now
        }
    }
}
