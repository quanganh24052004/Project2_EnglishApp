//
//  LessonViewModel.swift
//  Project2_EnglishApp
//
//
//

import SwiftUI
import Combine
import SwiftData
import Supabase

enum LearningStep {
    case flashcard
    case listenWrite
    case fillBlank
}

enum CheckResult {
    case correct
    case wrong(correctAnswer: String)
}

class LessonViewModel: ObservableObject {
    // MARK: - Properties
    let items: [LearningItem]
    
    @Published var retryQueue: [LearningItem] = []
    @Published var isRetryMode: Bool = false
    @Published var currentRetryItem: LearningItem?
    
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
    
    // MARK: - 1. Thêm hàm phát Audio (Dùng cho nút Loa ở các Game)
        func playCurrentAudio(speed: Float = 1.0) {
        let ttsSpeed: Float = (speed == 1.0) ? 0.5 : 0.2
        AudioManager.shared.playTTS(text: currentItem.word, language: "en-US", speed: ttsSpeed)
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
        AudioManager.shared.playFeedback(isCorrect: isCorrect)
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
    
    // MARK: - Navigation
    func moveToNextStage() {
        showFeedbackSheet = false
        
        if isRetryMode {
            if case .correct = currentFeedback {
                if !retryQueue.isEmpty {
                    retryQueue.removeFirst()
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
            currentStep = .flashcard
        } else {
            checkForRetryPhase()
        }
    }
    
    private func checkForRetryPhase() {
        if retryQueue.isEmpty {
            isLessonFinished = true
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
    
    // MARK: Lưu danh sách được chọn (Gọi từ SummarizeView)
    func saveSelectedWords(_ selectedIDs: Set<PersistentIdentifier>) {
        guard let manager = learningManager else { return }
        
        Task {
            let currentUser = await SupabaseAuthService.shared.currentUser
            let userID = currentUser?.id.uuidString
            
            await MainActor.run {
                for id in selectedIDs {
                    // 1. Gọi hàm markAsLearned và nhận về record
                    if let record = manager.markAsLearned(wordID: id, supabaseUserID: userID),
                       let word = record.word {
                        
                        // 2. 👇 THÊM MỚI: Hẹn giờ thông báo dựa trên nextReview của record
                        NotificationManager.shared.scheduleReviewNotification(
                            for: word,
                            at: record.nextReview
                        )
                    }
                }
                
                // (Tùy chọn) In log kiểm tra
                print("✅ Đã lưu \(selectedIDs.count) từ và hẹn giờ thông báo.")
            }
        }
    }
    
    // MARK: Helper Progress
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

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
