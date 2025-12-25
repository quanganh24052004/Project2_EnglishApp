//
//  SurveyOptionRow.swift
//  OnboardingApp
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//


import SwiftUI

struct SurveyOptionRow: View {
    let option: SurveyOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: option.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .white : .orange) // Giữ logic đổi màu nội dung
                
                // Text
                Text(option.text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .black) // Giữ logic đổi màu chữ
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Dấu tick (Chỉ hiện khi chọn)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity) // Đảm bảo nút rộng full chiều ngang
        }
        // ÁP DỤNG STYLE Ở ĐÂY
        .buttonStyle(SelectionThreeDButtonStyle(isSelected: isSelected))
    }
}
