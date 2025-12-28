//
//  SelectionThreeDButtonStyle.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 25/12/25.
//

import SwiftUI

struct SelectionThreeDButtonStyle: ButtonStyle {
    // MARK: - Configuration
    var isSelected: Bool // Trạng thái quan trọng nhất: Đang được chọn hay không
    
    var color: Color
    var strokeColor: Color // Đã sửa từ 'strockColor' cho đúng chính tả
    private let shadowColor: Color
    var depth: CGFloat
    var height: CGFloat
    
    // Cập nhật init để nhận vào 'isSelected'
    init(isSelected: Bool,
         color: Color = .white,
         strokeColor: Color = .neutral04,
         depth: CGFloat = 4,
         height: CGFloat = 56) {
        
        self.isSelected = isSelected
        self.color = color
        self.strokeColor = strokeColor
        self.depth = depth
        self.height = height
        self.shadowColor = Color.neutral04
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        let currentOffset = isPressed ? depth : 0
        let activeShadowColor = isSelected ? Color.orange : shadowColor
        
        return configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isSelected ? .orange : .neutral04)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                ZStack {
                    color
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.orange : strokeColor, lineWidth: isSelected ? 3 : 1.5)
                }
            )
            .cornerRadius(16)
            .shadow(
                color: activeShadowColor,
                radius: 0,
                x: 0,
                y: isPressed ? 0 : depth
            )
            .offset(y: currentOffset)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
