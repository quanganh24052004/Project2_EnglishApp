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
            HStack(spacing: 16) {
                Image(systemName: option.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text(option.text)
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity) // Đảm bảo nút rộng full chiều ngang
        }
        .buttonStyle(SelectionThreeDButtonStyle(isSelected: isSelected))
    }
}
