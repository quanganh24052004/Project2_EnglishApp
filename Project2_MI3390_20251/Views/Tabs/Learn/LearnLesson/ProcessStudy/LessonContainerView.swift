//
//  LessonContainerView.swift
//  Project2_EnglishApp
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//

import SwiftUI
import SwiftData

struct LessonContainerView: View {
    @StateObject private var viewModel: LessonViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    // State cho Sheet cảnh báo thoát
    @State private var showExitSheet = false

    init(items: [LearningItem]) {
        _viewModel = StateObject(wrappedValue: LessonViewModel(items: items))
    }
    
    var body: some View {
        VStack {
            // MARK: - Header
            HStack {
                Button(action: { showExitSheet = true }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 28, weight: .bold)) // Chỉnh lại size cho đẹp
                        .foregroundColor(.gray)
                }
                
                ProgressBar(
                    value: viewModel.progress,
                    height: 16,
                    color: .orange,
                    iconName: "iconProgressBar"
                )
                .padding(.horizontal, 4)
            }
            .padding()
            
            // MARK: - Main Content
            Group {
                if viewModel.isLessonFinished {
                    // ⭐️ MÀN HÌNH TỔNG KẾT & CHỌN TỪ (MỚI)
                    SummarizeView(
                        items: viewModel.items,
                        onSave: { selectedIDs in
                            // 1. Lưu các từ user đã chọn
                            viewModel.saveSelectedWords(selectedIDs)
                            // 2. Thoát ra ngoài
                            dismiss()
                        },
                        onCancel: {
                            dismiss()
                        }
                    )
                    .transition(.move(edge: .trailing))
                    
                } else {
                    switch viewModel.currentStep {
                    case .flashcard:
                        FlashcardStepView(
                            item: viewModel.currentItem,
                            onContinue: { viewModel.moveToNextStage() }
                        )
                    case .listenWrite:
                        SpellingGameView(
                            item: viewModel.currentItem,
                            onCheck: { viewModel.checkListenWrite(userAnswer: $0) }
                        )
                    case .fillBlank:
                        InputStepView(
                            item: viewModel.currentItem,
                            onCheck: { viewModel.checkFillBlank(userAnswer: $0) }
                        )
                    }
                }
            }
            Spacer()
        }
        .background(Color(.neutral01)) // Hoặc màu nền của bạn
        .onAppear {
             if viewModel.learningManager == nil {
                 viewModel.learningManager = LearningManager(modelContext: modelContext)
             }
        }
        // Sheet Feedback
        .sheet(isPresented: $viewModel.showFeedbackSheet, onDismiss: {
            viewModel.moveToNextStage()
        }) {
            if let result = viewModel.currentFeedback {
                FeedbackSheetView(result: result)
                    .presentationDetents([.fraction(0.40)])
                    .presentationDragIndicator(.visible)
            }
        }
        // Sheet Exit Warning
        .sheet(isPresented: $showExitSheet) {
            ExitConfirmationSheet(
                onContinue: { showExitSheet = false },
                onExit: {
                    showExitSheet = false
                    dismiss()
                }
            )
            .presentationDetents([.fraction(0.40)])
        }
    }
}
