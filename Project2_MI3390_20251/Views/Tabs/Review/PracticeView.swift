struct PracticeView: View {
    let recordsToReview: [StudyRecord]
    
    var body: some View {
        VStack {
            if recordsToReview.isEmpty {
                Text("Không có từ nào để ôn!")
            } else {
                Text("Đang ôn tập \(recordsToReview.count) từ")
                // Ở đây bạn sẽ tái sử dụng logic Flashcard hoặc QuizView
                // Ví dụ: QuizView(words: recordsToReview.compactMap { $0.word })
            }
        }
        .navigationTitle("Ôn tập")
    }
}