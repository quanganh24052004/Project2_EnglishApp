//
//  IntroView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//

import SwiftUI

struct IntroView: View {
    // Nhận Binding từ RootView
    @Binding var isOnboardingDone: Bool
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Capy Vocab")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.orange)
                    .padding()
                
                Spacer()
                Image("wow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 256, height: 256)
                
                Text("Ghi nhớ 1000 từ vựng \n chỉ trong 1 tháng")
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // LUỒNG 1: Khách -> Survey -> MainTab
                NavigationLink(destination: SurveyView(isOnboardingDone: $isOnboardingDone)) {
                    Text("Bắt đầu ngay")
                }
                .buttonStyle(ThreeDButtonStyle())
                .padding(.horizontal, 100)
                
                // LUỒNG 2: User có acc -> Login -> MainTab
                NavigationLink(destination: LoginView()) {
                    Text("Đăng nhập")
                }
                .buttonStyle(ThreeDButtonStyle(color: .gray))
                .padding(.horizontal, 100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.neutral01)
        }
    }
}
