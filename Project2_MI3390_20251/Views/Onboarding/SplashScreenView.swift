//
//  SplashScreenView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//


import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false // State để làm hiệu ứng fade-in

    var body: some View {
        ZStack {
            Color.orange.ignoresSafeArea() // Màu nền chủ đạo (theo style Survey của bạn)
            
            VStack(spacing: 20) {
                // Logo App (Thay bằng Image Asset của bạn nếu có)
                Image(systemName: "book.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                
                Text("English Master")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8) // Hiệu ứng scale nhẹ
            .opacity(isAnimating ? 1.0 : 0.0)     // Hiệu ứng hiện dần
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}