//
//  LessonViewModel.swift
//  Project2_EnglishApp
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//

import SwiftUI
import Combine
import SwiftData

// Định nghĩa các bước học
enum LearningStep {
    case flashcard      // 1. Xem thẻ, nghe
    case listenWrite    // 2. Nghe và Gõ lại (Đã nâng cấp với gợi ý mờ)
    case fillBlank      // 3. Điền từ còn thiếu
}

// Kết quả kiểm tra
enum CheckResult {
    case correct
    case wrong(correctAnswer: String)
}

class LessonViewModel: ObservableObject {
    // MARK: - Properties
    private let items: [LearningItem]
    
    @Published var currentItemIndex: Int = 0
    @Published var currentStep: LearningStep = .flashcard
    
    @Published var progress: Double = 0.0
    @Published var showFeedbackSheet: Bool = false
    @Published var currentFeedback: CheckResult? = nil
    @Published var isLessonFinished: Bool = false
    
    // Manager để lưu xuống SwiftData
    var learningManager: LearningManager?
    
    // Lấy từ vựng hiện tại
    var currentItem: LearningItem {
        items[currentItemIndex]
    }
    
    // MARK: - Init
    init(items: [LearningItem]) {
        self.items = items
        updateProgress()
    }
    
    // MARK: - Logic Kiểm Tra (Core Logic)
    
    // 1. Kiểm tra phần Nghe & Viết (Spelling Game)
    func checkListenWrite(userAnswer: String) {
        // Chuẩn hóa: Xóa khoảng trắng thừa, đưa về chữ thường
        let cleanInput = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanTarget = currentItem.word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let isCorrect = cleanInput == cleanTarget
        processResult(isCorrect: isCorrect, correctAnswer: currentItem.word)
    }
    
    // 2. Kiểm tra phần Điền từ (Fill Blank) - Giữ logic cũ hoặc tùy chỉnh
    func checkFillBlank(userAnswer: String) {
        let cleanInput = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanTarget = currentItem.word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let isCorrect = cleanInput == cleanTarget
        processResult(isCorrect: isCorrect, correctAnswer: currentItem.word)
    }
    
    // MARK: - Xử lý kết quả chung & Lưu Database
    private func processResult(isCorrect: Bool, correctAnswer: String) {
        
        // A. Cập nhật UI Feedback trước (để App phản hồi nhanh với người dùng)
        if isCorrect {
            currentFeedback = .correct
        } else {
            currentFeedback = .wrong(correctAnswer: correctAnswer)
        }
        showFeedbackSheet = true
        
        // B. Lưu tiến độ vào DB (SwiftData)
        if let manager = learningManager {
            // Không cần fetch "wordObject" thủ công nữa
            // Truyền thẳng ID có sẵn trong currentItem
            manager.updateProgress(wordID: currentItem.wordID, isCorrect: isCorrect)
            
            print("✅ Đã gửi yêu cầu lưu tiến độ cho từ ID: \(currentItem.wordID)")
        }
    }
    
    // MARK: - Navigation
    
    func moveToNextStage() {
        switch currentStep {
        case .flashcard:
            currentStep = .listenWrite
            
        case .listenWrite:
            currentStep = .fillBlank
            
        case .fillBlank:
            moveToNextWord()
        }
        updateProgress()
    }
    
    private func moveToNextWord() {
        if currentItemIndex < items.count - 1 {
            currentItemIndex += 1
            currentStep = .flashcard // Quay lại bước 1 cho từ mới
        } else {
            isLessonFinished = true // Hoàn thành bài học
        }
    }
    
    // MARK: - Helper tính Progress Bar
    private func updateProgress() {
        let totalSteps = Double(items.count * 3)
        let currentStepsDone = Double(currentItemIndex * 3) + stepIndex(currentStep)
        progress = totalSteps > 0 ? currentStepsDone / totalSteps : 0
    }
    
    private func stepIndex(_ step: LearningStep) -> Double {
        switch step {
        case .flashcard: return 0
        case .listenWrite: return 1
        case .fillBlank: return 2
        }
    }
}
