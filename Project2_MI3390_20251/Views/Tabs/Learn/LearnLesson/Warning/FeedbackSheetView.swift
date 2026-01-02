//
//  FeedbackSheetView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//  Updated by AI Assistant on 31/12/25
//

import SwiftUI
import AVFoundation

struct FeedbackSheetView: View {
    // MARK: - Properties
    let isCorrect: Bool
    let item: LearningItem
    let onNext: (() -> Void)?
    
    @State private var showTranslation: Bool = false
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Init
    // Bạn cần sửa lại cách gọi ở LessonContainerView để truyền `item` vào đây
    init(result: CheckResult, item: LearningItem, onNext: (() -> Void)? = nil) {
        switch result {
        case .correct:
            self.isCorrect = true
        case .wrong:
            self.isCorrect = false
        }
        self.item = item
        self.onNext = onNext
    }
    
    // Init hỗ trợ xem trước hoặc logic khác
    init(isCorrect: Bool, item: LearningItem, onNext: @escaping () -> Void) {
        self.isCorrect = isCorrect
        self.item = item
        self.onNext = onNext
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // 1. Background tint (Xanh hoặc Đỏ nhạt)
            (isCorrect ? Color.green : Color.red).opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // MARK: - 1. Header: Trạng thái Đúng/Sai
                statusHeader
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // MARK: - 2. Nội dung chi tiết từ vựng
                wordDetailContent
                
                Spacer()
                
                // MARK: - 3. Nút Tiếp tục
                continueButton
            }
            .padding(24)
        }
    }
    
    // MARK: - Subviews
    
    private var statusHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.white)
            
            Text(isCorrect ? "Chính xác! 🎉" : "Chưa chính xác")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    private var wordDetailContent: some View {
        HStack(alignment: .top, spacing: 16) {
            Button{
                AudioManager.shared.playTTS(text: item.word)
            } label: {
                Image(systemName: "speaker.wave.3.fill")
            }
            .buttonStyle(ThreeDCircleButtonStyle(
                iconColor: .orange,
                backgroundColor: .white,
                size: 36
            ))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.word)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("(\(item.partOfSpeech))")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .italic()
                }
                
                Text(item.phonetic)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                
                Text(item.meaning)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 4)
                
                if !item.example.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text("Ex: \(item.example)")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white)
                                .italic()
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                            
                            Button{
                                withAnimation {
                                    showTranslation.toggle()
                                }
                            } label: {
                                Image(systemName: "translate")
                            }
                            .buttonStyle(ThreeDCircleButtonStyle(
                                iconColor: .orange,
                                backgroundColor: .white,
                                size: 32
                            ))
                        }
                        
                        // Hàng 5: Dịch ví dụ (Hiện khi ấn nút)
                        if showTranslation {
                            Text(item.exampleVi)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            if let onNext = onNext {
                onNext()
            }
            dismiss()
        }) {
            Text("Tiếp tục")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(ThreeDButtonStyle(color: .white))
        .padding(.horizontal, 100)
    }
}   
