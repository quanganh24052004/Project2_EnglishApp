//
//  ReviewContainerView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//

import SwiftUI
import SwiftData

struct ReviewContainerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext // Cần để truyền cho SummaryView tự query
    
    // ViewModel sẽ được khởi tạo trong init
    @StateObject var viewModel: ReviewViewModel
    
    // Custom Init: Inject Context -> Tạo Manager -> Tạo VM
    init(modelContext: ModelContext) {
        let manager = LearningManager(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: ReviewViewModel(modelContext: modelContext, learningManager: manager))
    }
    
    var body: some View {
        Group {
            // --- LOGIC ĐIỀU HƯỚNG MỚI THÊM ---
            if viewModel.isSessionCompleted {
                // Nếu đã học xong -> Hiện màn hình Tổng kết
                ReviewSummaryView(
                    onContinueReview: {
                        // Reset lại ViewModel để tải phiên ôn tập tiếp theo
                        viewModel.loadReviewSession()
                    }
                )
            } else {
                // Nếu chưa xong -> Hiện giao diện ôn tập cũ (Giữ nguyên logic của bạn)
                reviewContentView
            }
        }
        .onAppear {
            // Chỉ load nếu chưa có câu hỏi và chưa hoàn thành
            if viewModel.questions.isEmpty && !viewModel.isSessionCompleted {
                viewModel.loadReviewSession()
            }
        }
    }
    
    // Tách toàn bộ logic UI cũ vào biến này để code gọn gàng, không thay đổi logic gốc
    var reviewContentView: some View {
        VStack(spacing: 0) {
            // 1. Header & Progress Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
                
                // ProgressBar (Giữ nguyên style của bạn)
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
            
            Divider()
            
            // 2. Nội dung chính
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Đang tạo bài ôn tập...")
                        .controlSize(.large)
                } else if viewModel.questions.isEmpty {
                    ContentUnavailableView(
                        "Không có dữ liệu",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Không tạo được câu hỏi nào từ dữ liệu hiện tại.")
                    )
                    VStack {
                        Spacer()
                        Button("Quay lại") { dismiss() }
                            .padding()
                    }
                } else {
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.default, value: viewModel.currentIndex)
            
            // 3. Footer Button
            if !viewModel.isLoading && !viewModel.questions.isEmpty {
                Button(action: {
                    viewModel.checkAnswer()
                }) {
                    Text("Kiểm tra")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSubmit ? Color.blue : Color.gray)
                        .cornerRadius(25)
                }
                .disabled(!canSubmit)
                .padding()
            }
        }
        .navigationBarHidden(true)
        // 4. Feedback Sheet
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
    
    // Logic validate cũ
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

// Extension safe index (Giữ nguyên)
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
