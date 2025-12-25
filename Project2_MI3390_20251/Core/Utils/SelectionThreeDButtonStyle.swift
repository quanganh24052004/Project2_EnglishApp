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
    var depth: CGFloat = 4
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        let backgroundColor = isSelected ? activeColor : .white
        
        let shadowColor = isSelected ? activeColor.opacity(0.5) : Color.gray.opacity(0.3)
        
        configuration.label
            .padding()
            .background(backgroundColor)
            .cornerRadius(16)
            .shadow(
                color: shadowColor,
                radius: 0,
                x: 0,
                y: isPressed ? 0 : depth
            )
            .offset(y: isPressed ? depth : 0)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}
