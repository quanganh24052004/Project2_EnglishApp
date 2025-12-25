//
//  FlipCardContainer.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import SwiftUI

struct FlipCardContainer<Front: View, Back: View>: View {
    var isFlipped: Bool
    var front: () -> Front
    var back: () -> Back
    
    // MARK: - Internal State (Quản lý góc quay riêng biệt)
    @State private var backDegree = 0.0
    @State private var frontDegree = -90.0
    
    private let durationAndDelay: CGFloat = 0.3
    
    init(isFlipped: Bool, @ViewBuilder front: @escaping () -> Front, @ViewBuilder back: @escaping () -> Back) {
        self.isFlipped = isFlipped
        self.front = front
        self.back = back
    }
    
    var body: some View {
        ZStack {
            front()
                .rotation3DEffect(.degrees(frontDegree), axis: (x: 0, y: 1, z: 0))
            
            back()
                .rotation3DEffect(.degrees(backDegree), axis: (x: 0, y: 1, z: 0))
        }
        .onChange(of: isFlipped) { newValue in
            flipCard(flipped: newValue)
        }
        .onAppear {
            if isFlipped {
                backDegree = 90
                frontDegree = 0
            } else {
                backDegree = 0
                frontDegree = -90
            }
        }
    }
    
    // MARK: - Animation Logic (Giống hệt README)
    private func flipCard(flipped: Bool) {
        if flipped {
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = 90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)){
                frontDegree = 0
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay)) {
                frontDegree = -90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)){
                backDegree = 0
            }
        }
    }
}
