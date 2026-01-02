//
//  LoginView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//  Refactored UI & Comments.
//

import SwiftUI
import AuthenticationServices

/// Màn hình Đăng nhập chính của ứng dụng.
struct LoginView: View {
    
    // MARK: - Properties
    
    /// ViewModel quản lý logic riêng của màn hình Login.
    @StateObject private var viewModel = LoginViewModel()
    
    /// ViewModel xác thực toàn cục (Shared).
    @EnvironmentObject var authVM: AuthViewModel
    
    /// Action để đóng màn hình hiện tại.
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Lớp nền (Tràn viền)
            Color.primary01.ignoresSafeArea()
            
            // Lớp nội dung (Sử dụng GeometryReader để xử lý Keyboard Avoidance)
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Spacer linh hoạt để đẩy nội dung xuống giữa
                        Spacer()
                        
                        headerView
                        
                        formView
                            .padding(.vertical, 32)
                        
                        loginButton
                        
                        dividerView
                        
                        socialButtons
                        
                        Spacer()
                        
                        footerLink
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 24)
                    // Đặt chiều cao tối thiểu bằng màn hình để Layout đẹp khi không có phím
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        // Hiển thị Alert khi có lỗi
        .alert("Thông báo", isPresented: $viewModel.showingError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Subviews & Components

extension LoginView {
    
    /// Header chứa Logo và Slogan.
    private var headerView: some View {
        VStack(spacing: 0) {
            Image("img_hi_capy")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .padding(.vertical, 28)
            
            Text("Free, join now\n and start learning today!")
                .multilineTextAlignment(.center)
                .font(.system(size: 22, design: .rounded))
                .fontWeight(.bold)
                .frame(height: 56)
        }
    }
    
    /// Form nhập liệu (Email & Password).
    private var formView: some View {
        VStack(spacing: 24) {
            inputField(title: "Email address", text: $viewModel.email, placeholder: "Enter your email address")
            
            VStack(spacing: 8) {
                inputField(title: "Password", text: $viewModel.password, placeholder: "Enter your password", isSecure: true)
                
                HStack {
                    Button("Forget Password?") {
                        print("Tap Forgot Password")
                    }
                    .font(.system(size: 15, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary02)
                    Spacer()
                }
            }
        }
    }
    
    /// Nút Đăng nhập chính.
    private var loginButton: some View {
        Button(viewModel.isLoading ? "Loading..." : "Login") {
            viewModel.login(authVM: authVM) {
                dismiss()
            }
        }
        .buttonStyle(ThreeDButtonStyle(color: .pGreen))
        .disabled(viewModel.isLoading)
    }
    
    /// Đường kẻ phân cách "Or".
    private var dividerView: some View {
        HStack(spacing: 15) {
            Rectangle().frame(height: 0.8).foregroundColor(.neutral04)
            Text("Or").font(.system(size: 15)).foregroundColor(.neutral04)
            Rectangle().frame(height: 0.8).foregroundColor(.neutral04)
        }
        .padding(.vertical, 24)
    }
    
    /// Các nút đăng nhập Mạng xã hội.
    private var socialButtons: some View {
        HStack(spacing: 15) {
            Button { print("Google Login") } label: {
                HStack { Image("img_google").resizable().frame(width: 24, height: 24) }
            }
            .buttonStyle(ThreeDButtonStyle(color: .black, height: 50))
            
            Button { } label: {
                HStack {
                    Image(systemName: "applelogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(ThreeDButtonStyle(color: .black, height: 50))
        }
    }
    
    /// Link đăng ký tài khoản.
    private var footerLink: some View {
        NavigationLink {
            RegistrationView()
                .navigationBarBackButtonHidden()
        } label: {
            HStack(spacing: 3) {
                Text("Don't have an account?").foregroundColor(.neutral08)
                    .font(.system(size: 12, design: .rounded))
                    .fontWeight(.medium)
                Text("Sign up").fontWeight(.semibold).foregroundColor(.primary02)
                    .font(.system(size: 12, design: .rounded))
                    .fontWeight(.medium)
            }
            .padding(8)
        }
    }
    
    /// Hàm tiện ích tạo TextField có tiêu đề.
    @ViewBuilder
    private func inputField(title: String, text: Binding<String>, placeholder: String, isSecure: Bool = false) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 15, design: .rounded))
                    .fontWeight(.semibold)
                    .frame(height: 20)
                    .foregroundColor(.neutral08)
                Spacer()
            }
            AppTextField(text: text, placeholder: placeholder, isSecure: isSecure)
        }
    }
}
