//
//  LoginViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 2/1/26.
//

import SwiftUI
import Observation

/// ViewModel quản lý logic cho màn hình Đăng nhập (LoginView).
@Observable
class LoginViewModel {
    
    // MARK: - Input Properties
    
    /// Email người dùng nhập vào.
    var email = ""
    
    /// Mật khẩu người dùng nhập vào.
    var password = ""
    
    // MARK: - State Properties
    
    /// Trạng thái đang xử lý đăng nhập (để hiện Loading Spinner).
    var isLoading = false
    
    /// Nội dung lỗi cần hiển thị.
    var errorMessage: String?
    
    /// Cờ điều khiển việc hiển thị Alert lỗi.
    var showingError = false
    
    // MARK: - Actions
    
    /// Thực hiện hành động Đăng nhập.
    /// - Returns: `Void` nếu thành công, ném ra lỗi nếu thất bại.
    @MainActor
    func login() async throws {
        // Validate cơ bản
        guard !email.isEmpty, !password.isEmpty else {
            let error = AuthError.message("Vui lòng nhập đầy đủ Email và Mật khẩu.")
            errorMessage = error.localizedDescription
            showingError = true
            throw error
        }
        
        isLoading = true
        errorMessage = nil
        showingError = false
        
        do {
            // 1. Gọi API Supabase để đăng nhập
            _ = try await SupabaseAuthService.shared.signIn(email: email, password: password)
            
            // 2. Cập nhật trạng thái thành công
            isLoading = false
            
        } catch {
            // Xử lý lỗi
            isLoading = false
            errorMessage = error.localizedDescription
            showingError = true
            throw error
        }
    }
}
