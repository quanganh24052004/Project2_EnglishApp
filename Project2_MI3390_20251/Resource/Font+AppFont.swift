//
//  AppFontName.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 15/12/25.
//


import SwiftUI

enum AppFontName {
    // THAY THẾ CHUỖI DƯỚI ĐÂY BẰNG TÊN THỰC TẾ
    static let regular = "ChalkboardSE"
    static let semiBold = "ChalkboardSE-Light"
    static let bold = "ChalkboardSE-Bold"
}

extension Font {
    static func appFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        
        switch weight {
        case .bold:
            name = AppFontName.bold
        case .semibold:
            name = AppFontName.semiBold
        default: 
            name = AppFontName.regular
        }
        
        return .custom(name, size: size)
    }
}
