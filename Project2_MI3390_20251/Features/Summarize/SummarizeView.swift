//
//  SummarizeView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 25/12/25.
//

import SwiftUI
import SwiftData

struct SummarizeView: View {
    // MARK: - Properties
    let items: [LearningItem]
    
    // Actions
    var onSave: (Set<PersistentIdentifier>) -> Void
    var onCancel: () -> Void
    
    @State private var selectedIDs: Set<PersistentIdentifier> = []

    // MARK: - Body
    var body: some View {
        ZStack {
            // 1. Background toàn màn hình
            Color.neutral01
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header Section
                VStack(spacing: 12) {
                    // Hình ảnh minh họa (Dùng ảnh có sẵn trong Assets)
                    Image("wow")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                    
                    Text("Tuyệt vời! 🎉")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Bạn đã hoàn thành bài học.\nChọn từ vựng bạn muốn lưu vào sổ tay:")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // MARK: - Scrollable Content (Card Style)
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(items) { item in
                            wordSelectionCard(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                Spacer()
                // MARK: - Footer Actions
                VStack(spacing: 32) {
                    Button(action: {
                        onSave(selectedIDs)
                    }) {
                        Text("Lưu vào sổ tay (\(selectedIDs.count))")
                    }
                    .buttonStyle(ThreeDButtonStyle(
                        color: selectedIDs.isEmpty ? .gray : .pGreen
                    ))
                    .padding(.horizontal, 24)
                    .disabled(selectedIDs.isEmpty)
                    
                    Button(action: onCancel) {
                        Text("Không lưu & Thoát")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                            .underline()
                    }
                }
            }
        }
        .onAppear {
            // Mặc định chọn tất cả khi vào màn hình
            let allIDs = items.map { $0.wordID }
            selectedIDs = Set(allIDs)
        }
    }
    
    // MARK: - Helper Views
    
    // Component Card cho từng từ
    private func wordSelectionCard(item: LearningItem) -> some View {
        let isSelected = selectedIDs.contains(item.wordID)
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                toggleSelection(for: item.wordID)
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.pGreen : Color.neutral04, lineWidth: 2)
                        .background(Circle().fill(isSelected ? Color.pGreen : Color.white))
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Nội dung từ
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.word)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .primary : .gray)
                    
                    Text(item.meaning)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            // Hiệu ứng viền khi chọn
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.pGreen : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain) // Bỏ hiệu ứng mờ mặc định của Button
    }
    
    private func toggleSelection(for id: PersistentIdentifier) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
}

