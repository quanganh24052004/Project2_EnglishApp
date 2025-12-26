//
//  MultipleChoiceView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//
import SwiftUI

struct MultipleChoiceView: View {
    let question: ReviewQuestion
    @Binding var selectedID: UUID?
    
    // Kiểm tra xem option là Audio (Scenario 1, 6) hay Text
    var optionsAreAudio: Bool {
        return question.type == .listenAndChooseWord || question.type == .listenAndChooseMeaning
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // 1. Phần Đề bài (Prompt)
            ReviewPromptView(question: question)
            
            Spacer()
            
            // 2. Phần Grid Đáp án
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(question.options) { option in
                    ReviewOptionButton(
                        text: option.content,
                        isSelected: selectedID == option.id,
                        isAudioMode: optionsAreAudio
                    ) {
                        selectedID = option.id
                        // Nếu là dạng nghe, bấm vào là đọc luôn
                        if optionsAreAudio {
                            // AudioManager.shared.speak(option.content)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
