//
//  SummarizeView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 25/12/25.
//

import SwiftUI
import SwiftData

struct SummarizeView: View {
    let items: [LearningItem]
    
    // Actions
    var onSave: (Set<PersistentIdentifier>) -> Void
    var onCancel: () -> Void
    
    @State private var selectedIDs: Set<PersistentIdentifier> = []

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Tổng kết từ vựng")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Chọn từ bạn muốn lưu vào sổ tay")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            // MARK: - LIST CHECKBOX
            List {
                ForEach(items) { item in
                    HStack(spacing: 15) {
                        Image(systemName: selectedIDs.contains(item.wordID) ? "checkmark.square.fill" : "square")
                            .font(.system(size: 24))
                            .foregroundColor(selectedIDs.contains(item.wordID) ? .blue : .gray)
                            .onTapGesture {
                                toggleSelection(for: item.wordID)
                            }
                        
                        Text(item.word)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(width: 120, alignment: .leading)
                        
                        Divider().frame(height: 20)
                        
                        Text(item.meaning)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle()) // Tăng vùng bấm cho cả dòng
                    .onTapGesture {
                        toggleSelection(for: item.wordID)
                    }
                }
            }
            .listStyle(.sidebar)
            
            VStack(spacing: 12) {
                Button(action: {
                    onSave(selectedIDs)
                }) {
                    Text("Lưu vào sổ tay (\(selectedIDs.count))")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                .disabled(selectedIDs.isEmpty)
                .opacity(selectedIDs.isEmpty ? 0.6 : 1)
                
                Button("Không lưu & Thoát", action: onCancel)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 5, y: -2)
        }
        .onAppear {
            let allIDs = items.map { $0.wordID }
            selectedIDs = Set(allIDs)
        }
    }
    
    private func toggleSelection(for id: PersistentIdentifier) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
}
