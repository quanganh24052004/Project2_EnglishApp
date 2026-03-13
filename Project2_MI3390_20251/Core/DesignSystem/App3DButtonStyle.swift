//
//  App3DButtonStyle.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh
//

import SwiftUI

// MARK: - App Button Enums
public enum AppButtonRole {
    case primary      // Nút chính (ví dụ: Tiếp tục, Hoàn thành) -> default: xanh pGreen
    case secondary    // Nút phụ (ví dụ: Bỏ qua) -> default: nền trắng viền xám
    case destructive  // Nút huỷ/xoá -> default: đỏ
    case warning      // Nút cảnh báo -> default: cam
    case custom(color: Color, shadow: Color, text: Color)
    
    // Thuộc tính màu tuỳ role
    var backgroundColor: Color {
        switch self {
        case .primary: return Color("primary01", bundle: nil) // Hoặc .pGreen, tuỳ asset
        case .secondary: return .primaryBG
        case .destructive: return .red
        case .warning: return .orange
        case .custom(let color, _, _): return color
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .primary: return Color("primary01", bundle: nil).opacity(0.5) // Thay thế tuỳ asset bóng
        case .secondary: return .border
        case .destructive: return .red.opacity(0.5)
        case .warning: return .orange.opacity(0.5)
        case .custom(_, let shadow, _): return shadow
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary, .destructive, .warning: return .white
        case .secondary: return Color("brand", bundle: nil)
        case .custom(_, _, let text): return text
        }
    }
}

public enum AppButtonShape {
    case capsule
    case roundedRectangle(radius: CGFloat)
    case circle
    
    func applyShape<S: ShapeStyle>(content: AnyView, fill: S) -> AnyView {
        switch self {
        case .capsule:
            return AnyView(content.background(Capsule().fill(fill)))
        case .roundedRectangle(let radius):
            return AnyView(content.background(RoundedRectangle(cornerRadius: radius).fill(fill)))
        case .circle:
            return AnyView(content.background(Circle().fill(fill)))
        }
    }
    
    func applyStroke<S: ShapeStyle>(content: AnyView, stroke: S, lineWidth: CGFloat) -> AnyView {
        switch self {
        case .capsule:
            return AnyView(content.overlay(Capsule().stroke(stroke, lineWidth: lineWidth)))
        case .roundedRectangle(let radius):
            return AnyView(content.overlay(RoundedRectangle(cornerRadius: radius).stroke(stroke, lineWidth: lineWidth)))
        case .circle:
            return AnyView(content.overlay(Circle().stroke(stroke, lineWidth: lineWidth)))
        }
    }
}

// MARK: - Unified 3D Button Style
public struct App3DButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    let role: AppButtonRole
    let shape: AppButtonShape
    let depth: CGFloat
    let isFullWidth: Bool
    let height: CGFloat
    
    // Dành riêng cho state Selected (như nút Option)
    let isSelected: Bool
    
    public init(
        role: AppButtonRole = .primary,
        shape: AppButtonShape = .roundedRectangle(radius: 16),
        depth: CGFloat = 5,
        height: CGFloat = 48,
        isFullWidth: Bool = true,
        isSelected: Bool = false
    ) {
        self.role = role
        self.shape = shape
        self.depth = depth
        self.height = height
        self.isFullWidth = isFullWidth
        self.isSelected = isSelected
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let isFlat = !isEnabled || isPressed
        
        let labelOffset: CGFloat = isFlat ? depth : 0
        
        // Cấu hình linh hoạt dựa trên Role và State
        let currentBg = isEnabled ? (isSelected ? .primary01.opacity(0.1) : role.backgroundColor) : Color(UIColor.systemGray5)
        let currentText = isEnabled ? (isSelected ? .primary01 : role.textColor) : Color(UIColor.systemGray)
        let currentShadow = isEnabled ? (isSelected ? .primary01 : role.shadowColor) : Color.clear
        
        // Riêng Secondary sẽ có viền
        let isSecondary = (role.backgroundColor == .primaryBG)
        let strokeColor = isSelected ? .primary01 : (isSecondary ? role.shadowColor : .clear)
        let strokeWidth: CGFloat = (isSecondary || isSelected) ? 2 : 0
        
        ZStack {
            // Shadow Layer (đế bóng dưới cùng)
            shape.applyShape(content: AnyView(Color.clear), fill: currentShadow)
                .offset(y: depth)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .frame(height: height)
            
            // Lớp Nền và Chữ
            let mainBg = shape.applyShape(content: AnyView(Color.clear), fill: currentBg)
            let styledBg = shape.applyStroke(content: mainBg, stroke: strokeColor, lineWidth: strokeWidth)
            
            configuration.label
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(currentText)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .frame(height: height)
                .background(styledBg)
                .offset(y: labelOffset)
        }
        .frame(height: height + depth)
        // iOS 17+ Spring Animations
        .animation(.snappy, value: isPressed)
        .animation(.smooth, value: isEnabled)
        .animation(.smooth(duration: 0.2), value: isSelected)
    }
}

// MARK: - Tiện ích
extension View {
    func app3DButton(role: AppButtonRole = .primary, shape: AppButtonShape = .roundedRectangle(radius: 16), isFullWidth: Bool = true, isSelected: Bool = false) -> some View {
        self.buttonStyle(App3DButtonStyle(role: role, shape: shape, isFullWidth: isFullWidth, isSelected: isSelected))
    }
}
