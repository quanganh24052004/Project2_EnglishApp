//
//  BarChartShape.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 31/12/25.
//


//
//  BarChartShape.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//

import SwiftUI

struct BarChartShape: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight], // Chỉ bo 2 góc trên
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}