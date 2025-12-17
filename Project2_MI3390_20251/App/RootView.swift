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
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                if isOnboardingDone {
                    MainTabView()
                } else {
                    SurveyView(isOnboardingDone: $isOnboardingDone)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    RootView()
}
