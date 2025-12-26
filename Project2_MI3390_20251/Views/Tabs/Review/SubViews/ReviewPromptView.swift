//
//  ReviewPromptView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//
import SwiftUI

struct ReviewPromptView: View {
    let question: ReviewQuestion
    
    var body: some View {
        VStack(spacing: 16) {
            // Nếu có Audio đề bài (Kịch bản 8)
            if let audio = question.audioUrl, question.type == .listenToAudioChooseMeaning {
//                AudioButton() {
//                    AudioManager.shared.playTTS(text: text, language: "en-US")
//                }
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
