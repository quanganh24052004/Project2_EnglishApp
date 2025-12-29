//
//  RootView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI
import Combine

struct RootView: View {
    @State private var showSplash: Bool = true
    
    // Lưu trạng thái đã làm Survey hay chưa vào bộ nhớ máy
    @AppStorage("isOnboardingDone") var isOnboardingDone: Bool = false
    
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                // LOGIC CHÍNH Ở ĐÂY:
                // Vào màn hình chính nếu: Đã đăng nhập HOẶC Đã làm xong Survey
                if authViewModel.isAuthenticated || isOnboardingDone {
                    MainTabView()
                        .environmentObject(authViewModel) // Truyền xuống để dùng ở ProfileView sau này
                } else {
                    // Nếu chưa làm gì cả -> Hiện Intro
                    // Truyền $isOnboardingDone xuống để SurveyView có thể thay đổi nó
                    IntroView(isOnboardingDone: $isOnboardingDone)
                        .environmentObject(authViewModel)
                }
            }
        }
        .onAppear {
            authViewModel.checkSession()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSplash = false
                }
            }
            AudioManager.shared.playBackgroundMusic()
        }
    }
}
