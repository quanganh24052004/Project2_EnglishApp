//
//  ButtonStyle.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 25/12/25.
//

import SwiftUI

extension Color {
    static let buttonMain = pGreen
}

struct ThreeDButtonStyle: ButtonStyle {
    let color: Color
    let depth: CGFloat
    let height: CGFloat
    private let shadowColor: Color
    
    init(color: Color = .buttonMain, depth: CGFloat = 5, height: CGFloat = 48) {
        self.color = color
        self.depth = depth
        self.height = height
        self.shadowColor = color.opacity(0.5)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .tracking(1.5)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(color)
            .cornerRadius(16)
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
struct ButtonPreview: View {
    var body: some View {
        VStack(spacing: 30) {
            Button("Tiếp tục") {
                print("Tapped!")
            }
            .buttonStyle(ThreeDButtonStyle())
            .padding(100)
            Button("TIẾP TỤC") {
                print("Next tapped!")
            }
            .buttonStyle(ThreeDButtonStyle(color: .blue, depth: 6))
        }
        .padding()
    }
}

#Preview {
    ButtonPreview()
}
