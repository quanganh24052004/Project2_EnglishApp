//
//  CapyColors.swift
//  Project2_MI3390_20251
//
//  Refactored for Unified Architecture
//

import SwiftUI

// MARK: - 1. COLOR PALETTE
public struct CapyColors {
    // Grayscale / Adaptive Colors
    public static let swan = Color(UIColor.systemGray6) // Light gray in light, dark gray in dark
    public static let swanShadow = Color(UIColor.systemGray4)
    public static let swanText = Color(UIColor.secondaryLabel)
    public static let swanBorder = Color(UIColor.separator)
    
    // Brand Colors (Dynamic Tints)
    public static let blueJay = Color.blue // Use system blue for automatic adaptation
    public static let blueJayShadow = Color.blue.opacity(0.8)
    public static let iguana = Color.blue.opacity(0.15)
    public static let whale = Color.blue
    
    public static let green = Color.green
    public static let greenShadow = Color.green.opacity(0.8)
    
    public static let red = Color.red
    public static let redShadow = Color.red.opacity(0.8)
    
    // Backgrounds
    public static let background = Color(UIColor.systemBackground)
    public static let secondaryBackground = Color(UIColor.secondarySystemBackground)
}

// MARK: - 2. UNIFIED BUTTON STYLE

public enum CapyButtonType {
    /// Nút chính (Ví dụ: Tiếp tục, Bỏ qua). Truyền màu nền, màu đổ bóng và màu chữ.
    case primary(color: Color, shadow: Color, textColor: Color = .white)
    /// Nút phụ (Nền trắng, viền xám)
    case secondary
    /// Nút dạng thẻ chọn lựa (Card). Có trạng thái trạng thái chọn hay không.
    case card(isChecked: Bool)
}

public struct CapyButtonStyle: ButtonStyle {
    public let type: CapyButtonType
    
    public init(_ type: CapyButtonType) {
        self.type = type
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        CapyButtonBody(configuration: configuration, type: type)
    }
}

private struct CapyButtonBody: View {
    let configuration: ButtonStyle.Configuration
    let type: CapyButtonType
    
    @Environment(\.isEnabled) private var isEnabled
    
    @ViewBuilder
    var body: some View {
        let isPressed = configuration.isPressed
        
        switch type {
        case .primary(let tColor, let tShadow, let tText):
            // Lấy màu trạng thái
            let mainColor = isEnabled ? tColor : CapyColors.swan
            let shadowColor = isEnabled ? tShadow : CapyColors.swanShadow
            let textColor = isEnabled ? tText : CapyColors.swanShadow
            let lip: CGFloat = 4.0
            
            let faceOffset: CGFloat = (!isEnabled || isPressed) ? lip : 0
            
            configuration.label
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundColor(textColor)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .offset(y: faceOffset)
                .background(
                    ZStack {
                        // Đế bóng
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(shadowColor)
                            .offset(y: lip)
                        
                        // Nền chính
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(mainColor)
                            .offset(y: faceOffset)
                    }
                )
                .padding(.bottom, lip)
                .animation(.spring(response: 0.2, dampingFraction: 0.55), value: faceOffset)
                .animation(.easeInOut(duration: 0.2), value: isEnabled)
                
        case .secondary:
            let mainColor = isEnabled ? CapyColors.background : CapyColors.swan
            let shadowColor = isEnabled ? CapyColors.swanShadow : CapyColors.swanShadow
            let textColor = isEnabled ? CapyColors.blueJay : CapyColors.swanText
            let lip: CGFloat = 4.0
            
            let faceOffset: CGFloat = (!isEnabled || isPressed) ? lip : 0
            
            configuration.label
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundColor(textColor)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .offset(y: faceOffset)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(shadowColor)
                            .offset(y: lip)
                        
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(mainColor)
                            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(CapyColors.swanBorder, lineWidth: 2))
                            .offset(y: faceOffset)
                    }
                )
                .padding(.bottom, lip)
                .animation(.spring(response: 0.2, dampingFraction: 0.55), value: faceOffset)
                .animation(.easeInOut(duration: 0.2), value: isEnabled)
            
        case .card(let isChecked):
            let borderColor = isChecked ? CapyColors.blueJay : CapyColors.swanBorder
            let bgColor = isChecked ? CapyColors.iguana : CapyColors.background
            let textColor = !isEnabled ? CapyColors.swanText : (isChecked ? CapyColors.whale : Color.primary)
            let lip: CGFloat = 2.0
            
            let faceOffset: CGFloat = (isPressed && isEnabled) ? lip : 0
            
            configuration.label
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .offset(y: faceOffset)
                .background(
                    ZStack {
                        // Viền đáy (đóng vai trò như bóng)
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(borderColor)
                            .offset(y: lip)
                        
                        // Khối chính chứa viền bao quanh
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(bgColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(borderColor, lineWidth: 2)
                            )
                            .offset(y: faceOffset)
                    }
                )
                .padding(.bottom, lip)
                .animation(.spring(response: 0.15, dampingFraction: 0.7), value: isPressed)
                .animation(.easeInOut(duration: 0.2), value: isChecked)
                .opacity(!isEnabled ? 0.6 : 1.0)
        }
    }
}

// MARK: - 3. EXTENSIONS CHO VIEW
public extension View {
    func capyButton(_ type: CapyButtonType) -> some View {
        self.buttonStyle(CapyButtonStyle(type))
    }
}

// MARK: - 4. SHOWCASE PREVIEW
struct CapyDesignSystemShowcase: View {
    @State private var isFormValid: Bool = false
    @State private var selectedCardIndex: Int? = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                Text("CapyVocab Design System")
                    .font(.title2.bold())
                    .padding(.top)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("1. Cards (Thẻ chọn)").font(.headline)
                    
                    Button(action: { selectedCardIndex = 0 }) {
                        HStack {
                            Text("A. Quả táo (Apple)")
                            Spacer()
                            if selectedCardIndex == 0 { Image(systemName: "checkmark.circle.fill").foregroundColor(CapyColors.blueJay) }
                        }
                    }
                    .capyButton(.card(isChecked: selectedCardIndex == 0))
                    
                    Button(action: { selectedCardIndex = 1 }) {
                        HStack {
                            Text("B. Quả chuối (Banana)")
                            Spacer()
                            if selectedCardIndex == 1 { Image(systemName: "checkmark.circle.fill").foregroundColor(CapyColors.blueJay) }
                        }
                    }
                    .capyButton(.card(isChecked: selectedCardIndex == 1))
                    
                    Button(action: {}) {
                        Text("C. Thẻ này bị khóa")
                    }
                    .capyButton(.card(isChecked: false))
                    .disabled(true)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("2. Primary Buttons").font(.headline)
                    
                    Toggle("Bật/Tắt trạng thái", isOn: $isFormValid)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                    
                    Button("Kiểm tra (Default)") {}
                        .capyButton(.primary(color: CapyColors.blueJay, shadow: CapyColors.blueJayShadow))
                        .disabled(!isFormValid)
                    
                    Button("Tiếp tục (Success)") {}
                        .capyButton(.primary(color: CapyColors.green, shadow: CapyColors.greenShadow))
                        .disabled(!isFormValid)
                    
                    Button("Bỏ qua (Danger)") {}
                        .capyButton(.primary(color: CapyColors.red, shadow: CapyColors.redShadow))
                        .disabled(!isFormValid)
                }
            }
            .padding(24)
        }
        .defersSystemGestures(on: .bottom)
    }
}

#Preview {
    CapyDesignSystemShowcase()
}
