import SwiftUI

// Giả lập màu custom của bạn để code chạy được ngay
extension Color {
    static let buttonMain = pGreen
}

struct ThreeDButtonStyle: ButtonStyle {
    // 1. Chỉ cần lưu các biến property
    let color: Color
    let depth: CGFloat
    let height: CGFloat
    // Biến private, tự tính toán, bên ngoài không cần quan tâm
    private let shadowColor: Color
    
    // 2. Custom Init để tính toán logic "Shadow ăn theo Main"
    init(color: Color = .buttonMain, depth: CGFloat = 5, height: CGFloat = 48) {
        self.color = color
        self.depth = depth
        self.height = height
        self.shadowColor = color.opacity(0.5)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .font(.system(size: 16, weight: .bold)) // Đã sửa lại thành system font để chạy được ngay
            .tracking(1.5)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(color)
            .cornerRadius(16)
            // Logic Shadow & Offset
            .shadow(
                color: shadowColor,
                radius: 0,
                x: 0,
                y: isPressed ? 0 : depth
            )
            .offset(y: isPressed ? depth : 0)
            .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.6), value: isPressed)
    }
}
// Preview để test ngay
struct ButtonPreview: View {
    var body: some View {
        VStack(spacing: 30) {
            Button("Tiếp tục") {
                print("Tapped!")
            }
            .buttonStyle(ThreeDButtonStyle()) // Dùng mặc định
            .padding(100)
            Button("TIẾP TỤC") {
                print("Next tapped!")
            }
            // Dùng custom (ví dụ màu xanh)
            .buttonStyle(ThreeDButtonStyle(color: .blue, depth: 6))
        }
        .padding()
    }
}

#Preview {
    ButtonPreview()
}
