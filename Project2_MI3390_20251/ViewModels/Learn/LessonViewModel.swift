//
//  LessonViewModel.swift
//  Project2_EnglishApp
//
//  Refactored by Mentor: Defer saving to SummarizeView
//

import SwiftUI
import Combine
import SwiftData

// Định nghĩa các bước học
enum LearningStep {
    case flashcard      // 1. Xem thẻ
    case listenWrite    // 2. Nghe & Viết
    case fillBlank      // 3. Điền từ
}

// Kết quả kiểm tra
enum CheckResult {
    case correct
    case wrong(correctAnswer: String)
}

class LessonViewModel: ObservableObject {
    // MARK: - Properties
    let items: [LearningItem] // Public để View tổng kết truy cập được
    
    // --- LOGIC HÀNG ĐỢI (RETRY QUEUE) ---
    @Published var retryQueue: [LearningItem] = [] // Danh sách từ làm sai
    @Published var isRetryMode: Bool = false       // Đang ở chế độ học lại?
    @Published var currentRetryItem: LearningItem? // Từ đang được học lại
    
    @Published var currentItemIndex: Int = 0
    @Published var currentStep: LearningStep = .flashcard
    
    @Published var progress: Double = 0.0
    @Published var showFeedbackSheet: Bool = false
    @Published var currentFeedback: CheckResult? = nil
    @Published var isLessonFinished: Bool = false
    
    var learningManager: LearningManager?
    
    var currentItem: LearningItem {
        if isRetryMode {
            return currentRetryItem ?? items[0]
        } else {
            return items[safe: currentItemIndex] ?? items[0]
        }
    }
    
    // MARK: - Init
    init(items: [LearningItem], manager: LearningManager? = nil) {
        self.items = items
        self.learningManager = manager
        updateProgress()
    }
    
    // MARK: - Logic Kiểm Tra
    func checkListenWrite(userAnswer: String) {
        let isCorrect = cleanAndCompare(input: userAnswer, target: currentItem.word)
        handleAnswerResult(isCorrect: isCorrect)
    }
    
    func checkFillBlank(userAnswer: String) {
        let isCorrect = cleanAndCompare(input: userAnswer, target: currentItem.word)
        handleAnswerResult(isCorrect: isCorrect)
    }
    
    private func handleAnswerResult(isCorrect: Bool) {
        if isCorrect {
            currentFeedback = .correct
        } else {
            currentFeedback = .wrong(correctAnswer: currentItem.word)
            addToRetryQueue(item: currentItem)
        }
        showFeedbackSheet = true
    }
    
    private func addToRetryQueue(item: LearningItem) {
        if !retryQueue.contains(where: { $0.id == item.id }) {
            retryQueue.append(item)
        }
    }
    
    private func cleanAndCompare(input: String, target: String) -> Bool {
        return input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
               target.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    // MARK: - Navigation (CORE LOGIC ĐÃ SỬA)
    func moveToNextStage() {
        showFeedbackSheet = false
        
        // --- 1. Retry Mode ---
        if isRetryMode {
            if case .correct = currentFeedback {
                if !retryQueue.isEmpty {
                    retryQueue.removeFirst()
                    // ⚠️ Đã XÓA dòng lưu DB ở đây
                }
            } else {
                if let failedItem = currentRetryItem {
                    retryQueue.append(failedItem)
                    retryQueue.removeFirst()
                }
            }
            loadNextRetryItem()
            return
        }
        
        // --- 2. Normal Mode ---
        switch currentStep {
        case .flashcard:
            currentStep = .listenWrite
            
        case .listenWrite:
            currentStep = .fillBlank
            
        case .fillBlank:
            // ⚠️ QUAN TRỌNG: Học xong từ này -> Chuyển từ tiếp theo
            // KHÔNG LƯU DB Ở ĐÂY NỮA
            moveToNextWord()
        }
        
        updateProgress()
    }
    
    private func moveToNextWord() {
        if currentItemIndex < items.count - 1 {
            currentItemIndex += 1
            currentStep = .flashcard
        } else {
            checkForRetryPhase()
        }
    }
    
    private func checkForRetryPhase() {
        if retryQueue.isEmpty {
            isLessonFinished = true // Hiện SummarizeView
        } else {
            isRetryMode = true
            loadNextRetryItem()
        }
    }
    
    private func loadNextRetryItem() {
        if retryQueue.isEmpty {
            isLessonFinished = true
            return
        }
        currentRetryItem = retryQueue.first
        currentStep = Bool.random() ? .listenWrite : .fillBlank
        updateProgress()
    }
    
    // MARK: - NEW: Lưu danh sách được chọn (Gọi từ SummarizeView)
    func saveSelectedWords(_ selectedIDs: Set<PersistentIdentifier>) {
        guard let manager = learningManager else { return }
        
        print("💾 Đang lưu \(selectedIDs.count) từ vào sổ tay...")
        
        for id in selectedIDs {
            // Gọi hàm Manager để tạo Record Level 0 và đặt lịch thông báo
            manager.markAsLearned(wordID: id)
        }
    }
    
    // MARK: - Helper Progress
    private func updateProgress() {
        let totalSteps = Double(items.count * 3)
        var currentStepsDone = Double(currentItemIndex * 3) + stepIndex(currentStep)
        if isRetryMode { currentStepsDone = totalSteps }
        
        withAnimation {
            progress = totalSteps > 0 ? min(currentStepsDone / totalSteps, 1.0) : 0
        }
    }
    
    private func stepIndex(_ step: LearningStep) -> Double {
        switch step {
        case .flashcard: return 0
        case .listenWrite: return 1
        case .fillBlank: return 2
        }
    }
}

// Extension an toàn
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
