//
//  LevelNode.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 3/2/26.
//


import SwiftUI

struct LevelNode: Identifiable {
    let id = UUID()
    let level: Int
    let isLocked: Bool
}

struct LearningPathView: View {
    // Giả lập dữ liệu 20 levels
    let levels = (1...20).map { LevelNode(level: $0, isLocked: $0 > 3) }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) { // Spacing dọc giữa các level
                ForEach(Array(levels.enumerated()), id: \.element.id) { index, node in
                    LevelButton(level: node.level, isLocked: node.isLocked)
                        // LOGIC QUAN TRỌNG NHẤT: Hàm Sin
                        // index * 0.5: Tần số sóng (sóng ngắn hay dài)
                        // * 70: Biên độ sóng (độ rộng sang 2 bên)
                        .offset(x: sin(Double(index) * 0.7) * 70)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)
        }
        .background(Color.black.opacity(0.05)) // Màu nền nhẹ
    }
}

// UI của một nút Level tròn
struct LevelButton: View {
    let level: Int
    let isLocked: Bool
    
    var body: some View {
        ZStack {
            // Vòng tròn ngoài (Viền)
            Circle()
                .fill(isLocked ? Color.gray.opacity(0.3) : Color.green.opacity(0.2))
                .frame(width: 80, height: 80)
            
            // Vòng tròn trong (Nút chính)
            Circle()
                .fill(isLocked ? Color.gray : Color.green)
                .frame(width: 70, height: 70)
                .overlay(
                    // Hiệu ứng 3D đơn giản (bóng)
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 4)
                        .blur(radius: 2)
                        .offset(x: -2, y: -2)
                        .mask(Circle().frame(width: 68, height: 68))
                )
            
            // Số level hoặc Icon
            if isLocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.white)
                    .font(.title2)
            } else {
                Text("\(level)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Sao đánh giá (trang trí)
            if !isLocked {
                HStack(spacing: 2) {
                    ForEach(0..<3) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
                .offset(y: 45) // Đẩy xuống dưới nút
            }
        }
        .shadow(radius: 5, y: 5)
    }
}

#Preview {
    LearningPathView()
}