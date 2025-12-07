//
//  LoginView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image("img_login")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
            
            Text("For free, join now and \n start learning")
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .font(.system(size: 22, weight: .medium))
        }
    }
}

#Preview {
    LoginView()
}
