struct ReviewContainerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ReviewViewModel // Được inject từ bên ngoài
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header & Progress Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
                
                // Tận dụng component ProgressBar của bạn
                // Giả sử nó nhận value từ 0.0 đến 1.0
                ProgressBar(value: viewModel.progress) 
                    .frame(height: 10)
                    .padding(.horizontal)
                
                Text("\(viewModel.currentIndex + 1)/\(viewModel.questions.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            
            Divider()
            
            // 2. Nội dung chính (Thay đổi theo câu hỏi)
            ZStack {
                if !viewModel.questions.isEmpty {
                    let currentQ = viewModel.questions[viewModel.currentIndex]
                    
                    Group {
                        switch currentQ.type {
                        // Nhóm A: Trắc nghiệm
                        case .listenAndChooseWord, 
                             .listenAndChooseMeaning, 
                             .chooseWordFromContext, 
                             .chooseMeaningFromContext, 
                             .listenToAudioChooseMeaning:
                            MultipleChoiceView(question: currentQ, selectedID: $viewModel.selectedOptionID)
                            
                        // Nhóm B: Spelling
                        case .fillInTheBlank, 
                             .translateAndFill:
                            SpellingView(question: currentQ, currentInput: $viewModel.spellingInput)
                            
                        // Nhóm C: Typing
                        case .listenAndWrite:
                            TypingView(question: currentQ, textInput: $viewModel.textInput)
                        }
                    }
                    .id(currentQ.id) // Quan trọng: Force refresh view khi đổi câu hỏi
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 3. Footer Button (Kiểm tra)
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
        .navigationBarHidden(true)
        // 4. Feedback Sheet (Hiển thị kết quả đúng/sai)
        .sheet(isPresented: $viewModel.showResult) {
            // Bạn có thể dùng `CorrectSheetView` hoặc `FeedbackSheetView` có trong file list
            ReviewFeedbackView(
                isCorrect: viewModel.isLastAnswerCorrect,
                correctAnswer: viewModel.questions[viewModel.currentIndex].correctAnswer,
                onNext: {
                    viewModel.nextQuestion()
                }
            )
            .presentationDetents([.fraction(0.3)]) // Hiện 1/3 màn hình
            .interactiveDismissDisabled()
        }
    }
    
    // Logic validate nút Kiểm tra (phải chọn rồi mới cho bấm)
    var canSubmit: Bool {
        let type = viewModel.questions[safe: viewModel.currentIndex]?.type
        switch type {
        case .listenAndChooseWord, .chooseWordFromContext, .listenAndChooseMeaning, .chooseMeaningFromContext, .listenToAudioChooseMeaning:
            return viewModel.selectedOptionID != nil
        case .fillInTheBlank, .translateAndFill:
            return !viewModel.spellingInput.isEmpty
        case .listenAndWrite:
            return !viewModel.textInput.isEmpty
        case .none:
            return false
        }
    }
}

// Extension safe index
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}