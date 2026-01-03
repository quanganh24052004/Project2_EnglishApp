//
//  AppTextField.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 20/12/25.
//  Refactored for Clean Code & Reusability.
//

import SwiftUI

/// Một component TextField tùy chỉnh hỗ trợ Icon, chế độ bảo mật (Password) và trạng thái Focus.
struct AppTextField: View {
    
    // MARK: - Properties
    
    /// Liên kết hai chiều với biến text bên ngoài.
    @Binding var text: String
    
    /// Placeholder hiển thị khi chưa có nội dung.
    let placeholder: String
    
    /// Tên icon hệ thống (SF Symbols) hiển thị bên trái (Optional).
    var iconName: String? = nil
    
    /// Cờ đánh dấu đây có phải là trường nhập mật khẩu hay không.
    var isSecure: Bool = false
    
    // MARK: - Private State
    
    /// Trạng thái hiển thị mật khẩu (ẩn/hiện).
    @State private var isShowPassword: Bool = false
    
    /// Trạng thái focus của TextField.
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            leadingIconView
            textFieldView
            trailingButtonView
        }
        .padding(16)
        .background(backgroundStyle)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
    
    // MARK: - Subviews
    
    /// View hiển thị Icon bên trái
    @ViewBuilder
    private var leadingIconView: some View {
        if let iconName = iconName {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(isFocused ? .orange : .gray)
                .frame(width: 24)
        }
    }
    
    /// Khu vực nhập liệu chính (Switch giữa SecureField và TextField)
    private var textFieldView: some View {
        Group {
            if isSecure && !isShowPassword {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .focused($isFocused)
        .font(.system(size: 15))
        .foregroundColor(.primary) // Dùng .primary thay vì .black để hỗ trợ Dark Mode tốt hơn (hoặc giữ .black nếu design bắt buộc)
        // Lưu ý: Đã bỏ frame height cố định để text không bị cắt nếu font hệ thống to lên
    }
    
    /// Các nút chức năng bên phải (Hiện mật khẩu / Xóa text)
    @ViewBuilder
    private var trailingButtonView: some View {
        if isSecure {
            // Nút ẩn/hiện mật khẩu
            Button {
                isShowPassword.toggle()
            } label: {
                Image(systemName: isShowPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.neutral04)
            }
        } else {
            // Nút xóa text (chỉ hiện khi có text và đang focus)
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
    
    /// Style nền và viền của TextField
    private var backgroundStyle: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(isFocused ? Color.orange : Color.neutral04, lineWidth: 2)
            .background(Color.white) // Nền trắng nội bộ
            .cornerRadius(16)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        VStack(spacing: 20) {
            AppTextField(text: .constant(""), placeholder: "Username", iconName: "person")
            AppTextField(text: .constant("123456"), placeholder: "Password", iconName: "lock", isSecure: true)
        }
        .padding()
    }
}
