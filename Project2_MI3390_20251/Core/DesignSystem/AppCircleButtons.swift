//
//  AppCircleButtons.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 21/12/25.
//  Refactored for Documentation Standards.
//

import SwiftUI

// MARK: - 1. Button Style Definition

/// Style nút bấm hình tròn dạng 3D (Three-Dimensional Circle).
///
/// Style này tạo ra nút hình tròn với hiệu ứng đổ bóng và nhấn xuống.
/// Thường dùng cho các nút chức năng như: Phát âm thanh, Dịch, Gợi ý...
struct ThreeDCircleButtonStyle: ButtonStyle {
    
    // MARK: - Configuration Properties
    
    /// Màu của icon bên trong.
    let iconColor: Color
    
    /// Màu nền của nút.
    let backgroundColor: Color
    
    /// Đường kính của nút (Width = Height).
    let size: CGFloat
    
    /// Độ sâu của hiệu ứng 3D (Khoảng cách dịch chuyển khi nhấn).
    let depth: CGFloat
    
    /// Màu đổ bóng (Được tính toán tự động dựa trên backgroundColor).
    private let shadowColor: Color
    
    // MARK: - Initialization
    
    /// Khởi tạo style nút tròn 3D.
    /// - Parameters:
    ///   - iconColor: Màu icon (Mặc định: .white).
    ///   - backgroundColor: Màu nền (Mặc định: .blue).
    ///   - size: Kích thước nút (Mặc định: 48).
    ///   - depth: Độ sâu hiệu ứng (Mặc định: 4).
    init(
        iconColor: Color = .white,
        backgroundColor: Color = .blue,
        size: CGFloat = 48,
        depth: CGFloat = 4
    ) {
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.size = size
        self.depth = depth
        
        // Tự động tạo màu bóng bằng cách giảm độ đậm của màu nền
        self.shadowColor = backgroundColor.opacity(0.5)
    }
    
    // MARK: - Body Implementation
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            // Icon size tỉ lệ thuận với button size (45%)
            .font(.system(size: size * 0.45, weight: .bold))
            .foregroundColor(iconColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .clipShape(Circle())
            // Lớp bóng (Shadow)
            .shadow(
                color: shadowColor,
                radius: 0,
                x: 0,
                y: isPressed ? 0 : depth
            )
            // Hiệu ứng dịch chuyển
            .offset(y: isPressed ? depth : 0)
            // Animation nảy nhẹ
            .animation(
                .interactiveSpring(response: 0.3, dampingFraction: 0.6),
                value: isPressed
            )
    }
}

// MARK: - 2. Pre-configured Buttons (Các nút bấm dựng sẵn)

/// Nút phát âm thanh chuẩn (Icon Loa).
/// - Size: 64pt, Màu: Xanh dương.
struct AudioButton: View {
    /// Hành động khi nhấn nút.
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "speaker.wave.3.fill")
        }
        .buttonStyle(ThreeDCircleButtonStyle(
            iconColor: .white,
            backgroundColor: .blue,
            size: 64
        ))
    }
}

/// Nút phát âm thanh chậm (Icon Con rùa).
/// - Size: Mặc định (48pt), Màu: Cam.
struct SlowAudioButton: View {
    /// Hành động khi nhấn nút.
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "tortoise.fill")
        }
        .buttonStyle(ThreeDCircleButtonStyle(
            iconColor: .white,
            backgroundColor: .orange
        ))
    }
}

/// Nút dịch thuật (Icon Translate).
/// - Size: Nhỏ (32pt), Màu: Xanh dương.
struct TranslateButton: View {
    /// Hành động khi nhấn nút.
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "translate")
        }
        .buttonStyle(ThreeDCircleButtonStyle(
            iconColor: .white,
            backgroundColor: .blue,
            size: 32
        ))
    }
}

/// Nút sổ tay/từ điển (Icon Sách).
/// - Size: 48pt, Màu: Xanh lá (PGreen).
struct HandbookButton: View {
    /// Hành động khi nhấn nút.
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "books.vertical.fill")
        }
        // Giả định .pGreen là màu custom trong Assets của bạn
        .buttonStyle(ThreeDCircleButtonStyle(
            iconColor: .white,
            backgroundColor: .green, // Hoặc .pGreen nếu project có extension Color
            size: 48
        ))
    }
}

// MARK: - Preview

#Preview("Audio Buttons Demo") {
    HStack(spacing: 30) {
        AudioButton { print("Normal Speed") }
        SlowAudioButton { print("Slow Speed") }
        TranslateButton { print("Translate") }
    }
    .padding()
}
