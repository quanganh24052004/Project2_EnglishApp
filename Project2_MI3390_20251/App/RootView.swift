//
//  RootView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//


import SwiftUI

struct RootView: View {
    @State private var showSplash: Bool = true
    
    @AppStorage("isOnboardingDone") var isOnboardingDone: Bool = false
    
    var body: some View {
        ZStack {
            if showSplash {
                // Luôn hiển thị cái này đầu tiên
                SplashScreenView()
                    .transition(.opacity) // Hiệu ứng mờ dần khi tắt
                    .zIndex(1) // Đảm bảo luôn nằm trên cùng
            } else {
                // Sau khi Splash tắt, mới check logic nghiệp vụ
                if isOnboardingDone {
                    // Màn hình chính sau khi đã hoàn thành khảo sát
                    // (Bạn có thể thay bằng MainTabView hoặc HomeView của bạn)
                    MainTabView()
                } else {
                    // Màn hình khảo sát (Code bạn đã gửi)
                    SurveyView(isOnboardingDone: $isOnboardingDone)
                }
            }
        }
        .onAppear {
            // Giả lập thời gian loading (ví dụ 2.5 giây)
            // Trong thực tế, bạn có thể gọi API tải config ở đây
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}
