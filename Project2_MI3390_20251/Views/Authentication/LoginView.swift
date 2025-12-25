//
//  LoginView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                Image("img_login")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                
                Text("Free, join now\n and start learning today!")
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 22, weight: .bold))
                    .frame(height: 56)
                VStack (spacing: 24) {
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
                                .fontWeight(.regular)
                                .frame(height: 20)
                                .foregroundColor(.neutral08)
                            Spacer()
                        }
                        AppTextField(text: $password, placeholder: "Enter your password", isSecure: true)
                    }
                    HStack {
                        Button {
                            print("Forget Password")
                        } label: {
                            Text("Forget Password?")
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .fontWeight(.regular)
                                .frame(height: 20)
                                .foregroundColor(.primary02)
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 32)
                
                Button("Login") {
                    print("Login")
                }
                .buttonStyle(ThreeDButtonStyle(color: .pGreen))
                .padding(.bottom, 24)
                
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
            }
            .padding(.horizontal, 24)
        }

    }
}

#Preview {
    LoginView()
}
