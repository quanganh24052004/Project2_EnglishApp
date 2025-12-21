// File: LessonContainerView.swift
import SwiftUI
import SwiftData

struct LessonContainerView: View {
    @StateObject private var viewModel: LessonViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    // Init nhận danh sách items
    init(items: [LearningItem]) {
        _viewModel = StateObject(wrappedValue: LessonViewModel(items: items))
    }
    
    var body: some View {
        VStack {
            // --- HEADER ---
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                }
                ProgressView(value: viewModel.progress)
                    .tint(.green)
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            .padding()
            
            // --- BODY ---
            Group {
                if viewModel.isLessonFinished {
                    // Màn hình hoàn thành
                    VStack(spacing: 20) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.yellow)
                        Text("Congratulations! You have finished the lesson.")
                            .font(.title2).bold()
                            .multilineTextAlignment(.center)
                        
                        Button("Complete") { dismiss() }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    // Switch các bước học
                    switch viewModel.currentStep {
                    case .flashcard:
                        FlashcardStepView(
                            item: viewModel.currentItem,
                            onContinue: { viewModel.moveToNextStage() }
                        )
                        
                    case .listenWrite:
                        // *** TÍNH NĂNG MỚI: SPELLING GAME ***
                        SpellingGameView(
                            item: viewModel.currentItem,
                            onCheck: { userAnswer in
                                viewModel.checkListenWrite(userAnswer: userAnswer)
                            }
                        )
                        
                    case .fillBlank:
                        InputStepView(
                            title: "Fill in the missing words",
                            item: viewModel.currentItem,
                            onCheck: { answer in
                                viewModel.checkFillBlank(userAnswer: answer)
                            }
                        )
                    }
                }
            }
            Spacer()
        }
        .background(Color(.neutral01))
        // --- LIFECYCLE ---
        .onAppear {
            if viewModel.learningManager == nil {
                viewModel.learningManager = LearningManager(modelContext: modelContext)
            }
        }
        // --- FEEDBACK SHEET ---
        .sheet(isPresented: $viewModel.showFeedbackSheet, onDismiss: {
            viewModel.moveToNextStage()
        }) {
            if let result = viewModel.currentFeedback {
                FeedbackSheetView(result: result)
                    .presentationDetents([.fraction(0.40)])
                    .interactiveDismissDisabled()
            }
        }
    }
}

