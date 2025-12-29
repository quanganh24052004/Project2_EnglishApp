//
//  SupabaseAuthService.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//

import Foundation
import Supabase
import AuthenticationServices

class SupabaseAuthService {
    static let shared = SupabaseAuthService()
    
    let client: SupabaseClient
    
    private init() {
        // 1. Cấu hình để tắt warning và xử lý session đúng chuẩn mới
        // Dùng 'Supabase.AuthClientOptions' để tránh lỗi "Module 'Auth' has no member..."
        self.client = SupabaseClient(
            supabaseURL: URL(string: Constants.projectURLString)!,
            supabaseKey: Constants.projectAPIKey,
        )
    }
    
    // MARK: - Email & Password
    
    func signIn(email: String, password: String) async throws -> Auth.User {
        let session = try await client.auth.signIn(email: email, password: password)
        return session.user
    }
    
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
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    // MARK: - Apple Sign In
    
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
    
    // MARK: - Session & User
    
    // 2. Helper lấy User hiện tại (Dùng cho AuthViewModel và ProfileView)
    var currentUser: Auth.User? {
        get async {
            // Lấy user từ session hiện tại
            return try? await client.auth.session.user
        }
    }
    
    // 3. Kiểm tra trạng thái đăng nhập (Có check hết hạn token)
    var isUserLoggedIn: Bool {
        get async {
            do {
                let session = try await client.auth.session
                return !session.isExpired
            } catch {
                return false
            }
        }
    }
}

enum AuthError: Error {
    case userNotFound
}
