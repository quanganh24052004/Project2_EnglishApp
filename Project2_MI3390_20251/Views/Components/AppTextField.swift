//
//  AppTextField.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 15/12/25.
//


import SwiftUI
// Đặt bên ngoài struct View chính
enum FieldFocus {
    case field
}
import SwiftUI

struct AppTextField: View {
    @Binding var text: String
    
    let placeholder: String
    let iconName: String
    let isSecure: Bool
    
    @FocusState private var fieldIsFocused: FieldFocus?
    
    // Giữ nguyên enum ở ngoài struct
    enum FieldFocus {
        case field
    }

    var body: some View {
        HStack(spacing: 12) {
//            Image(systemName: iconName)
//                .foregroundColor(.gray)
//                .frame(width: 24, height: 24)
//            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        // 1. Gán trạng thái focus cho SecureField
                        .focused($fieldIsFocused, equals: .field)
                } else {
                    TextField(placeholder, text: $text)
                        // 2. Gán trạng thái focus cho TextField
                        .focused($fieldIsFocused, equals: .field)
                        // onEditingChanged không còn cần thiết cho việc thay đổi UI
                }
            }
            .font(.appFont(size: 16, weight: .regular))
            
            // Nút xóa nhanh: kiểm tra focus qua fieldIsFocused
            if !text.isEmpty && fieldIsFocused == .field {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                // 3. Thay đổi giao diện dựa trên fieldIsFocused
                .stroke(fieldIsFocused == .field ? Color.blue : Color.gray.opacity(0.4), lineWidth: 1.5)
        )
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.15), value: fieldIsFocused) // Animation mượt mà hơn
    }
}

// Ứng dụng mẫu
struct TextFieldDemoView: View {
    // State để lưu trữ dữ liệu
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Đăng nhập")
                .font(.appFont(size: 30, weight: .bold))
                .padding(.bottom, 30)

            // Custom Email Field
            AppTextField(
                text: $email, 
                placeholder: "Địa chỉ Email", 
                iconName: "envelope", 
                isSecure: false
            )
            .textContentType(.emailAddress) // Gợi ý hệ thống cho bàn phím

            // Custom Password Field (Secure)
            AppTextField(
                text: $password, 
                placeholder: "Mật khẩu", 
                iconName: "lock", 
                isSecure: true
            )
            .textContentType(.password) // Gợi ý hệ thống cho bàn phím
        }
    }
}

#Preview {
    TextFieldDemoView()
}
