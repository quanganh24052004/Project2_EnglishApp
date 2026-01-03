//
//  ChartBarItemView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 31/12/25.
//


//
//  ChartBarItemView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//

import SwiftUI

struct ChartBarItemView: View {
    // MARK: - Properties
    let value: Int
    let label: String
    let color: Color
    let maxValue: CGFloat
    let maxHeight: CGFloat
    let animationIndex: Int
    let isVisible: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 6) {
            Text("\(value) từ")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .opacity(isVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: isVisible)
            
            BarChartShape(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.6), color],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .scaleEffect(y: isVisible ? 1 : 0, anchor: .bottom)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7)
                    .delay(Double(animationIndex) * 0.1),
                    value: isVisible
                )
                .frame(height: (CGFloat(value) / (maxValue == 0 ? 1 : maxValue)) * maxHeight)
                .frame(minHeight: 10)
            
            Text(label)
                .font(.system(size: 14, design: .rounded))
                .fontWeight(.bold)
        }
    }
}
