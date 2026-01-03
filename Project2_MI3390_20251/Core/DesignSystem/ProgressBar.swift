//
//  MarkedProgressBar.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 21/12/25.
//


import SwiftUI

struct ProgressBar: View {
    var value: Double
    var height: CGFloat = 12
    var color: Color = .orange
    var backgroundColor: Color = Color.white
    var iconName: String
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let progress = min(max(value, 0), 1)
            let fillWidth = width * CGFloat(progress)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(backgroundColor)
                    .frame(height: height)
                
                Capsule()
                    .fill(color)
                    .frame(width: fillWidth, height: height)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
                
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .font(.system(size: height * 1.5)) // Icon to gấp 1.5 lần thanh bar
                    .foregroundColor(color)
                    .shadow(radius: 2)
                    .offset(x: fillWidth - (height * 1.5 / 2))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)

            }
            .frame(height: height * 2)
        }
        .frame(height: height * 2)
    }
}
