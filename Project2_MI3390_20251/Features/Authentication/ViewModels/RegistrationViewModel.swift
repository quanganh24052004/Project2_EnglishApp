//
//  RegistrationViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 2/1/26.
//

import SwiftUI
import Combine

/// ViewModel quản lý logic cho màn hình Đăng ký (RegistrationView).
class RegistrationViewModel: ObservableObject {
    
    // MARK: - Input Properties
    
    @Published var firstname = ""
    @Published var lastname = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    /// Trạng thái kiểm tra mật khẩu khớp nhau.
    @Published var passwordMatch = false
    
    // MARK: - State Properties
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingError = false
    
    // MARK: - Helper Methods
    
    /// Kiểm tra xem mật khẩu và xác nhận mật khẩu có trùng khớp không.
    func checkPasswordMatch() {
        passwordMatch = !password.isEmpty && (password == confirmPassword)
    }
    
    // MARK: - Actions
    
    /// Thực hiện hành động Đăng ký tài khoản mới.
    /// - Returns: `Void` nếu thành công, ném ra lỗi nếu thất bại.
    @MainActor
    func register() async throws {
        // Double check trước khi gọi API
        guard passwordMatch else {
            let error = AuthError.message("Mật khẩu xác nhận không khớp.")
            errorMessage = error.localizedDescription
            showingError = true
            throw error
        }
        
        isLoading = true
        
        do {
            // 1. Gọi API Đăng ký kèm Metadata (Họ tên, SĐT)
            _ = try await SupabaseAuthService.shared.signUp(
                email: email,
                password: password,
                firstName: firstname,
                lastName: lastname,
                phone: phone
            )
            
            // 2. Hoàn tất
            isLoading = false
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showingError = true
            throw error
        }
    }
}
