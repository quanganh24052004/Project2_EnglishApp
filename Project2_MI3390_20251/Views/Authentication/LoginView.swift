//
//  LoginView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var currentNonce: String?

    // Logic Login Email
    func login() {
            // 1. Kiểm tra đầu vào
        guard !email.isEmpty, !password.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                // 2. Gọi API đăng nhập Supabase
                let _ = try await SupabaseAuthService.shared.signIn(email: email, password: password)
                
                // 3. QUAN TRỌNG: Cập nhật trạng thái UI trên luồng chính
                await MainActor.run {
                    isLoading = false
                    
                    // 👉 DÒNG NÀY SẼ CHUYỂN MÀN HÌNH
                    // Khi biến này thành true, RootView sẽ thay thế LoginView bằng MainTabView ngay lập tức
                    authVM.isAuthenticated = true
                    
                    // Nếu LoginView được mở dạng sheet (từ Profile), dòng này sẽ đóng nó lại
                    dismiss()
                }
            } catch {
                // 4. Xử lý lỗi
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    func handleAppleLogin(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                return
            }
            
            isLoading = true
            Task {
                do {
                    let _ = try await SupabaseAuthService.shared.signInWithApple(idToken: idTokenString, nonce: nonce)
                    await MainActor.run {
                        isLoading = false
                        authVM.isAuthenticated = true
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                }
            }
        case .failure(let error):
            print("Apple Sign In Failed: \(error.localizedDescription)")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image("img_hi_capy") // Đảm bảo ảnh có trong Assets
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .padding(.vertical, 28)
            Text("Free, join now\n and start learning today!")
                .multilineTextAlignment(.center)
                .font(.system(size: 22, weight: .bold))
                .frame(height: 56)
            
            VStack(spacing: 24) {
                VStack (spacing: 8) {
                    HStack {
                        Text("Email address")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .frame(height: 20)
                            .foregroundColor(.neutral08)
                        Spacer()
                    }
                    AppTextField(text: $email, placeholder: "Enter your email address", isSecure: false)
                }
                VStack (spacing: 8) {
                    HStack {
                        Text("Password")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .frame(height: 20)
                            .foregroundColor(.neutral08)
                        Spacer()
                    }
                    AppTextField(text: $password, placeholder: "Enter your password", isSecure: true)
                }
                
                HStack {
                    Button("Forget Password?") { print("Tap Forgot Password") }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary02)
                    Spacer()
                }
            }
            .padding(.vertical, 32)
            
            Button(isLoading ? "Loading..." : "Login") {
                login()
            }
            .buttonStyle(ThreeDButtonStyle(color: .pGreen))
            .disabled(isLoading)
            .alert("Error", isPresented: $showingError) { Button("OK") {} } message: { Text(errorMessage ?? "") }
            
            // Divider OR
            VStack(spacing: 16) {
                HStack(spacing: 15) {
                    Rectangle().frame(height: 0.8).foregroundColor(.neutral04)
                    Text("Or").font(.system(size: 15)).foregroundColor(.neutral04)
                    Rectangle().frame(height: 0.8).foregroundColor(.neutral04)
                }
            }
            .padding(.vertical, 24)
            
            // Social Buttons
            HStack(spacing: 15) {
                Button { print("Google Login") } label: {
                    HStack { Image("img_google").resizable().frame(width: 24, height: 24) }
                }
                .buttonStyle(ThreeDButtonStyle(color: .black, height: 50))
                
                Button { } label: {
                    HStack { Image(systemName: "applelogo").resizable().scaledToFit().frame(width: 24, height: 24).foregroundColor(.white) }
                }
                .buttonStyle(ThreeDButtonStyle(color: .black, height: 50))
            }
            
            Spacer()
            
            NavigationLink {
                RegistrationView()
                    .navigationBarBackButtonHidden()
            } label: {
                HStack(spacing: 3) {
                    Text("Don't have an account?").foregroundColor(.neutral08)
                    Text("Sign up").fontWeight(.semibold).foregroundColor(.primary02)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color.neutral01)
        .ignoresSafeArea()
    }
}
