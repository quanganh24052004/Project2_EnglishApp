//
//  ReviewSummaryView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//

import SwiftUI
import SwiftData

struct ReviewSummaryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    // Kiểm tra xem còn từ nào cần ôn nữa không (ngoài phiên vừa xong)
    @Query var studyRecords: [StudyRecord]
    
    var dueRecordsCount: Int {
        let now = Date()
        return studyRecords.filter { $0.nextReview <= now }.count
    }
    
    // Callback để điều hướng về các tab chính
    var onGoToLearn: () -> Void
    var onContinueReview: () -> Void
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 1. Ảnh minh họa & Chúc mừng
            Image("img_happy") // Đảm bảo bạn có ảnh này hoặc thay bằng systemImage
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            
            Text("Tuyệt vời! 🎉")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.green)
            
            Text("Bạn đã hoàn thành phiên ôn tập này.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // 2. Các nút hành động
            VStack(spacing: 16) {
                
                // Nút A: Học từ mới (Luôn hiện) -> Trỏ về Tab Learning
                Button(action: {
                    onGoToLearn()
                }) {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Học từ mới")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
                }
                
                // Nút B: Ôn tập ngay (Chỉ hiện nếu còn từ cần ôn)
                if dueRecordsCount > 0 {
                    Button(action: {
                        onContinueReview()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("Ôn tập tiếp (\(dueRecordsCount))")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                
                // Nút C: Về trang chủ (Đóng review)
                Button(action: {
                    onDismiss()
                }) {
                    Text("Về trang chủ")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}