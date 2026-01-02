//
//  SupabaseAuthService.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//  Refactored for Best Practices & Session Fix.
//

import Foundation
import Supabase
import AuthenticationServices

/// Service quản lý xác thực người dùng với Supabase (Singleton Pattern).
final class SupabaseAuthService {
    
    // MARK: - Properties
    
    /// Instance duy nhất dùng chung cho toàn bộ ứng dụng.
    static let shared = SupabaseAuthService()
    
    /// Client chính để giao tiếp với Supabase.
    let client: SupabaseClient
    
    // MARK: - Initialization
    
    private init() {
        // Cấu hình Client với Options để xử lý Session nội bộ đúng chuẩn mới.
        // `emitLocalSessionAsInitialSession: true`: Đảm bảo App nhận được session cũ ngay khi mở,
        // tránh warning và lỗi logic khi kiểm tra đăng nhập.
        let options = SupabaseClientOptions(
            auth: .init(emitLocalSessionAsInitialSession: true)
        )
        
        self.client = SupabaseClient(
            supabaseURL: URL(string: Constants.projectURLString)!,
            supabaseKey: Constants.projectAPIKey,
            options: options
        )
    }
    
    // MARK: - Authentication Actions
    
    /// Đăng nhập bằng Email và Mật khẩu.
    func signIn(email: String, password: String) async throws -> Auth.User {
        let session = try await client.auth.signIn(email: email, password: password)
        return session.user
    }
    
    /// Đăng ký tài khoản mới kèm thông tin bổ sung (Metadata).
    /// - Parameters:
    ///   - firstName: Tên.
    ///   - lastName: Họ.
    ///   - phone: Số điện thoại.
    func signUp(email: String, password: String, firstName: String, lastName: String, phone: String) async throws -> Auth.User {
        let metadata: [String: AnyJSON] = [
            "first_name": .string(firstName),
            "last_name": .string(lastName),
            "phone": .string(phone)
        ]
        
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: metadata
        )
        
        return response.user
    }
    
    /// Đăng xuất khỏi thiết bị hiện tại.
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    /// Đăng nhập bằng Apple ID.
    func signInWithApple(idToken: String, nonce: String) async throws -> Auth.User {
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )
        return session.user
    }
    
    // MARK: - Session Management
    
    /// Lấy thông tin User hiện tại từ Session đang lưu trong máy.
    /// Trả về `nil` nếu không có session hoặc lỗi.
    var currentUser: Auth.User? {
        get async {
            return try? await client.auth.session.user
        }
    }
    
    /// Kiểm tra xem người dùng đã đăng nhập và phiên còn hạn hay không.
    /// Hàm này rất quan trọng để quyết định điều hướng vào App chính hay màn hình Login.
    var isUserLoggedIn: Bool {
        get async {
            do {
                let session = try await client.auth.session
                // Kiểm tra thêm isExpired để chắc chắn Token còn dùng được
                return !session.isExpired
            } catch {
                return false
            }
        }
    }
}

// MARK: - Custom Errors (Optional)

enum AuthError: Error {
    case unknown
    case message(String)
}
