//
//  AudioButtonStyle.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 21/12/25.
//

import SwiftUI

struct ThreeDCircleButtonStyle: ButtonStyle {
    
    let iconColor: Color
    let backgroundColor: Color
    let size: CGFloat
    let depth: CGFloat
    
    private let shadowColor: Color
    
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
        
        self.shadowColor = backgroundColor.opacity(0.5)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .font(.system(size: size * 0.45, weight: .bold))
            .foregroundColor(iconColor)
            
            .frame(width: size, height: size)
            
            .background(backgroundColor)
            .clipShape(Circle())
            
            .shadow(
                color: shadowColor,
                radius: 0,
                x: 0,
                y: isPressed ? 0 : depth
            )
            .offset(y: isPressed ? depth : 0)
            
            .animation(
                .interactiveSpring(response: 0.3, dampingFraction: 0.6),
                value: isPressed
            )
    }
}

// MARK: - PREVIEW DEMO
struct CircleColorPreview: View {
    var body: some View {
        HStack(spacing: 30) {
            
            Button {
                print("Play")
            } label: {
                Image(systemName: "speaker.wave.3.fill")
            }
            .buttonStyle(ThreeDCircleButtonStyle(
                iconColor: .white,
                backgroundColor: .blue
            ))
            
            Button { print("Stop") } label: {
                Image(systemName: "tortoise.fill")
            }
            .buttonStyle(ThreeDCircleButtonStyle(
                iconColor: .white,
                backgroundColor: .orange,
                size: 56,
                depth: 6
            ))
            
            Button { print("Sound") } label: {
                Image(systemName: "speaker.wave.2.fill")
            }
            .buttonStyle(ThreeDCircleButtonStyle(
                iconColor: .green,
                backgroundColor: .green.opacity(0.2) // Truyền nền nhạt vào đây
            ))
        }
        .padding()
    }
}

#Preview {
    CircleColorPreview()
}
