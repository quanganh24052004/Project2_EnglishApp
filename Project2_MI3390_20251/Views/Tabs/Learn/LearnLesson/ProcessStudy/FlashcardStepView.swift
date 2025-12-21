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
                    AudioControlButton(
                        icon: "speaker.wave.2.fill",
                        text: "Nghe",
                        color: Color(.orange)
                    ) {
                        audioManager.playAudio(url: item.audioUrl, speed: 1.0)
                    }
                    
                    AudioControlButton(
                        icon: "tortoise.fill",
                        text: "Chậm",
                        color: Color(.orange)
                    ) {
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

// MARK: - Subview: Nút Audio
// Tách ra để code chính gọn hơn và dễ style lại đồng loạt
struct AudioControlButton: View {
    let icon: String
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(text)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Style hiệu ứng nhún nhẹ cho các nút phụ (không cần 3D như nút chính)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
