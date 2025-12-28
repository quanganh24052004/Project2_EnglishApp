//
//  RegistrationView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""
    @State private var comfirmPassword = ""
    @State private var passwordMatch = false
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                
                Text("Create an account")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.top, 56)
                
                VStack (spacing: 12) {
                    VStack (spacing: 8) {
                        HStack {
                            Text("First Name")
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .frame(height: 20)
                                .foregroundColor(.neutral08)
                            Spacer()
                        }
                        AppTextField(text: $firstname, placeholder: "Enter your first name", isSecure: false)
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
                        AppTextField(text: $lastname, placeholder: "Enter your last name", isSecure: false)
                    }
                    
                    VStack (spacing: 8) {
                        HStack {
                            Text("Phone")
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .frame(height: 20)
                                .foregroundColor(.neutral08)
                            Spacer()
                        }
                        AppTextField(text: $phone, placeholder: "Enter your number phone", isSecure: false)
                    }
                    
                    VStack (spacing: 8) {
                        HStack {
                            Text("Email")
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
                    
                    VStack (spacing: 8) {
                        HStack {
                            Text("Comfirm Password")
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .frame(height: 20)
                                .foregroundColor(.neutral08)
                            Spacer()
                        }
                        AppTextField(text: $comfirmPassword, placeholder: "Enter your comfirm password", isSecure: true)
                    }
                    .onChange(of: comfirmPassword) { oldValue, newValue in
                        passwordMatch = newValue == password
                    }
                }
                .padding(.vertical, 12)
                
                Button("Login") {
                    print("Login")
                }
                .buttonStyle(ThreeDButtonStyle(color: .pGreen))
                
                VStack (spacing: 16) {
                    HStack (spacing: 15) {
                        Rectangle()
                            .frame(height: 0.8)
                            .foregroundColor(.neutral04)
                        Text("Or")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .fontWeight(.regular)
                            .frame(height: 20)
                            .foregroundColor(.neutral04)
                        Rectangle()
                            .frame(height: 0.8)
                            .foregroundColor(.neutral04)
                    }
                }
                .padding(.vertical, 16)
                HStack (spacing: 15) {
                    Button {
                        print("Login with Social")
                    } label: {
                        HStack(spacing: 12) {
                            Image("img_google")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .buttonStyle(ThreeDButtonStyle(color: .black, height: 50))
                    
                    Button {
                        print("Login with Social")
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "applelogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .buttonStyle(ThreeDButtonStyle(color: .black, height: 50))
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    HStack (spacing: 3) {
                        Text("Already have an account?")
                            .font(.system(size: 15))
                            .frame(height: 20)
                            .foregroundColor(Color.neutral08)
                        Text("Sign in")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .frame(height: 20)
                            .foregroundColor(Color.primary02)
                    }
                }
                .padding(.top, 16)
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.neutral01)
        .ignoresSafeArea()
    }
}

#Preview {
    RegistrationView()
}
