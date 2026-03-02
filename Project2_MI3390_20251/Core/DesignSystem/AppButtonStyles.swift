//
//  AppButtonStyles.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 25/12/25.
//

import SwiftUI

// MARK: -1. Primary Button Style

struct PrimaryPhysicalButtonStyle: ButtonStyle {

    // MARK: - Environment
    @Environment(\.isEnabled) private var isEnabled

    // MARK: - Stored Properties

    private let textSize: CGFloat
    private let textColor: Color
    private let fontWeight: Font.Weight
    private let fontDesign: Font.Design
    private let backgroundColor: Color
    private let shadowColor: Color
    private let cornerRadius: CGFloat
    private let height: CGFloat
    private let heightShadow: CGFloat
    private let isFullWidth: Bool
    private let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle

    // MARK: - Init

    init(
        textSize: CGFloat = 16,
        textColor: Color = .primaryBG,
        fontWeight: Font.Weight = .bold,
        fontDesign: Font.Design = .rounded,
        backgroundColor: Color = .brand,
        shadowColor: Color = .shadow,
        cornerRadius: CGFloat = 16,
        height: CGFloat = 48,
        heightShadow: CGFloat = 4,
        isFullWidth: Bool = true,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    ) {
        self.textSize = textSize
        self.textColor = textColor
        self.fontWeight = fontWeight
        self.fontDesign = fontDesign
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.height = height
        self.heightShadow = heightShadow
        self.isFullWidth = isFullWidth
        self.hapticStyle = hapticStyle
    }

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        let maxWidth: CGFloat? = isFullWidth ? .infinity : nil
        
        let currentBgColor = isEnabled ? backgroundColor : .buttonDisable
        let currentTextColor = isEnabled ? textColor : .textDisable
        let currentShadowColor = isEnabled ? shadowColor : .clear

        // Khi nút nổi 3D (Enabled & Không bị đè ngón tay), offset của Label bằng 0.
        // Khi nút xẹp xuống (Bị Disable HOẶC bị đè), offset tụt xuống bằng độ sâu của bóng.
        let isFlat = !isEnabled || configuration.isPressed
        let labelOffset: CGFloat = isFlat ? heightShadow : 0

        ZStack {
            // Shadow Layer (Luôn cố định dính chặt tay ở độ sâu tối đa)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(currentShadowColor)
                .offset(y: heightShadow)
                .frame(maxWidth: maxWidth)
                .frame(height: height)

            // Lớp chứa Text + Background chính (Sẽ trồi/sụt trên nền shadow)
            configuration.label
                .font(.system(size: textSize, design: fontDesign))
                .fontWeight(fontWeight)
                .foregroundColor(currentTextColor)
                .frame(maxWidth: maxWidth)
                .frame(height: height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(currentBgColor)
                )
                .offset(y: labelOffset)
        }
        .frame(height: height + heightShadow)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .onChange(of: configuration.isPressed) { oldValue, newValue in
            if isEnabled && newValue && !oldValue {
                triggerHaptic(style: hapticStyle)
            }
        }
    }
}

// MARK: -2. Secondary Button Style
struct SecondaryPhysicalButtonStyle: ButtonStyle {

    // MARK: - Stored Properties

    private let textSize: CGFloat
    private let textColor: Color
    private let fontWeight: Font.Weight
    private let fontDesign: Font.Design
    private let backgroundColor: Color
    private let strokeColor: Color
    private let strokeWidth: CGFloat
    private let cornerRadius: CGFloat
    private let height: CGFloat
    private let heightShadow: CGFloat
    private let isFullWidth: Bool
    private let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle

    // MARK: - Init

    init(
        textSize: CGFloat = 16,
        textColor: Color = .brand,
        fontWeight: Font.Weight = .semibold,
        fontDesign: Font.Design = .rounded,
        backgroundColor: Color = .primaryBG,
        strokeColor: Color = .strokeBtn,
        strokeWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16,
        height: CGFloat = 48,
        heightShadow: CGFloat = 4,
        isFullWidth: Bool = true,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    ) {
        self.textSize = textSize
        self.textColor = textColor
        self.fontWeight = fontWeight
        self.fontDesign = fontDesign
        self.backgroundColor = backgroundColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.cornerRadius = cornerRadius
        self.height = height
        self.heightShadow = heightShadow
        self.isFullWidth = isFullWidth
        self.hapticStyle = hapticStyle
    }

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        let maxWidth: CGFloat? = isFullWidth ? .infinity : nil

        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(strokeColor)
                .offset(y: heightShadow)
                .frame(maxWidth: maxWidth)
                .frame(height: height)

            configuration.label
                .font(.system(size: textSize, design: fontDesign))
                .fontWeight(fontWeight)
                .foregroundColor(textColor)
                .frame(maxWidth: maxWidth)
                .frame(height: height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(strokeColor, lineWidth: strokeWidth)
                        )
                )
                .offset(y: configuration.isPressed ? heightShadow : 0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
        }
        .frame(height: height + heightShadow)
        .onChange(of: configuration.isPressed) { oldValue, newValue in
            if newValue && !oldValue {
                triggerHaptic(style: hapticStyle)
            }
        }
    }
}

public func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}

// MARK: - 1. Action Button Style (Nút bấm hành động)

/// Style nút bấm dạng 3D có hiệu ứng đổ bóng và nhấn xuống.
///
/// Style này tự động điều chỉnh màu chữ và màu bóng dựa trên màu nền:
/// - Nếu nền trắng: Chữ đen, bóng xám.
/// - Nếu nền màu: Chữ trắng, bóng là màu nền giảm độ đậm (opacity).
struct ThreeDButtonStyle: ButtonStyle {
    
    // MARK: - Configuration Properties
    
    /// Màu nền chính của nút.
    private let backgroundColor: Color
    
    /// Màu chữ (Được tính toán tự động dựa trên backgroundColor).
    private let textColor: Color
    
    /// Màu đổ bóng (Được tính toán tự động).
    private let shadowColor: Color
    
    /// Độ sâu của hiệu ứng 3D (khoảng cách dịch chuyển khi nhấn).
    private let depth: CGFloat
    
    /// Chiều cao cố định của nút.
    private let height: CGFloat
    
    // MARK: - Initialization
    
    /// Khởi tạo style nút 3D.
    /// - Parameters:
    ///   - color: Màu nền chính (Mặc định là .pGreen).
    ///   - depth: Độ sâu hiệu ứng nhấn (Mặc định là 5).
    ///   - height: Chiều cao nút (Mặc định là 48).
    init(color: Color = .pGreen, depth: CGFloat = 5, height: CGFloat = 48) {
        self.backgroundColor = color
        self.depth = depth
        self.height = height
        
        // Logic tự động tính toán màu tương phản
        if color == .white {
            self.textColor = .black
            self.shadowColor = Color(UIColor.systemGray3)
        } else {
            self.textColor = .white
            self.shadowColor = color.opacity(0.5)
        }
    }
    
    // MARK: - Body Implementation
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .font(.system(size: 18, design: .rounded))
            .fontWeight(.bold)
            .tracking(1.5)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(backgroundColor)
            .cornerRadius(16)
            // Lớp bóng (Shadow Layer)
            .shadow(
                color: shadowColor,
                radius: 0,
                x: 0,
                y: isPressed ? 0 : depth
            )
            // Hiệu ứng dịch chuyển khi nhấn
            .offset(y: isPressed ? depth : 0)
            // Animation nảy nhẹ
            .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.6), value: isPressed)
            // Viền nhẹ cho nút trắng để tách biệt với nền
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(backgroundColor == .white ? Color(UIColor.systemGray5) : Color.clear, lineWidth: 1)
                    .offset(y: isPressed ? depth : 0)
            )
    }
}

// MARK: - 2. Selection Button Style (Nút chọn lựa)

/// Style nút bấm 3D dùng cho các lựa chọn (Option/Toggle).
///
/// Style này hỗ trợ trạng thái `isSelected`. Khi được chọn, nút sẽ chuyển sang màu cam (Orange)
/// và viền đậm hơn để người dùng dễ nhận biết.
struct SelectionThreeDButtonStyle: ButtonStyle {
    
    // MARK: - Configuration Properties
    
    /// Trạng thái được chọn của nút.
    var isSelected: Bool
    
    private var color: Color
    private var strokeColor: Color
    private let shadowColor: Color = .neutral04
    private var depth: CGFloat
    private var height: CGFloat
    
    // MARK: - Initialization
    
    /// Khởi tạo style nút lựa chọn.
    /// - Parameters:
    ///   - isSelected: Trạng thái chọn hiện tại.
    ///   - color: Màu nền khi chưa chọn (Mặc định là .white).
    ///   - strokeColor: Màu viền khi chưa chọn (Mặc định là .neutral04).
    ///   - depth: Độ sâu hiệu ứng nhấn (Mặc định là 4).
    ///   - height: Chiều cao nút (Mặc định là 56).
    init(isSelected: Bool,
         color: Color = .primaryBG,
         strokeColor: Color = .border,
         depth: CGFloat = 4,
         height: CGFloat = 56) {
        
        self.isSelected = isSelected
        self.color = color
        self.strokeColor = strokeColor
        self.depth = depth
        self.height = height
    }
    
    // MARK: - Body Implementation
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        // Khi nhấn nút sẽ thụt xuống một đoạn bằng `depth`
        let currentOffset = isPressed ? depth : 0
        
        // Khi được chọn, bóng chuyển sang màu Cam, ngược lại là màu mặc định
        let activeShadowColor = isSelected ? Color.primary01 : shadowColor
        
        return configuration.label
            .font(.system(size: 16, design: .rounded))
            .fontWeight(.bold)
            .foregroundColor(isSelected ? .primary01 : .primaryText)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(isSelected ? .primary01.opacity(0.1) : .primaryBG)
            .background(
                ZStack {
                    color
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.primary01 : strokeColor, lineWidth: isSelected ? 3 : 3)
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
            // Animation khi nhấn và khi đổi trạng thái chọn
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

