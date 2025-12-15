//
//  AppFontName.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 15/12/25.
//


import SwiftUI

// 💡 TIPS: In ra Console để tìm tên PostScript chính xác nếu bị lỗi
/*
    for family in UIFont.familyNames.sorted() {
        let names = UIFont.fontNames(forFamilyName: family)
        print("Family: \(family) Font names: \(names)")
    }
*/

// Định nghĩa tên PostScript chính xác của các font
enum AppFontName {
    // THAY THẾ CHUỖI DƯỚI ĐÂY BẰNG TÊN THỰC TẾ
    static let regular = "ChalkboardSE"
    static let semiBold = "ChalkboardSE-Light"
    static let bold = "ChalkboardSE-Bold"
}

extension Font {
    /// Custom font của dự án (Ví dụ: Roboto, Montserrat)
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
