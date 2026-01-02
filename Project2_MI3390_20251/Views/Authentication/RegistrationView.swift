//
//  RegistrationView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//  Refactored UI & Comments.
//

import SwiftUI
import AuthenticationServices

/// Màn hình Đăng ký tài khoản mới.
struct RegistrationView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    /// ViewModel quản lý logic riêng cho màn hình Đăng ký.
    @StateObject private var viewModel = RegistrationViewModel()
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Lớp nền
            Color.primary01.ignoresSafeArea()
            
            // Lớp nội dung
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 20)
                        
                        Text("Create an account")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.bottom, 24)
                        
                        formFields
                        
                        signUpButton
                            .padding(.top, 24)
                        
                        footerLink
                            .padding(.top, 16)
                        
                        dividerView
                        
                        socialButtons
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .alert("Thông báo", isPresented: $viewModel.showingError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Subviews & Components

extension RegistrationView {
    
    /// Các trường nhập liệu thông tin cá nhân.
    private var formFields: some View {
        VStack(spacing: 12) {
            inputField(title: "First name", text: $viewModel.firstname, placeholder: "First name")
            inputField(title: "Last name", text: $viewModel.lastname, placeholder: "Last name")
            inputField(title: "Phone number", text: $viewModel.phone, placeholder: "Phone number")
            inputField(title: "Email address", text: $viewModel.email, placeholder: "Email address")
            inputField(title: "Password", text: $viewModel.password, placeholder: "Password", isSecure: true)
            
            inputField(title: "Confirm password", text: $viewModel.confirmPassword, placeholder: "Confirm password", isSecure: true)
                .onChange(of: viewModel.confirmPassword) { _,_ in viewModel.checkPasswordMatch() }
                .onChange(of: viewModel.password) { _,_ in viewModel.checkPasswordMatch() }
        }
    }
    
    /// Nút Đăng ký (Disable nếu mật khẩu chưa khớp hoặc đang loading).
    private var signUpButton: some View {
        Button(viewModel.isLoading ? "Loading..." : "Sign Up") {
            viewModel.register(authVM: authVM) {
                dismiss()
            }
        }
        .buttonStyle(ThreeDButtonStyle(color: viewModel.passwordMatch ? .pGreen : .gray))
        .disabled(!viewModel.passwordMatch || viewModel.isLoading)
    }
    
    /// Link quay lại màn hình đăng nhập.
    private var footerLink: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 3) {
                Text("Already have an account?")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.neutral08)
                Text("Sign in")
                    .font(.system(size: 10, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary02)
            }
            .padding(8)
        }
    }
    
    private var dividerView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 15) {
                Rectangle()
                    .frame(height: 0.8)
                    .foregroundColor(.neutral04)
                Text("Or")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.neutral04)
                Rectangle()
                    .frame(height: 0.8)
                    .foregroundColor(.neutral04)
            }
        }
        .padding(.vertical, 12)
    }
    
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
