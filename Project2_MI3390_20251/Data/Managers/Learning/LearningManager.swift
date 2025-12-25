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
    private func getInterval(forCurrentLevel level: Int) -> TimeInterval {
        switch level {
        case 0: return 10 * 60
        case 1: return 60 * 60          
        case 2: return 24 * 60 * 60
        case 3: return 3 * 24 * 60 * 60
        case 4: return 7 * 24 * 60 * 60
        case 5: return 7 * 24 * 60 * 60
        default: return 10 * 60
        }
    }
    
    // MARK: - 2. Xử lý khi Học xong bài mới (Learn Mode)
    func markAsLearned(wordID: PersistentIdentifier) {
        guard let word = modelContext.model(for: wordID) as? Word else { return }
        
        let descriptor = FetchDescriptor<StudyRecord>(
            predicate: #Predicate { $0.word?.persistentModelID == wordID }
        )
        
        if let existingRecord = try? modelContext.fetch(descriptor).first {
            print("ℹ️ Từ '\(word.english)' đã tồn tại ở Level \(existingRecord.memoryLevel).")
            return
        }
        
        let user = getCurrentUser()
        let newRecord = StudyRecord(user: user, word: word)
        newRecord.memoryLevel = 0
        newRecord.lastReview = Date()
        
        let nextDate = Date().addingTimeInterval(getInterval(forCurrentLevel: 0))
        newRecord.nextReview = nextDate
        
        modelContext.insert(newRecord)
        
        saveContext()
        
        NotificationManager.shared.scheduleReviewNotification(for: word, at: nextDate)
        print("🔔 Đã hẹn giờ ôn '\(word.english)' sau 10 phút.")
    }
    
    // MARK: - 3. Xử lý khi Ôn tập (Review Mode)
        func processReviewResult(record: StudyRecord, isCorrect: Bool) {
        let now = Date()
        record.lastReview = now
        
        if isCorrect {
            let currentLevel = record.memoryLevel
            let nextLevel = min(currentLevel + 1, 5) // Max là 5
            
            record.memoryLevel = nextLevel
            
            record.nextReview = now.addingTimeInterval(getInterval(forCurrentLevel: nextLevel))
            
            print("✅ Đúng: '\(record.word?.english ?? "")' lên Level \(nextLevel)")
            
        } else {
            let currentLevel = record.memoryLevel
            
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
        guard let word = modelContext.model(for: wordID) as? Word else {
            print("❌ Error: Word not found for ID \(wordID)")
            return
        }
        
        let user = getCurrentUser()
        
        let record: StudyRecord
        
        if let existingRecord = word.studyRecords.first(where: { $0.user?.persistentModelID == user.persistentModelID }) {
            record = existingRecord
        } else {
            record = StudyRecord(user: user, word: word)
            modelContext.insert(record)
            record.word = word
            record.user = user
        }
        
        calculateNextReview(for: record, isCorrect: isCorrect)
        
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
        case 2:
            return calendar.date(byAdding: .hour, value: 1, to: now) ?? now
            
        case 3:
            return calendar.date(byAdding: .hour, value: 12, to: now) ?? now
            
        case 4:
            return calendar.date(byAdding: .day, value: 1, to: now) ?? now
            
        case 5:
            return calendar.date(byAdding: .day, value: 5, to: now) ?? now
            
        default:
            return calendar.date(byAdding: .minute, value: 10, to: now) ?? now
        }
    }
}
