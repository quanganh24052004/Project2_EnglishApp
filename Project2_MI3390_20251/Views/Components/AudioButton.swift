//
//  AudioButton.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 21/12/25.
//

import SwiftUI
// MARK: - Subview: Nút Audio
struct AudioButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "speaker.wave.3.fill")
        }
        .buttonStyle(ThreeDCircleButtonStyle(
            iconColor: .white,
            backgroundColor: .blue,
            size: 64
        ))
    }
}

struct SlowAudioButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "tortoise.fill")
        }
        .buttonStyle(ThreeDCircleButtonStyle(
            iconColor: .white,
            backgroundColor: .orange,
        ))
    }
}
