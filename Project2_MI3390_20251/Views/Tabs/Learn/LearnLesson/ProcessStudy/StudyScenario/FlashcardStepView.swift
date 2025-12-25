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
    @State private var hasInteracted = false // Kiểm tra xem đã lật thẻ chưa
    @State private var isFlipped = false    // Trạng thái lật của thẻ
    @State private var timer: AnyCancellable? // Timer để tự động lật
    
    let item: LearningItem
    var onContinue: () -> Void
    let mainColor: Color = .buttonMain
    
    var body: some View {
        ZStack {
            Color(.neutral01).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // MARK: - 2. Flip Card với logic tự động
                // Giả sử WordCardView có hỗ trợ Binding cho trạng thái lật
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
                        audioManager.playAudio(url: item.audioUrl, speed: 1.0)
                    }
                    SlowAudioButton() {
                        audioManager.playAudio(url: item.audioUrl, speed: 0.5)
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
        // 1. Tự động phát âm thanh khi vào màn hình
        audioManager.playAudio(url: item.audioUrl, speed: 1.0)
        
        // 2. Thiết lập Timer tự động lật sau 5 giây
        timer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if !hasInteracted {
                    withAnimation(.spring()) {
                        self.isFlipped = true // Tự động lật thẻ
                        enableContinue()      // Cho phép bấm tiếp tục
                    }
                }
                timer?.cancel() // Hủy timer sau khi chạy xong
            }
    }
    
    private func enableContinue() {
        hasInteracted = true
        timer?.cancel() // Nếu người dùng chủ động bấm trước 5s, hủy timer
    }
    
    private func stopStepLogic() {
        audioManager.stop()
        timer?.cancel()
    }
}
