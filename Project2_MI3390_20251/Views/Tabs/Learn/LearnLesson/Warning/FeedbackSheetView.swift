//
//  FeedbackSheetView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//  Updated for Review Feature
//

import SwiftUI

struct FeedbackSheetView: View {
    // MARK: - Properties (Internal State)
    // Chúng ta chuyển đổi mọi input về dạng nguyên thủy để View dễ vẽ
    private let isCorrect: Bool
    private let correctAnswer: String
    private let onNext: (() -> Void)? // Action tùy chọn (Review cần, Learning có thể không)

    @Environment(\.dismiss) var dismiss
    
    // MARK: - Init 1: Dùng cho Review (Màn hình Ôn tập mới)
    // Cách gọi: FeedbackSheetView(isCorrect: ..., correctAnswer: ..., onNext: ...)
    init(isCorrect: Bool, correctAnswer: String, onNext: @escaping () -> Void) {
        self.isCorrect = isCorrect
        self.correctAnswer = correctAnswer
        self.onNext = onNext
    }
    
    // MARK: - Init 2: Dùng cho Learning (Màn hình Học cũ)
    // Cách gọi: FeedbackSheetView(result: result) -> Giữ tương thích với code cũ của bạn
    init(result: CheckResult, onNext: (() -> Void)? = nil) {
        switch result {
        case .correct:
            self.isCorrect = true
            self.correctAnswer = ""
        case .wrong(let answer):
            self.isCorrect = false
            self.correctAnswer = answer
        }
        self.onNext = onNext
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // 1. Icon & Trạng thái
            if isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .transition(.scale)
                
                Text("Chính xác! 🎉") // Hoặc "That's right!" nếu muốn giữ tiếng Anh
                    .font(.title)
                    .bold()
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .transition(.scale)
                
                Text("Chưa chính xác!") // Hoặc "It's not right!"
                    .font(.title)
                    .bold()
                    .foregroundColor(.red)
                
                VStack(spacing: 8) {
                    Text("Đáp án đúng là:") // Hoặc "The correct answer is:"
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(correctAnswer)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer().frame(height: 20)
            
            // 2. Button Action
            Button(action: {
                // Nếu có hành động onNext (Review), thực hiện trước rồi mới dismiss
                if let onNext = onNext {
                    onNext()
                }
                dismiss()
            }) {
                Text("Tiếp tục")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(ThreeDButtonStyle(color: isCorrect ? .green : .red)) // Đổi màu nút theo trạng thái
            .padding(.horizontal, 40)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(
            (isCorrect ? Color.green : Color.red).opacity(0.1)
                .ignoresSafeArea()
        )
    }
}
