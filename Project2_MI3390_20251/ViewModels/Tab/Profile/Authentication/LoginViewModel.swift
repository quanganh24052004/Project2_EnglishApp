//
//  LoginViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 2/1/26.
//  Refactored for Documentation Standards.
//

import SwiftUI
import Combine

/// ViewModel quản lý logic cho màn hình Đăng nhập (LoginView).
class LoginViewModel: ObservableObject {
    
    // MARK: - Input Properties
    
    /// Email người dùng nhập vào.
    @Published var email = ""
    
    /// Mật khẩu người dùng nhập vào.
    @Published var password = ""
    
    // MARK: - State Properties
    
    /// Trạng thái đang xử lý đăng nhập (để hiện Loading Spinner).
    @Published var isLoading = false
    
    /// Nội dung lỗi cần hiển thị.
    @Published var errorMessage: String?
    
    /// Cờ điều khiển việc hiển thị Alert lỗi.
    @Published var showingError = false
    
    // MARK: - Actions
    
    /// Thực hiện hành động Đăng nhập.
    /// - Parameters:
    ///   - authVM: ViewModel xác thực gốc để cập nhật trạng thái App.
    ///   - onSuccess: Closure được gọi khi đăng nhập thành công (thường dùng để dismiss View).
    @MainActor
    func login(authVM: AuthViewModel, onSuccess: @escaping () -> Void) {
        // Validate cơ bản
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Vui lòng nhập đầy đủ Email và Mật khẩu."
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // 1. Gọi API Supabase để đăng nhập
                _ = try await SupabaseAuthService.shared.signIn(email: email, password: password)
                
                // 2. Đồng bộ thông tin User về AuthViewModel toàn cục
                await authVM.fetchCurrentUser()
                
                // 3. Cập nhật trạng thái thành công
                isLoading = false
                authVM.isAuthenticated = true
                onSuccess()
                
            } catch {
                // Xử lý lỗi
                isLoading = false
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}
