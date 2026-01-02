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

    @State private var showExitSheet = false

    init(items: [LearningItem]) {
        _viewModel = StateObject(wrappedValue: LessonViewModel(items: items))
    }
    
    var body: some View {
        ZStack {
            Color(.neutral01)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if !viewModel.isLessonFinished {
                    headerView
                        .padding()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                ZStack {
                    if viewModel.isLessonFinished {
                        SummarizeView(
                            items: viewModel.items,
                            onSave: { selectedIDs in
                                viewModel.saveSelectedWords(selectedIDs)
                                dismiss()
                            },
                            onCancel: {
                                dismiss()
                            }
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else {
                        lessonContentView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: viewModel.isLessonFinished)
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentStep)
            }
        }
        .onAppear {
             if viewModel.learningManager == nil {
                 viewModel.learningManager = LearningManager(modelContext: modelContext)
             }
            AudioManager.shared.stopBackgroundMusic()
        }
        .onDisappear {
            AudioManager.shared.playBackgroundMusic()
        }
        .sheet(isPresented: $viewModel.showFeedbackSheet, onDismiss: {
            withAnimation {
                viewModel.moveToNextStage()
            }
        }) {
            if let result = viewModel.currentFeedback {
                FeedbackSheetView(
                    result: result,
                    item: viewModel.currentItem
                )
                    .presentationDetents([.fraction(0.65)])
                    .presentationDragIndicator(.visible)
            }
        }
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
        .environmentObject(viewModel)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Button(action: { showExitSheet = true }) {
                Image(systemName: "xmark")
                    .font(.system(size: 28, weight: .bold))
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
    }
    
    @ViewBuilder
    private var lessonContentView: some View {
        Group {
            switch viewModel.currentStep {
            case .flashcard:
                FlashcardStepView(
                    item: viewModel.currentItem,
                    onContinue: {
                        withAnimation {
                            viewModel.moveToNextStage()
                        }
                    }
                )
                
            case .fillBlank:
                SpellingGameView(
                    item: viewModel.currentItem,
                    onCheck: { viewModel.checkListenWrite(userAnswer: $0) }
                )
                
            case .listenWrite:
                InputStepView(
                    item: viewModel.currentItem,
                    onCheck: { viewModel.checkFillBlank(userAnswer: $0) }
                )
            }
        }
        .id(viewModel.currentStep)
    }
}
