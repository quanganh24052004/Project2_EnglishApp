import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Nội dung text
            .font(.system(size: 15, weight: .semibold))
            .tracking(1.5) // letter-spacing: 1.5px
            .foregroundColor(.white)
            
            // Padding giống CSS
            .padding(.vertical, 17)
            .padding(.horizontal, 40)
            
            // Background + bo góc
            .background(
                Color(red: 255/255, green: 56/255, blue: 86/255) // rgb(255, 56, 86)
            )
            .cornerRadius(10)
            
            // Shadow giống box-shadow
            .shadow(
                color: Color(red: 201/255, green: 46/255, blue: 70/255),
                radius: 0,
                x: 0,
                y: configuration.isPressed ? 0 : 10 // normal: 10px, active: 0px
            )
            
            // Hiệu ứng nhấn: translateY(5px)
            .offset(y: configuration.isPressed ? 10 : 0)
            
            // Transition mượt giống transition: all 0.3s ease / 200ms
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
