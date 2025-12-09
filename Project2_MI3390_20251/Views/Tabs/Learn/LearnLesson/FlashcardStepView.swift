//
//  FlashcardStepView.swift
//  DemoQuaTrinhHoc1Tu
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//
import SwiftUI
import Combine

struct FlashcardStepView: View {
    let item: LearningItem // Đổi tên biến cho rõ ràng
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            // Demo Flipcard UI
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 300)
                Text(item.term) // Hiển thị term
                    .font(.largeTitle)
                    .bold()
            }
            .onTapGesture {
                // Logic lật thẻ ở đây
            }
            
            HStack {
                Button(action: { /* Play Sound */ }) { Label("Nghe", systemImage: "speaker.wave.2") }
                Button(action: { /* Play Slow */ }) { Label("Chậm", systemImage: "tortoise") }
            }
            .buttonStyle(.bordered)
            
            Spacer()
                Button("Tiếp tục", action: onContinue)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
        }
        .padding()
    }
}
