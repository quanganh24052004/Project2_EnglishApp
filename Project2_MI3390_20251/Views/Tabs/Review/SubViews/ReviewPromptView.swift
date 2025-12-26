struct ReviewPromptView: View {
    let question: ReviewQuestion
    
    var body: some View {
        VStack(spacing: 16) {
            // Nếu có Audio đề bài (Kịch bản 8)
            if let audio = question.audioUrl, question.type == .listenToAudioChooseMeaning {
                 AudioButton(url: audio) // Sử dụng Component có sẵn của bạn
                     .frame(width: 60, height: 60)
            }
            
            // Hiển thị Text (Câu ví dụ hoặc Nghĩa)
            if let text = question.promptText {
                if let highlighted = question.highlightedWord {
                    // Kịch bản 7: Xử lý gạch chân/Highlight
                    Text(attributedString(from: text, highlight: highlighted))
                        .font(.title2)
                        .multilineTextAlignment(.center)
                } else {
                    // Các kịch bản thường
                    Text(text)
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    // Helper tạo Attributed String để bôi đậm/gạch chân từ khóa
    func attributedString(from fullText: String, highlight: String) -> AttributedString {
        var attributed = AttributedString(fullText)
        if let range = attributed.range(of: highlight) {
            attributed[range].foregroundColor = .orange
            attributed[range].underlineStyle = .single
            attributed[range].font = .system(size: 24, weight: .bold)
        }
        return attributed
    }
}