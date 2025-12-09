//
//  LessonViewModel.swift
//  DemoQuaTrinhHoc1Tu
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//
import SwiftUI
import Combine

enum LearningStep{
    case flashcard      // Xem thẻ, nghe
    case listenWrite    // Nghe và chép lại
    case fillBlank      // Điền từ vào chỗ trống
}

enum CheckResult {
    case correct
    case wrong(correctAnswer: String)
}

class LessonViewModel: ObservableObject {
    // SỬA 1: Dùng LearningItem thay vì Word
    private let items: [LearningItem]
    
    @Published var currentItemIndex: Int = 0
    @Published var currentStep: LearningStep = .flashcard
    
    @Published var progress: Double = 0.0
    @Published var showFeedbackSheet: Bool = false
    @Published var currentFeedback: CheckResult? = nil
    @Published var isLessonFinished: Bool = false
    
    // Getter lấy từ hiện tại
    var currentItem: LearningItem {
        items[currentItemIndex]
    }
    
    // Init nhận vào danh sách LearningItem
    init(items: [LearningItem]) {
        self.items = items
        updateProgress()
    }
    
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
            currentStep = .flashcard
        } else {
            isLessonFinished = true
        }
    }
    
    func checkAnswer(userAnswer: String) {
        // SỬA 2: So sánh trực tiếp với currentItem.term
        let isCorrect = userAnswer.lowercased().trimmingCharacters(in: .whitespaces) == currentItem.term.lowercased()
        
        if isCorrect {
            currentFeedback = .correct
        } else {
            currentFeedback = .wrong(correctAnswer: currentItem.term)
        }
        showFeedbackSheet = true
    }
    
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
