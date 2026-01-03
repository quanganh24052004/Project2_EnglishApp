//
//  ReviewChartView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//

import SwiftUI

struct ReviewChartView: View {
    // MARK: - Properties
    let dataPoints: [Int]
    let labels: [String] = ["Lv 0", "Lv 1", "Lv 2", "Lv 3", "Lv 4", "Lv 5"]
    
    private let colors: [Color] = [.gray, .red.opacity(0.8), .yellow, .cyan, .blue, .purple]
    private let chartHeight: CGFloat = 200
    
    // State Animation
    @State private var isVisible: Bool = false
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // Container chính
            ZStack(alignment: .bottom) {
                
                Rectangle()
                    .frame(height: 3)
                    .foregroundStyle(Color.neutral03)
                    .padding(.bottom, 20)
                
                HStack(alignment: .bottom, spacing: 6) {
                    let maxValue = CGFloat(dataPoints.max() ?? 1)
                    
                    ForEach(0..<min(dataPoints.count, labels.count), id: \.self) { index in
                        ChartBarItemView(
                            value: dataPoints[index],
                            label: labels[index],
                            color: colors[index % colors.count],
                            maxValue: maxValue,
                            maxHeight: chartHeight,
                            animationIndex: index,
                            isVisible: isVisible
                        )
                    }
                }
                .frame(height: chartHeight + 40)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
        .padding()
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.neutral01
        ReviewChartView(dataPoints: [5, 12, 8, 20, 15, 3])
    }
}
