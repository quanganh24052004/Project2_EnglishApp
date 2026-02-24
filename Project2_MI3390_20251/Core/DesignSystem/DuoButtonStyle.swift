//
//  DuoButtonStyle.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 4/2/26.
//


import SwiftUI

struct DuoButtonStyle: ButtonStyle {
    
    // MARK: - Configuration
    var mainColor: Color        // Màu mặt nút (VD: Xanh lá sáng)
    var shadowColor: Color      // Màu cạnh dưới (VD: Xanh lá đậm)
    var textColor: Color = .white
    var height: CGFloat = 50
    var depth: CGFloat = 4      // Độ dày của nút (phần 3D)
    var cornerRadius: CGFloat = 16
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        // Logic: Khi nhấn thì offset = 0 (lún xuống), khi thả thì offset = -depth (nổi lên)
        let yOffset = isPressed ? 0 : -depth
        
        return configuration.label
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            
            // --- LAYER 1: MẶT NÚT (FACE) ---
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(mainColor)
                    // Thêm viền nhẹ bên trong cho mặt nút (Optional - Duolingo cũ hay dùng)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            .padding(1) // Padding để viền nằm lọt bên trong
                    )
            )
            // --- XỬ LÝ 3D & ANIMATION ---
            // Đẩy mặt nút lên trên để lộ Layer 2
            .offset(y: yOffset)
            
            // --- LAYER 2: CẠNH ĐÁY (EDGE/SHADOW) ---
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(shadowColor)
                    // Cạnh đáy nằm cố định, không di chuyển
            )
            // Hiệu ứng nảy (Bouncy) đặc trưng của Duolingo
            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: isPressed)
    }
}

// MARK: - Extension để gọi nhanh
extension ButtonStyle where Self == DuoButtonStyle {
    static var duoPrimary: DuoButtonStyle {
        DuoButtonStyle(mainColor: Color(hex: "58CC02"), shadowColor: Color(hex: "58A700"))
    }
    
    static var duoSecondary: DuoButtonStyle {
        DuoButtonStyle(mainColor: .white, shadowColor: Color(hex: "E5E5E5"), textColor: .blue, depth: 2)
    }
    
    static var duoDanger: DuoButtonStyle {
        DuoButtonStyle(mainColor: .red, shadowColor: Color.red.opacity(0.6))
    }
    
    // Hàm tuỳ chỉnh
    static func duo(color: Color, shadow: Color) -> DuoButtonStyle {
        DuoButtonStyle(mainColor: color, shadowColor: shadow)
    }
}

// Helper Hex Color (Nếu project bạn chưa có)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}