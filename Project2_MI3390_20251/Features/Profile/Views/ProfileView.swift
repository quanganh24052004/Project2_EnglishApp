//
//  ProfileView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//  Refactored for Clean Code & Rounded Design.
//

import SwiftUI
import Supabase

/// Màn hình Hồ sơ người dùng (Profile).
/// Hiển thị thông tin cá nhân, trạng thái đăng nhập và các tùy chọn tài khoản.
struct ProfileView: View {
    
    // MARK: - Properties
    
    /// ViewModel quản lý trạng thái xác thực (Auth).
    @EnvironmentObject var authVM: AuthViewModel
    
    /// ViewModel quản lý ngôn ngữ
    @EnvironmentObject var languageManager: LanguageManager

    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                if let user = authVM.currentUser {
                    // 1. Trạng thái Đã đăng nhập
                    loggedInContent(user: user)
                } else {
                    // 2. Trạng thái Chưa đăng nhập (Guest)
                    guestContent
                }
            }
            .listStyle(.insetGrouped) // Style danh sách hiện đại hơn
            .navigationTitle(languageManager.currentLanguage == "vi" ? "Hồ sơ" : "Profile")
            .toolbar {
                toolbarContent
            }
            // Kéo xuống để làm mới dữ liệu
            .refreshable {
                await authVM.fetchCurrentUser()
            }
        }
        // Tự động tải dữ liệu khi vào màn hình nếu chưa có
        .onAppear {
            if authVM.currentUser == nil {
                Task { await authVM.fetchCurrentUser() }
            }
        }
    }
}

// MARK: - Subviews (Components)

extension ProfileView {
    
    /// Nội dung hiển thị khi người dùng ĐÃ đăng nhập.
    @ViewBuilder
    private func loggedInContent(user: Auth.User) -> some View {
        // Section 1: Header (Avatar + Tên)
        Section {
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    // Avatar tròn với Initials
                    Circle()
                        .fill(Color.orange.gradient)
                        .frame(width: 86, height: 86)
                        .overlay(
                            Text(user.initials)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                    
                    // Tên hiển thị
                    Text(user.fullName)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                    
                    // Email
                    Text(user.email ?? "No Email")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 10)
                Spacer()
            }
        }
        .listRowBackground(Color.clear) // Xóa nền row để Avatar nổi bật trên nền List
        
        // Section 2: Thông tin chi tiết
        Section("My profile") {
            ProfileRow(icon: "phone.fill", title: "Phone", value: user.phoneNumber)
            
            // Định dạng ngày tham gia (Optional: có thể move logic date formatter ra ngoài)
            let joinedDate = user.createdAt.formatted(date: .abbreviated, time: .omitted)
            ProfileRow(icon: "calendar", title: "Join from", value: joinedDate)
        }
        
        // Section 3: Đăng xuất
        Section {
            Button(role: .destructive) {
                authVM.signOut()
            } label: {
                HStack {
                    Spacer()
                    Text("Log out")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    /// Nội dung hiển thị khi người dùng CHƯA đăng nhập (Khách).
    private var guestContent: some View {
        Section {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray.opacity(0.5))
                
                Text("You are not logged in yet")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                NavigationLink {
                    LoginView()
                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    Text("Login now")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain) // Bỏ style mặc định của List button
                
                Spacer()
            }
            .padding(.vertical, 40)
        }
        .listRowBackground(Color.clear)
    }
    
    /// Nội dung trên thanh Toolbar.
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            // Chỉ hiện nút Đăng nhập nhỏ ở góc nếu đang ở chế độ khách
            if authVM.currentUser == nil && !authVM.isLoading {
                NavigationLink(
                    destination: LoginView().toolbar(.hidden, for: .tabBar)
                ) {
                    Text("Login")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Helper Views

/// Row hiển thị thông tin cá nhân (Icon - Title - Value).
struct ProfileRow: View {
    
    // MARK: - Properties
    let icon: String
    let title: String
    let value: String
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            // Icon container
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
            }
            
            // Title
            Text(title)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Value
            Text(value)
                .font(.system(.callout, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
