//
//  AuthViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//

import SwiftUI
import Combine
import Supabase // 1. Cần import thư viện này để dùng Auth.User

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // 2. Biến chứa thông tin người dùng (Firstname, Lastname, Email...)
    @Published var currentUser: Auth.User?
    
    func checkSession() {
        isLoading = true
        Task {
            // Kiểm tra xem đã đăng nhập chưa
            let loggedIn = await SupabaseAuthService.shared.isUserLoggedIn
            self.isAuthenticated = loggedIn
            
            // Nếu đã đăng nhập thì tải ngay thông tin user
            if loggedIn {
                await fetchCurrentUser()
            }
            self.isLoading = false
        }
    }
    
    // 3. Hàm lấy thông tin User hiện tại
    func fetchCurrentUser() async {
        // Gọi xuống Service để lấy user (bạn cần đảm bảo SupabaseAuthService có biến currentUser)
        // Hoặc gọi trực tiếp:
        if let user = await SupabaseAuthService.shared.currentUser {
            self.currentUser = user
        }
    }
    
    func signOut() {
        isLoading = true
        Task {
            do {
                try await SupabaseAuthService.shared.signOut()
                // Reset toàn bộ trạng thái về nil/false
                self.isAuthenticated = false
                self.currentUser = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
