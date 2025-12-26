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
    
    // Query để đếm số lượng từ CẦN ôn (NextReview <= Hiện tại)
    // Lưu ý: Logic này chạy độc lập để xem còn bài tồn đọng không
    @Query var studyRecords: [StudyRecord]
    
    var dueRecordsCount: Int {
        let now = Date()
        return studyRecords.filter { $0.nextReview <= now }.count
    }
    
    // Callback hành động
    var onContinueReview: () -> Void // Reset session để ôn tiếp
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 1. Ảnh minh họa & Chúc mừng
            Image("img_happy") // Dùng ảnh có sẵn trong Assets của bạn
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding()
            
            Text("Tuyệt vời! 🎉")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.green)
            
            Text("Bạn đã hoàn thành phiên ôn tập này.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // 2. Các nút điều hướng
            VStack(spacing: 16) {
                
                // Nút A: Học từ mới -> Đóng ReviewView để lộ ra Tab Learning bên dưới
                Button(action: {
                    dismiss()
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
                
                // Nút B: Ôn tập ngay (Chỉ hiện nếu còn từ tồn đọng)
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
                
                // Nút phụ: Về trang chủ
                Button(action: {
                    dismiss()
                }) {
                    Text("Về trang chủ")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
    }
}
