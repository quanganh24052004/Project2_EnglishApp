//
//  FeedbackSheetView.swift
//  DemoQuaTrinhHoc1Tu
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//
import SwiftUI

struct FeedbackSheetView: View {
    let result: CheckResult?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            if let result = result {
                switch result {
                case .correct:
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    Text("That's right!").font(.title).bold()
                    
                case .wrong(let correctAnswer):
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    Text("It's not right!").font(.title).bold()
                    Text("The correct answer is: \(correctAnswer)")
                        .foregroundColor(.secondary)
                }
            }
            
            Button("Continue") {
                dismiss() // Đóng sheet -> Trigger onDismiss ở Parent View
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Đổi màu nền sheet tùy kết quả
        .background(
            (result != nil && isCorrect(result!)) ? Color.green.opacity(0.1) : Color.red.opacity(0.1)
        )
    }
    
    func isCorrect(_ result: CheckResult) -> Bool {
        if case .correct = result { return true }
        return false
    }
}
