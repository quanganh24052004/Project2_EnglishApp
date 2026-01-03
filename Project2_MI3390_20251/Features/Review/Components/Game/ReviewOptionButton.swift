//
//  ReviewOptionButton.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//

import SwiftUI

// Component hiển thị 1 lựa chọn trắc nghiệm
struct ReviewOptionButton: View {
    let text: String
    let isSelected: Bool
    let isAudioMode: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isAudioMode {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                } else {
                    Text(text)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
            }
        }
        .buttonStyle(SelectionThreeDButtonStyle(isSelected: isSelected))
        .onAppear {
            if isAudioMode && isSelected {
                AudioManager.shared.playTTS(text: text)
            }
        }
    }
}
