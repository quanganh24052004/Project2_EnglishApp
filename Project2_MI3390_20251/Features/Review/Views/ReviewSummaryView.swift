//
//  ReviewSummaryView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//  Refactored for Clean Architecture & Design System.
//

import SwiftUI
import SwiftData

struct ReviewSummaryView: View {
    
    // MARK: - Environment & Properties
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    // Query lấy dữ liệu học tập
    @Query var studyRecords: [StudyRecord]
    
    /// Tính toán số lượng từ cần ôn tập tiếp
    var dueRecordsCount: Int {
        let now = Date()
        return studyRecords.filter { $0.nextReview <= now }.count
    }
    
    /// Closure callback khi người dùng muốn ôn tiếp
    var onContinueReview: () -> Void
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                illustrationSection
                
                headerSection
                    .padding(.top, 24)
                
                Spacer()
                
                actionButtons
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Subviews

extension ReviewSummaryView {
    
    /// Phần ảnh minh họa
    private var illustrationSection: some View {
        Image("img_happy") // Đảm bảo ảnh này có trong Assets
            .resizable()
            .scaledToFit()
            .frame(height: 220)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    /// Phần tiêu đề và nội dung text
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Great! 🎉")
                .font(.system(size: 28, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("You have completed this review session.\nKeep up the form!")
                .font(.system(size: 18, design: .rounded)) // Nội dung size 18
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    /// Khu vực các nút hành động
    private var actionButtons: some View {
        VStack(spacing: 16) {
            
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "book.fill")
                    Text("Learn new words")
                }
            }
            .buttonStyle(ThreeDButtonStyle(color: .pGreen))
            
            if dueRecordsCount > 0 {
                Button {
                    onContinueReview()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                        Text("Continue to review")
                        
                        Text("(\(dueRecordsCount))")
                            .font(.system(size: 14, design: .rounded))
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .buttonStyle(ThreeDButtonStyle(color: .orange))
            }
            
            Button {
                dismiss()
            } label: {
                Text("Back to homepage")
                    .font(.system(size: 16, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.neutral04)
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Preview
#Preview {
    ReviewSummaryView(onContinueReview: {})
}
