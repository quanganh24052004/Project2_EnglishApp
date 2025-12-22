//
//  AppTextField.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 20/12/25.
//

import SwiftUI

struct AppTextField: View {
    // MARK: - Properties
    @Binding var text: String
    
    let placeholder: String
    
    var iconName: String? = nil
    
    var isSecure: Bool = false
    
    @State private var isShowPassword: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isFocused ? .blue : .gray)
                    .frame(width: 24)
            }
            
            Group {
                if isSecure && !isShowPassword {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .focused($isFocused)
            
            if isSecure {
                Button {
                    isShowPassword.toggle()
                } label: {
                    Image(systemName: isShowPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.neutral04)
                }
            } else {
                if !text.isEmpty && isFocused {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.neutral04)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isFocused ? Color.blue : Color.neutral04, lineWidth: 2)
                .background(Color.white)
                .cornerRadius(16)
        )
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
