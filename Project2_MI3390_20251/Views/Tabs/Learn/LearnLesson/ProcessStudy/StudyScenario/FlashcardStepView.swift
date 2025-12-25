//
//  FlashcardStepView.swift
//  DemoQuaTrinhHoc1Tu
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//

import SwiftUI
import Combine

struct FlashcardStepView: View {
    @StateObject private var audioManager = AudioManager()
    
    // MARK: - New States for Logic
    @State private var hasInteracted = false
    @State private var isFlipped = false
    @State private var timer: AnyCancellable?
    
    let item: LearningItem
    var onContinue: () -> Void
    let mainColor: Color = .buttonMain
    
    var body: some View {
        ZStack {
            Color(.neutral01).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // MARK: - 2. Flip Card với logic tự động
                WordCardView(item: item, isFlipped: $isFlipped)
                    .id(item.id)
                    .onChange(of: isFlipped) { newValue in
                        if newValue == true {
                            enableContinue()
                        }
                    }
                
                // MARK: - 3. Audio Buttons
                HStack(spacing: 40) {
                    AudioButton() {
                        AudioManager.shared.playTTS(text: item.word, language: "en-US")
                    }
                    SlowAudioButton() {
                        AudioManager.shared.playTTS(text: item.word, language: "en-US", speed: 0.2)
                    }
                }
                .padding(.top, 10)
                
                Spacer()
                
                // MARK: - 4. Nút Tiếp tục (Disable nếu chưa tương tác)
                Button("Tiếp tục") {
                    onContinue()
                }
                .buttonStyle(ThreeDButtonStyle(color: hasInteracted ? mainColor : .gray))
                .disabled(!hasInteracted) // Disable nếu chưa lật thẻ
                .padding(.horizontal, 100)
                .padding(.bottom, 40)
                .animation(.easeInOut, value: hasInteracted)
            }
        }
        .onAppear {
            startStepLogic()
        }
        .onDisappear {
            stopStepLogic()
        }
    }
    
    // MARK: - Logic Functions
    
    private func startStepLogic() {
        audioManager.playTTS(text: item.word, language: "en-US", speed: 0.5)
        
        timer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if !hasInteracted {
                    withAnimation(.spring()) {
                        self.isFlipped = true
                        enableContinue()
                    }
                }
                timer?.cancel()
            }
    }
    
    private func enableContinue() {
        hasInteracted = true
        timer?.cancel()
    }
    
    private func stopStepLogic() {
        audioManager.stop()
        timer?.cancel()
    }
}
