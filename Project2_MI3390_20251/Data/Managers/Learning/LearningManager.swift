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
    
    // MARK: - 1. API: Đánh dấu đã học (Cập nhật nhận thêm supabaseUserID)
    func markAsLearned(wordID: PersistentIdentifier, supabaseUserID: String?) {
        guard let word = modelContext.model(for: wordID) as? Word else { return }
        
        let targetUser: User
        
        // 1. Xác định User mục tiêu
        if let id = supabaseUserID {
            // Case A: Có ID (Đã đăng nhập) -> Tìm user thật
            if let realUser = UserSyncManager.shared.getCurrentLocalUser(supabaseID: id, in: modelContext) {
                targetUser = realUser
            } else {
                // Fallback: Có ID nhưng không tìm thấy trong DB -> return hoặc dùng Guest
                print("❌ Error: Logged in but user not found in DB")
                return
            }
        } else {
            // Case B: Không có ID (Chưa đăng nhập/Nil) -> Lấy user Khách
            targetUser = UserSyncManager.shared.getGuestUser(in: modelContext)
        }
        
        // 2. Logic lưu Record (Giữ nguyên)
        let existingRecord = targetUser.studyRecords.first { $0.word?.persistentModelID == wordID }
        
        if let record = existingRecord {
            print("⚠️ [User: \(targetUser.name)] Word already learned. Resetting.")
            // Gọi hàm resetProgress private của bạn
            resetProgress(for: record)
        } else {
            let newRecord = StudyRecord(user: targetUser, word: word)
            newRecord.memoryLevel = 0
            newRecord.lastReview = Date()
            // Gọi hàm tính ngày private của bạn
            newRecord.nextReview = calculateNextReviewDate(forLevel: 0)
            
            targetUser.studyRecords.append(newRecord)
            modelContext.insert(newRecord)
            print("✅ [User: \(targetUser.name)] Marked as learned: \(word.english)")
        }
            
        do {
            try modelContext.save()
        } catch {
            print("❌ Save Error: \(error)")
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
    
    // MARK: - 5. API: Lấy danh sách từ đã học (Có lọc theo User)
    // Dùng hàm này cho màn hình danh sách từ vựng (Notebook)
    func fetchLearnedItems(for userID: String?) -> [StudyRecord] {
        // Xác định ID cần lấy (Nếu nil -> Lấy của Guest)
        let targetID = userID ?? "guest_user_id"
        
        let descriptor = FetchDescriptor<StudyRecord>(
            predicate: #Predicate { record in
                // Chỉ lấy record của User đó
                record.user?.id == targetID
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error fetching learned items: \(error)")
            return []
        }
    }
}
