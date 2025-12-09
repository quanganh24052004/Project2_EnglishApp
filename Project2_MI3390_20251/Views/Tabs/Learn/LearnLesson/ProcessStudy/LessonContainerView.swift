// File: LessonContainerView.swift
import SwiftUI

struct LessonContainerView: View {
    @StateObject private var viewModel: LessonViewModel
    @Environment(\.dismiss) var dismiss
    
    // Init nhận danh sách đã chuyển đổi
    init(items: [LearningItem]) {
        _viewModel = StateObject(wrappedValue: LessonViewModel(items: items))
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark").foregroundColor(.gray)
                }
                ProgressView(value: viewModel.progress)
                    .tint(.green)
            }
            .padding()
            
            // Body
            Group {
                if viewModel.isLessonFinished {
                    VStack(spacing: 20) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.yellow)
                        Text("Chúc mừng! Bạn đã hoàn thành bài học.")
                            .font(.title2)
                            .bold()
                        Button("Hoàn tất") { dismiss() }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    switch viewModel.currentStep {
                    case .flashcard:
                        FlashcardStepView(
                            item: viewModel.currentItem,
                            onContinue: { viewModel.moveToNextStage() }
                        )
                        
                    case .listenWrite:
                        InputStepView(
                            title: "Nghe và viết lại",
                            item: viewModel.currentItem,
                            onCheck: { answer in viewModel.checkAnswer(userAnswer: answer) }
                        )
                        
                    case .fillBlank:
                        InputStepView(
                            title: "Điền từ còn thiếu",
                            item: viewModel.currentItem,
                            onCheck: { answer in viewModel.checkAnswer(userAnswer: answer) }
                        )
                    }
                }
            }
        }
        // Bottom Sheet Feedback
        .sheet(isPresented: $viewModel.showFeedbackSheet, onDismiss: {
            viewModel.moveToNextStage()
        }) {
            if let result = viewModel.currentFeedback {
                FeedbackSheetView(result: result)
                    // SỬA LỖI FRACTION: Nếu iOS < 16 dùng .medium, iOS 16+ dùng .fraction
                    .presentationDetents([.fraction(0.40)])
                    .interactiveDismissDisabled()
            }
        }
    }
}
