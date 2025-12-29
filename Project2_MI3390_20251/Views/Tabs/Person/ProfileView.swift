//
//  ProfileView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    // 1. Gọi AuthViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            List {
                // TRƯỜNG HỢP 1: ĐÃ ĐĂNG NHẬP
                if let user = authVM.currentUser {
                    
                    // Header (Avatar + Tên)
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                Circle()
                                    .fill(Color.orange.gradient)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text(user.initials)
                                            .font(.title).bold().foregroundColor(.white)
                                    )
                                    .shadow(radius: 5)
                                
                                Text(user.fullName)
                                    .font(.title2).fontWeight(.bold)
                                
                                Text(user.email ?? "No Email")
                                    .font(.subheadline).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                    .listRowBackground(Color.clear)
                    
                    // Thông tin chi tiết
                    Section("Thông tin cá nhân") {
                        ProfileRow(icon: "person.fill", title: "Họ", value: user.firstName)
                        ProfileRow(icon: "person.fill", title: "Tên", value: user.lastName)
                        ProfileRow(icon: "phone.fill", title: "Số điện thoại", value: user.phoneNumber)
                        ProfileRow(icon: "envelope.fill", title: "Email", value: user.email ?? "")
                    }
                    
                    // Đăng xuất
                    Section {
                        Button(role: .destructive) {
                            authVM.signOut()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Đăng xuất")
                            }
                        }
                    }
                }
                // TRƯỜNG HỢP 2: CHƯA ĐĂNG NHẬP (GUEST) HOẶC ĐANG TẢI
                else {
                    Section {
                        VStack(spacing: 16) {
                            if authVM.isLoading {
                                ProgressView("Đang tải thông tin...")
                            } else {
                                // Giao diện cho Guest
                                Image(systemName: "person.crop.circle.badge.questionmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                
                                Text("Bạn chưa đăng nhập")
                                    .font(.headline)
                                
                                Text("Vui lòng đăng nhập để xem thông tin cá nhân và lưu tiến độ học tập.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Hồ sơ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Chỉ hiện nút Đăng nhập nếu chưa có user
                    if authVM.currentUser == nil && !authVM.isLoading {
                        NavigationLink(
                            destination: LoginView()
                                .toolbar(.hidden, for: .tabBar)
                        ) {
                            Text("Đăng nhập")
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .refreshable {
                await authVM.fetchCurrentUser()
            }
        }
        .onAppear {
            if authVM.currentUser == nil {
                Task { await authVM.fetchCurrentUser() }
            }
        }
    }
}

// Subview hiển thị từng dòng thông tin
struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            Text(title).foregroundColor(.primary)
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
