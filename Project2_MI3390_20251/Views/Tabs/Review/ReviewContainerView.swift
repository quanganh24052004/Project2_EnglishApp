//
//  ReviewContainerView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//

import SwiftUI
import SwiftData

struct ReviewContainerView: View {
    // MARK: - Environment & State
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @StateObject var viewModel: ReviewViewModel
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        let manager = LearningManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ReviewViewModel(modelContext: modelContext, learningManager: manager))
    }
    
    // MARK: - Main Body
    var body: some View {
        ZStack {
            // 1. Màu nền Neutral01 (Yêu cầu mới)
            Color.neutral01
                .ignoresSafeArea()
            
            // 2. Nội dung chính
            Group {
                if viewModel.isSessionCompleted {
                    ReviewSummaryView(
                        onContinueReview: {
                            viewModel.loadReviewSession()
                        }
                    )
                } else {
                    mainReviewContent
                }
            }
        }
        .onAppear {
            if viewModel.questions.isEmpty && !viewModel.isSessionCompleted {
                viewModel.loadReviewSession()
            }
            AudioManager.shared.stopBackgroundMusic()
        }
        .onDisappear {
            AudioManager.shared.playBackgroundMusic()
        }
        // Sheet kết quả
        .sheet(isPresented: $viewModel.showResult) {
            if !viewModel.questions.isEmpty {
                FeedbackSheetView(
                    isCorrect: viewModel.isLastAnswerCorrect,
                    correctAnswer: viewModel.questions[viewModel.currentIndex].correctAnswer,
                    onNext: {
                        viewModel.nextQuestion()
                    }
                )
                .presentationDetents([.fraction(0.40)])
                .interactiveDismissDisabled()
            }
        }
    }
}

// MARK: - Subviews Breakdown
extension ReviewContainerView {
    
    /// View chứa toàn bộ nội dung bài ôn tập
    private var mainReviewContent: some View {
        VStack(spacing: 0) {
            headerView
            Spacer()
            questionAreaView
            Spacer()
            footerView
        }
        .navigationBarHidden(true)
    }
    
    /// Header: Nút tắt, Progress Bar, Số câu hỏi
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
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
            
            Text("\(viewModel.currentIndex + 1)/\(max(viewModel.questions.count, 1))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    /// Khu vực hiển thị câu hỏi hoặc trạng thái Loading/Empty
    private var questionAreaView: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Đang tạo bài ôn tập...")
                    .controlSize(.large)
            } else if viewModel.questions.isEmpty {
                emptyStateView
            } else {
                VStack (spacing: 16) {
                    Text(viewModel.questions[viewModel.currentIndex].type.title)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(.neutral06)
                    
                    currentQuestionView
                }
                // Logic hiển thị câu hỏi được tách ra function riêng
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: viewModel.currentIndex)
    }
    
    /// View hiển thị khi không có dữ liệu
    private var emptyStateView: some View {
        VStack {
            ContentUnavailableView(
                "Không có dữ liệu",
                systemImage: "exclamationmark.triangle",
                description: Text("Không tạo được câu hỏi nào từ dữ liệu hiện tại.")
            )
            Spacer()
            Button("Quay lại") { dismiss() }
                .padding()
        }
    }
    
    /// Switch logic để hiển thị loại câu hỏi tương ứng (Sử dụng @ViewBuilder)
    @ViewBuilder
    private var currentQuestionView: some View {
        let currentQ = viewModel.questions[viewModel.currentIndex]
        
        Group {
            switch currentQ.type {
            case .listenAndChooseWord,
                 .listenAndChooseMeaning,
                 .chooseWordFromContext,
                 .chooseMeaningFromContext,
                 .listenToAudioChooseMeaning:
                MultipleChoiceView(question: currentQ, selectedID: $viewModel.selectedOptionID)
                
            case .fillInTheBlank,
                 .translateAndFill:
                SpellingView(question: currentQ, currentInput: $viewModel.spellingInput)
                
            case .listenAndWrite:
                TypingView(question: currentQ, textInput: $viewModel.textInput)
            }
        }
        .id(currentQ.id)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    /// Footer: Nút kiểm tra
    @ViewBuilder
    private var footerView: some View {
        if !viewModel.isLoading && !viewModel.questions.isEmpty {
            Button(action: {
                viewModel.checkAnswer()
            }) {
                Text("Kiểm tra")
            }
            // Áp dụng logic màu sắc dựa trên trạng thái active
            .buttonStyle(ThreeDButtonStyle(
                color: canSubmit ? .pGreen : .gray
            ))
            // Áp dụng logic disabled
            .disabled(!canSubmit)
            .padding(.horizontal, 100)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Validation Logic (Giữ nguyên)
extension ReviewContainerView {
    var canSubmit: Bool {
        guard !viewModel.questions.isEmpty, viewModel.currentIndex < viewModel.questions.count else { return false }
        
        let type = viewModel.questions[viewModel.currentIndex].type
        switch type {
        case .listenAndChooseWord, .chooseWordFromContext, .listenAndChooseMeaning, .chooseMeaningFromContext, .listenToAudioChooseMeaning:
            return viewModel.selectedOptionID != nil
        case .fillInTheBlank, .translateAndFill:
            return !viewModel.spellingInput.isEmpty
        case .listenAndWrite:
            return !viewModel.textInput.isEmpty
        }
    }
}

// MARK: - Extensions
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

