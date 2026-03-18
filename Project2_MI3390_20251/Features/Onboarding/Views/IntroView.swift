//
//  IntroView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//

import SwiftUI

struct IntroView: View {
    @Binding var isOnboardingDone: Bool
    @Environment(AuthViewModel.self) var authVM
    
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
                
                Text("Memorize 500 words \n in just 1 month")
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                NavigationLink(destination: SurveyView(isOnboardingDone: $isOnboardingDone)) {
                    Text("STARTING NOW")
                }
                .capyButton(.primary(color: CapyColors.green, shadow: CapyColors.greenShadow))
                .padding(.horizontal, 16)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primaryBG.edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    IntroView(isOnboardingDone: .constant(false))
}
