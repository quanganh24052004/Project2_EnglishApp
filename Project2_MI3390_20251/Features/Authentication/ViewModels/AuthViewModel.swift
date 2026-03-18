//
//  AuthViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//

import SwiftUI
import Supabase
import Observation

/// ViewModel quản lý trạng thái xác thực toàn cục của ứng dụng.
/// Chịu trách nhiệm kiểm tra phiên đăng nhập, lưu trữ thông tin User hiện tại và xử lý Đăng xuất.
@Observable
@MainActor
class AuthViewModel {
    
    // MARK: - Properties
    
    /// Trạng thái xác thực: `true` nếu đã đăng nhập, ngược lại là `false`.
    var isAuthenticated: Bool = false
    
    /// Trạng thái tải dữ liệu (Loading).
    var isLoading: Bool = false
    
    /// Thông báo lỗi nếu có (dùng để hiển thị Alert).
    var errorMessage: String?
    
    /// Thông tin chi tiết của người dùng hiện tại (lấy từ Supabase Auth).
    var currentUser: Auth.User?
    
    // MARK: - Initialization
    
    init() {
        // Tự động kiểm tra phiên khi khởi tạo (nếu cần thiết)
        // checkSession()
    }
    
    // MARK: - Session Management
    
    /// Kiểm tra phiên đăng nhập hiện tại khi App khởi động.
    /// Nếu phiên còn hạn, tự động tải thông tin User và chuyển vào màn hình chính.
    func checkSession() {
        isLoading = true
        
        Task {
            // Kiểm tra trạng thái logged in từ Service
            let loggedIn = await SupabaseAuthService.shared.isUserLoggedIn
            self.isAuthenticated = loggedIn
            
            if loggedIn {
                await fetchCurrentUser()
            }
            
            self.isLoading = false
        }
    }
    
    /// Tải thông tin chi tiết của User từ Session hiện tại.
    func fetchCurrentUser() async {
        if let user = await SupabaseAuthService.shared.currentUser {
            self.currentUser = user
            print("✅ [AuthViewModel] User fetched: \(user.email ?? "No Email")")
        } else {
            print("⚠️ [AuthViewModel] Failed to fetch user details.")
        }
    }
    
    // MARK: - Authentication Actions
    
    /// Đăng xuất khỏi tài khoản và xóa sạch trạng thái local.
    func signOut() {
        isLoading = true
        
        Task {
            do {
                try await SupabaseAuthService.shared.signOut()
                
                // Reset trạng thái về mặc định
                self.isAuthenticated = false
                self.currentUser = nil
                print("👋 [AuthViewModel] Signed out successfully.")
                
            } catch {
                self.errorMessage = "Đăng xuất thất bại: \(error.localizedDescription)"
                print("❌ [AuthViewModel] Sign out error: \(error)")
            }
            
            self.isLoading = false
        }
    }
}
