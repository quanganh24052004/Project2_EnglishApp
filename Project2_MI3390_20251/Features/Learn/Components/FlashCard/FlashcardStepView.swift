//
//  FlashcardStepView.swift
//  DemoQuaTrinhHoc1Tu
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//

import SwiftUI
import Combine

struct FlashcardStepView: View {
    
    // MARK: - New States for Logic
    @State private var hasInteracted = false
    @State private var isFlipped = false
    @State private var timer: AnyCancellable?
    
    let item: LearningItem
    var onContinue: () -> Void
    let mainColor: Color = .pGreen
    
    var body: some View {
        ZStack {
            CapyColors.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // MARK: - 2. Flip Card với logic tự động
                WordCardView(item: item, isFlipped: $isFlipped)
                    .id(item.id)
                    .onChange(of: isFlipped) { oldValue, newValue in
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
                Button("Continue") {
                    onContinue()
                }
                .capyButton(.primary(color: CapyColors.green, shadow: CapyColors.greenShadow))
                .disabled(!hasInteracted) // Disable nếu chưa lật thẻ
                .padding(.horizontal, 100)
                .padding(.bottom, 40)
                .animation(.smooth, value: hasInteracted)
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
        AudioManager.shared.playTTS(text: item.word, language: "en-US", speed: 0.5)
        
        timer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if !hasInteracted {
                    withAnimation(.bouncy) {
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
        AudioManager.shared.stop()
        timer?.cancel()
    }
}
