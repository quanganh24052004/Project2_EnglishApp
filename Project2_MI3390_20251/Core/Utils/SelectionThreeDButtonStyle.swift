//
//  SelectionThreeDButtonStyle.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 25/12/25.
//
import SwiftUI

struct SelectionThreeDButtonStyle: ButtonStyle {
    var isSelected: Bool
    var activeColor: Color = .orange
    var depth: CGFloat = 4 // Độ dày 3D
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        // 1. Tính toán màu sắc dựa trên trạng thái select
        let backgroundColor = isSelected ? activeColor : .white
        
        // Màu bóng: Nếu đang chọn thì bóng màu cam đậm, nếu không thì bóng xám nhẹ
        let shadowColor = isSelected ? activeColor.opacity(0.5) : Color.gray.opacity(0.3)
        
        configuration.label
            .padding() // Padding cho nội dung bên trong
            .background(backgroundColor)
            .cornerRadius(16)
            // 2. Logic 3D Shadow (thay thế cho Stroke/Overlay cũ)
            .shadow(
                color: shadowColor,
                radius: 0,
                x: 0,
                y: isPressed ? 0 : depth // Khi nhấn thì mất bóng
            )
            // 3. Logic Offset (Hạ xuống khi nhấn)
            .offset(y: isPressed ? depth : 0)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}
