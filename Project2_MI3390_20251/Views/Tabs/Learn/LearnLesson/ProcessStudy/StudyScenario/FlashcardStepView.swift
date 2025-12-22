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
    let item: LearningItem
    var onContinue: () -> Void
    
    // Tận dụng màu chủ đạo từ extension cũ (hoặc dùng .blue/.green tùy logic app)
    // Giả sử màu chính của app là màu nút Continue
    let mainColor: Color = .buttonMain
    
    var body: some View {
        ZStack {
            // MARK: - 1. Background đồng bộ
            Color(.neutral01)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {

                Spacer()
                
                // MARK: - 2. Khu vực hiển thị thẻ (Flip Card)
                WordCardView(item: item)
                    .id(item.id)
                
                // MARK: - 3. Các nút chức năng (Audio)
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
                
                // MARK: - 4. Nút điều hướng chính
                Button("Tiếp tục") {
                    onContinue()
                }
                .buttonStyle(ThreeDButtonStyle(color: mainColor))
                .padding(.horizontal, 100)
                .padding(.bottom, 40)
            }
        }
        .onDisappear {
            audioManager.stop()
        }
    }
}


