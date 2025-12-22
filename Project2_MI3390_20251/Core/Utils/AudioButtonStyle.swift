//
//  AudioButtonStyle.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 21/12/25.
//

import SwiftUI

struct ThreeDCircleButtonStyle: ButtonStyle {
    // 1. Cấu hình Input
    let iconColor: Color      // Màu của biểu tượng
    let backgroundColor: Color // Màu của nút
    let size: CGFloat
    let depth: CGFloat
    
    // 2. Thuộc tính tự tính toán (Shadow ăn theo màu nền)
    private let shadowColor: Color
    
    // 3. Init: Nhận 2 màu riêng biệt
    init(
        iconColor: Color = .white,       // Mặc định icon trắng
        backgroundColor: Color = .blue,  // Mặc định nền xanh
        size: CGFloat = 48,
        depth: CGFloat = 4
    ) {
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.size = size
        self.depth = depth
        
        // LOGIC SHADOW: Shadow phải ăn theo màu NỀN (không phải màu icon)
        // Dùng opacity 0.5 hoặc 0.6 của màu nền để tạo bóng trùng tông
        self.shadowColor = backgroundColor.opacity(0.5)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            // A. ÁP DỤNG MÀU ICON
            .font(.system(size: size * 0.45, weight: .bold))
            .foregroundColor(iconColor)
            
            // B. ĐỊNH HÌNH KHUNG
            .frame(width: size, height: size)
            
            // C. ÁP DỤNG MÀU NỀN
            .background(backgroundColor)
            .clipShape(Circle())
            
            // D. HIỆU ỨNG 3D (SHADOW + OFFSET)
            .shadow(
                color: shadowColor,
                radius: 0,
                x: 0,
                y: isPressed ? 0 : depth // Nhấn thì mất bóng
            )
            .offset(y: isPressed ? depth : 0) // Nhấn thì lún xuống
            
            // E. ANIMATION
            .animation(
                .interactiveSpring(response: 0.3, dampingFraction: 0.6),
                value: isPressed
            )
    }
}

// MARK: - PREVIEW DEMO
struct CircleColorPreview: View {
    var body: some View {
        HStack(spacing: 30) {
            
            // CASE 1: Icon Trắng, Nền Xanh (Chuẩn 3D)
            Button {
                print("Play")
            } label: {
                Image(systemName: "speaker.wave.3.fill")
            }
            .buttonStyle(ThreeDCircleButtonStyle(
                iconColor: .white,
                backgroundColor: .blue
            ))
            
            // CASE 2: Icon Đỏ, Nền Vàng nhạt (Style cảnh báo/vui nhộn)
            Button { print("Stop") } label: {
                Image(systemName: "tortoise.fill")
            }
            .buttonStyle(ThreeDCircleButtonStyle(
                iconColor: .white,
                backgroundColor: .orange,
                size: 56,
                depth: 6
            ))
            
            // CASE 3: Icon Xanh, Nền Xanh Nhạt (Style cũ của bạn)
            Button { print("Sound") } label: {
                Image(systemName: "speaker.wave.2.fill")
            }
            .buttonStyle(ThreeDCircleButtonStyle(
                iconColor: .green,
                backgroundColor: .green.opacity(0.2) // Truyền nền nhạt vào đây
            ))
        }
        .padding()
    }
}

#Preview {
    CircleColorPreview()
}
