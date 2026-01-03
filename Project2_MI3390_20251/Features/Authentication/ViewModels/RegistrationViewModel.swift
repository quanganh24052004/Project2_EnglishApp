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
    /// - Parameters:
    ///   - authVM: ViewModel xác thực gốc.
    ///   - onSuccess: Closure gọi lại khi thành công.
    @MainActor
    func register(authVM: AuthViewModel, onSuccess: @escaping () -> Void) {
        // Double check trước khi gọi API
        guard passwordMatch else {
            errorMessage = "Mật khẩu xác nhận không khớp."
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // 1. Gọi API Đăng ký kèm Metadata (Họ tên, SĐT)
                _ = try await SupabaseAuthService.shared.signUp(
                    email: email,
                    password: password,
                    firstName: firstname,
                    lastName: lastname,
                    phone: phone
                )
                
                // 2. Tải thông tin user vừa tạo
                await authVM.fetchCurrentUser()
                
                // 3. Hoàn tất
                isLoading = false
                authVM.isAuthenticated = true
                onSuccess()
                
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}
