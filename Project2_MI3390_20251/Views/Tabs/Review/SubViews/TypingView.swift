//
//  TypingView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//
//

import SwiftUI

struct TypingView: View {
    let question: ReviewQuestion
    @Binding var textInput: String
    
    var body: some View {
        VStack(spacing: 48) {
            AudioButton(action: {
                AudioManager.shared.playTTS(text: question.targetWord.english, language: "en-US")
            })
            
            AppTextField(text: $textInput, placeholder: "Gõ lại từ bạn nghe được")
            Spacer()
        }
        .padding()
        .onAppear {
            AudioManager.shared.playTTS(text: question.targetWord.english, language: "en-US")
        }
    }
}
