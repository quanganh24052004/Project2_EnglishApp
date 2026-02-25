//
//  InputStepView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//

import SwiftUI

struct InputStepView: View {
    @EnvironmentObject var viewModel: LessonViewModel
    
    let item: LearningItem
    
    var onCheck: (String) -> Void
    
    @State private var textInput: String = ""
    
    @FocusState private var isInputFocused: Bool

    private var isValidInput: Bool {
        return !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Listen and rewrite")
                        .font(.system(size: 20, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.neutral06)
                        .padding(.top, 20)
                    
                    HStack(spacing: 40) {
                        AudioButton {
                            viewModel.playCurrentAudio(speed: 1.0)
                        }
                        SlowAudioButton {
                            viewModel.playCurrentAudio(speed: 0.5)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    AppTextField(text: $textInput, placeholder: "Enter vocabulary...")
                        .focused($isInputFocused)
                }
                .padding(.horizontal)
            }
            .onTapGesture {
                isInputFocused = false
            }

            Spacer()
            
            Button("Check") {
                isInputFocused = false
                viewModel.checkListenWrite(userAnswer: textInput)
                textInput = ""
            }
            .buttonStyle(ThreeDButtonStyle(color: isValidInput ? .pGreen : .gray))
            .disabled(!isValidInput)
            .padding(.horizontal, 100)
            .padding(.bottom, 20)
        }
        .padding(.bottom)
        .onAppear {
            viewModel.playCurrentAudio()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isInputFocused = true
            }
        }
    }
}
