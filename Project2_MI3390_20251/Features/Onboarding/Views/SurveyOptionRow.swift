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
                    .font(.system(size: 18, design: .rounded))
                
                Text(option.text)
                    .multilineTextAlignment(.leading)
                
                Spacer()
    
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(SelectionThreeDButtonStyle(isSelected: isSelected))
    }
}
