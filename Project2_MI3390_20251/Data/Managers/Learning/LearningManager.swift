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
