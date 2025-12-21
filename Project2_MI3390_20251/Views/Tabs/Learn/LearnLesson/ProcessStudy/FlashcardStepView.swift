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
    // Input dữ liệu từ màn hình cha
    let item: LearningItem
    
    // Callback khi nhấn nút "Tiếp tục"
    var onContinue: () -> Void
    
    // State để quản lý việc phát âm thanh (nếu cần xử lý tại đây)
    // @StateObject private var audioPlayer = AudioService() // Ví dụ
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // MARK: - 1. Khu vực hiển thị thẻ (Flip Card)
            WordCardView(item: item)
                .id(item.id)
                .padding(.horizontal)
            
            // MARK: - 2. Các nút chức năng (Audio)
            HStack(spacing: 40) {
                Button(action: {
                    audioManager.playAudio(url: item.audioUrl, speed: 1.0)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                        Text("Listen")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    audioManager.playAudio(url: item.audioUrl, speed: 0.5)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "tortoise.fill")
                            .font(.title2)
                        Text("Slow")
                            .font(.caption)
                    }
                }
            }
            .foregroundColor(.blue)
            .padding(.top, 10)
            
            Spacer()
            
            // MARK: - 3. Nút điều hướng
            Button("Continue") {
                onContinue()
            }
            .buttonStyle(ThreeDButtonStyle())
            .padding(100)
        }
        .background(Color(UIColor.systemGroupedBackground))// Màu nền xám nhẹ dịu mắt
        .onDisappear {
                    audioManager.stop()
        }
    }
    
    // MARK: - Helper Functions
    func playAudio(url: String?, speed: Float) {
        guard let url = url else { return }
        print("Audio is playing: \(url) with speed \(speed)x")
    }
}
