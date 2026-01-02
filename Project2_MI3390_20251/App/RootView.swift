//
//  RootView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//  Refactored for Clean Code & Rounded Design.
//

import SwiftUI
import Combine
import SwiftData
import Supabase // Import để định nghĩa kiểu dữ liệu Auth.User trong helper

/// View gốc điều hướng luồng chính của ứng dụng.
/// Chịu trách nhiệm hiển thị Splash Screen và điều hướng giữa Main App hoặc Onboarding.
struct RootView: View {
    
    // MARK: - Properties
    
    /// Trạng thái hiển thị màn hình chờ (Splash Screen).
    @State private var showSplash: Bool = true
    
    /// Context dữ liệu SwiftData để đồng bộ user.
    @Environment(\.modelContext) private var modelContext
    
    /// Lưu trạng thái Onboarding trong UserDefaults.
    @AppStorage("isOnboardingDone") var isOnboardingDone: Bool = false
    
    /// ViewModel quản lý trạng thái xác thực (Auth).
    @StateObject private var authViewModel = AuthViewModel()
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if showSplash {
                // 1. Màn hình khởi động (Splash)
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1) // Luôn nằm trên cùng khi fade out
            } else {
                // 2. Điều hướng luồng chính
                contentFlow
            }
        }
        .fontDesign(.rounded)
        
        // MARK: - Side Effects & Events
        
        // Lắng nghe thay đổi User để đồng bộ dữ liệu về máy
        .onChange(of: authViewModel.currentUser) { _, newUser in
            handleUserSync(newUser)
        }
        // Logic khởi chạy ban đầu
        .onAppear {
            setupAppStartup()
        }
    }
}

// MARK: - Subviews & Helpers

extension RootView {
    
    /// View điều hướng nội dung chính (Main App hoặc Intro).
    @ViewBuilder
    private var contentFlow: some View {
        if authViewModel.isAuthenticated || isOnboardingDone {
            // Người dùng đã đăng nhập hoặc đã qua Onboarding -> Vào App chính
            MainTabView()
                .environmentObject(authViewModel)
        } else {
            // Người dùng mới -> Vào màn hình giới thiệu
            IntroView(isOnboardingDone: $isOnboardingDone)
                .environmentObject(authViewModel)
        }
    }
    
    /// Xử lý đồng bộ User khi có thay đổi.
    private func handleUserSync(_ user: Auth.User?) {
        guard let user = user else { return }
        
        Task {
            await MainActor.run {
                UserSyncManager.shared.syncUser(from: user, in: modelContext)
            }
        }
    }
    
    /// Thiết lập logic khởi động App.
    private func setupAppStartup() {
        // Kiểm tra phiên đăng nhập cũ
        authViewModel.checkSession()
        
        // Giả lập thời gian tải & tắt Splash sau 2.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showSplash = false
            }
        }
        
        // Phát nhạc nền
        AudioManager.shared.playBackgroundMusic()
    }
}
