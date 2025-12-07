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
                // Icon (Thay đổi màu sắc dựa trên trạng thái chọn)
                Image(systemName: option.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .white : .orange) // Màu icon
                
                // Text
                Text(option.text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .black) // Màu chữ
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Dấu tick nếu được chọn
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.orange : Color.white) // Màu nền
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.orange : Color.gray.opacity(0.2), lineWidth: 1) // Viền
            )
        }
        .buttonStyle(PlainButtonStyle()) // Bỏ hiệu ứng nhấp nháy mặc định
    }
}
