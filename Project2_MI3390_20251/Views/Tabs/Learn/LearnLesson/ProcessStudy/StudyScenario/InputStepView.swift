//
//  InputStepView.swift
//  DemoQuaTrinhHoc1Tu
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//
import SwiftUI

struct InputStepView: View {
    let item: LearningItem
    let mainColor: Color = .buttonMain
    var onCheck: (String) -> Void
    
    @State private var textInput: String = ""
    @StateObject private var audioManager = AudioManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Listen and rewrite")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.neutral06)
            
            HStack(spacing: 40) {
                AudioButton() {
                    audioManager.playAudio(url: item.audioUrl, speed: 1.0)
                }
                SlowAudioButton() {
                    audioManager.playAudio(url: item.audioUrl, speed: 0.5)
                }
            }
            .padding(.top, 10)
            
            AppTextField(text: $textInput, placeholder: "Enter vocabulary...")

            Spacer()
            
            Button("Check") {
                onCheck(textInput)
                textInput = ""
            }
            .buttonStyle(ThreeDButtonStyle(color: mainColor))
            .padding(.horizontal, 100)
            .padding(.bottom, 40)
        }
        .padding()
    }
}
