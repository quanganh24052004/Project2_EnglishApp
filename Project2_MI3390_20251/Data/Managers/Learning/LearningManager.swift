//
//  LearningManager.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 17/12/25.
//  
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class LearningManager {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - 1. API: Đánh dấu đã học từ mới (Learn Mode)
    func markAsLearned(wordID: PersistentIdentifier) {
        guard let word = modelContext.model(for: wordID) as? Word else { return }
        
        // Kiểm tra xem đã có record chưa để tránh tạo trùng
        let descriptor = FetchDescriptor<StudyRecord>(
            predicate: #Predicate { $0.word?.persistentModelID == wordID }
        )
        
        do {
            if let existingRecord = try modelContext.fetch(descriptor).first {
                print("⚠️ Record already exists for \(word.english). Resetting.")
                resetProgress(for: existingRecord)
            } else {
                // Tạo record mới (Level 0)
                let newRecord = StudyRecord(user: User(name: "Default", phone: ""), word: word)
                newRecord.memoryLevel = 0
                newRecord.lastReview = Date()
                newRecord.nextReview = calculateNextReviewDate(forLevel: 0)
                
                modelContext.insert(newRecord)
                print("✅ Created new SRS record for: \(word.english)")
            }
            
            try modelContext.save()
        } catch {
            print("❌ Error marking as learned: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 2. API: Xử lý kết quả Ôn tập (Review Mode)
    func processReviewResult(for record: StudyRecord, isCorrect: Bool) {
        record.lastReview = Date()
        record.updatedAt = Date()
        
        if isCorrect {
            // TRƯỜNG HỢP ĐÚNG: Tăng cấp (Max 5)
            let nextLevel = min(record.memoryLevel + 1, 5)
            record.memoryLevel = nextLevel
            record.nextReview = calculateNextReviewDate(forLevel: nextLevel)
            
            print("📈 Correct! Upgraded to Level \(nextLevel). Next review: \(record.nextReview.formatted())")
            
        } else {
            // TRƯỜNG HỢP SAI (Logic Mới):
            // Thay vì phạt về 0, ta giữ nguyên Level và lên lịch ôn lại theo đúng interval của Level đó.
            // Ví dụ: Đang Level 4 (7 ngày) -> Trả lời sai -> Vẫn Level 4 -> Ôn lại sau 7 ngày.
            
            // Giữ nguyên level (Code tường minh, dù không gán cũng được)
            let currentLevel = record.memoryLevel
            record.memoryLevel = currentLevel
            
            // Tính lại ngày review dựa trên Level hiện tại (Không phải Date() ngay lập tức)
            record.nextReview = calculateNextReviewDate(forLevel: currentLevel)
            
            print("🔁 Wrong! Kept at Level \(currentLevel). Next review: \(record.nextReview.formatted())")
        }
        
        // Lưu xuống DB
        do {
            try modelContext.save()
        } catch {
            print("❌ Error saving review result: \(error)")
        }
    }
    
    // MARK: - 3. Helper: Reset Progress (Dùng khi học lại từ đầu hoàn toàn)
    private func resetProgress(for record: StudyRecord) {
        record.memoryLevel = 0
        record.lastReview = Date()
        record.nextReview = calculateNextReviewDate(forLevel: 0)
    }
    
    // MARK: - 4. SRS CORE LOGIC (Tính toán thời gian)
    private func calculateNextReviewDate(forLevel level: Int) -> Date {
        let now = Date()
        let calendar = Calendar.current
        
        switch level {
        case 0:
            // Level 0 (Mới/Quên): 10 phút
            return now.addingTimeInterval(10 * 60)
            
        case 1:
            // Level 1: 1 giờ
            return now.addingTimeInterval(60 * 60)
            
        case 2:
            // Level 2: 1 ngày
            return calendar.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(86400)
            
        case 3:
            // Level 3: 3 ngày
            return calendar.date(byAdding: .day, value: 3, to: now) ?? now.addingTimeInterval(3 * 86400)
            
        case 4:
            // Level 4: 7 ngày
            return calendar.date(byAdding: .day, value: 7, to: now) ?? now.addingTimeInterval(7 * 86400)
            
        case 5:
            // Level 5 (Master): 15 ngày
            return calendar.date(byAdding: .day, value: 15, to: now) ?? now.addingTimeInterval(15 * 86400)
            
        default:
            return now.addingTimeInterval(24 * 60 * 60)
        }
    }
}
