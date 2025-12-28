//
//  ReviewPromptView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//  Updated: Fix TTS reading URL instead of Word
//

import SwiftUI

struct ReviewPromptView: View {
    let question: ReviewQuestion
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Kịch bản 8: Nghe âm thanh (Prompt) -> Chọn nghĩa
            // Kiểm tra type và audioUrl để hiển thị nút loa
            if question.type == .listenToAudioChooseMeaning, let _ = question.audioUrl {
                
                AudioButton(action: {
                    AudioManager.shared.playTTS(text: question.targetWord.english, language: "en-US")
                })
                .onAppear {
                    AudioManager.shared.playTTS(text: question.targetWord.english, language: "en-US")
                }
            }
            
            // Hiển thị Text (Câu ví dụ hoặc Nghĩa) cho các kịch bản khác
            if let text = question.promptText {
                if let highlighted = question.highlightedWord {
                    // Kịch bản 7: Xử lý gạch chân/Highlight
                    Text(attributedString(from: text, highlight: highlighted))
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.orange, lineWidth: 1.5)
                        )

                } else {
                    // Các kịch bản thường
                    Text(text)
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.orange, lineWidth: 1.5)
                        )

                }
            }
        }
    }
    
    // Helper tạo Attributed String để bôi đậm/gạch chân từ khóa
    func attributedString(from fullText: String, highlight: String) -> AttributedString {
        var attributed = AttributedString(fullText)
        // Tìm và highlight từ khóa (case insensitive)
        if let range = attributed.range(of: highlight, options: .caseInsensitive) {
            attributed[range].underlineStyle = .single
            attributed[range].font = .system(size: 18, weight: .semibold)
        }
        return attributed
    }
}
