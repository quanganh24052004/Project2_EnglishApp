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
            VStack(spacing: 8) {
                Spacer()
                Image("img_login")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                
                Text("Miễn phí, tham gia ngay bây giờ\nvà bắt đầu học ngay hôm nay!")
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 22, weight: .medium))
                Spacer()
            }
        }

    }
}

//#Preview {
//    LoginView()
//}
