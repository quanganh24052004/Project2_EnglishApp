//
//  ExitConfirmationSheet.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 25/12/25.
//


import SwiftUI

struct ExitConfirmationSheet: View {
    var onContinue: () -> Void // Hành động ở lại
    var onExit: () -> Void     // Hành động thoát
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon cảnh báo
            Image(.imgWarning)
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .padding(.top, 20)
            
            Text("Làm nốt bài đi. Thoát bây giờ là toàn bộ kết quả học sẽ không được lưu lại đó!")
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundColor(Color.black)
                .fixedSize(horizontal: false, vertical: true) // Giúp text tự giãn chiều cao đủ để hiển thị hết
                .padding(.horizontal)
            
            HStack(spacing: 24) {
                // Button 1: Ở lại (Nổi bật)
                Button(action: onContinue) {
                    Text("Ở lại học tiếp")
                }
                .buttonStyle(ThreeDButtonStyle(color: .pGreen))
                // Button 2: Thoát (Màu đỏ/Xám)
                Button(action: onExit) {
                    Text("Thoát")
                }
                .buttonStyle(ThreeDButtonStyle(color: .red))
            }
            .padding(.horizontal, 16)
        }
        .padding()
    }
}

#Preview {
    ExitConfirmationSheet(
        onContinue: { /* preview continue */ },
        onExit: { /* preview exit */ }
    )
}
