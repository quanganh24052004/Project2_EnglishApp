//
//  RegistrationView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI
import AuthenticationServices

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var firstname = ""
    @State private var lastname = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""
    @State private var comfirmPassword = ""
    @State private var passwordMatch = false
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    func register() {
        guard passwordMatch else {
            errorMessage = "Mật khẩu không khớp"
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let _ = try await SupabaseAuthService.shared.signUp(
                    email: email,
                    password: password,
                    firstName: firstname,
                    lastName: lastname,
                    phone: phone
                )
                
                await authVM.fetchCurrentUser()
                
                await MainActor.run {
                    isLoading = false
                    print("Registration Success")
                    
                    authVM.isAuthenticated = true
                    dismiss()

                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 56)
                Text("Create an account").font(.system(size: 22, weight: .bold))
                
                VStack(spacing: 12) {
                    Group {
                        VStack (spacing: 8) {
                            HStack {
                                Text("First name")
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .frame(height: 20)
                                    .foregroundColor(.neutral08)
                                Spacer()
                            }
                            AppTextField(text: $firstname, placeholder: "First name", isSecure: false)
                        }
                        
                        VStack (spacing: 8) {
                            HStack {
                                Text("Last name")
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .frame(height: 20)
                                    .foregroundColor(.neutral08)
                                Spacer()
                            }
                            AppTextField(text: $lastname, placeholder: "Last name", isSecure: false)
                        }
                        
                        VStack (spacing: 8) {
                            HStack {
                                Text("Phone number")
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .frame(height: 20)
                                    .foregroundColor(.neutral08)
                                Spacer()
                            }
                            AppTextField(text: $phone, placeholder: "Phone number", isSecure: false)
                        }
                        
                        VStack (spacing: 8) {
                            HStack {
                                Text("Email address")
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .frame(height: 20)
                                    .foregroundColor(.neutral08)
                                Spacer()
                            }
                            AppTextField(text: $email, placeholder: "Email address", isSecure: false)
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
                            AppTextField(text: $password, placeholder: "Password", isSecure: true)
                        }

                        VStack(spacing: 8) {
                            HStack {
                                Text("Confirm password")
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .frame(height: 20)
                                    .foregroundColor(.neutral08)
                                Spacer()
                            }
                            AppTextField(text: $comfirmPassword, placeholder: "Confirm password", isSecure: true)
                        }
                        .onChange(of: comfirmPassword) { oldValue, newValue in
                            passwordMatch = newValue == password
                        }
                    }
                }
                .padding(.vertical, 12)
                
                Button(isLoading ? "Loading..." : "Sign Up") {
                    register()
                }
                .buttonStyle(ThreeDButtonStyle(color: passwordMatch ? .pGreen : .gray))
                .disabled(!passwordMatch || isLoading)
                .alert("Error", isPresented: $showingError) { Button("OK") {} } message: { Text(errorMessage ?? "") }
                
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 3) {
                        Text("Already have an account?").foregroundColor(.neutral08)
                        Text("Sign in").fontWeight(.semibold).foregroundColor(.primary02)
                    }
                }
                .padding(.top, 16)
                VStack(spacing: 16) {
                    HStack(spacing: 15) {
                        Rectangle().frame(height: 0.8).foregroundColor(.neutral04)
                        Text("Or").font(.system(size: 15)).foregroundColor(.neutral04)
                        Rectangle().frame(height: 0.8).foregroundColor(.neutral04)
                    }
                }
                .padding(.vertical, 12)
                
                // Social Buttons
                HStack(spacing: 15) {
                    Button { print("Google Login") } label: {
                        HStack { Image("img_google").resizable().frame(width: 24, height: 24) }
                    }
                    .buttonStyle(ThreeDButtonStyle(color: .black, height: 50))
                    
                    // Apple Button Overlay Wrapper
                    Button { } label: {
                        HStack { Image(systemName: "applelogo").resizable().scaledToFit().frame(width: 24, height: 24).foregroundColor(.white) }
                    }
                    .buttonStyle(ThreeDButtonStyle(color: .black, height: 50))
                }
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .background(Color.primary01)
        .ignoresSafeArea()
    }
}
