//
//  MultipleChoiceView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//  Updated: Fix TTS reading URL instead of Word
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
            ReviewPromptView(question: question)
            
            Spacer()

            ForEach(question.options) { option in
                ReviewOptionButton(
                    text: option.content, // Vẫn dùng content để hiển thị (nếu cần debug)
                    isSelected: selectedID == option.id,
                    isAudioMode: optionsAreAudio
                ) {
                    selectedID = option.id
                    
                    if optionsAreAudio {

                        if let wordToRead = option.originalWord?.english {
                            AudioManager.shared.playTTS(text: wordToRead, language: "en-US")
                        } else {
                            AudioManager.shared.playTTS(text: option.content, language: "en-US")
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}
