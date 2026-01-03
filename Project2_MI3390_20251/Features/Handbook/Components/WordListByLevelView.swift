//
//  WordListByLevelView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 03/01/26.
//

import SwiftUI
import SwiftData

struct WordListByLevelView: View {
    let level: Int
    let words: [StudyRecord]
    
    var body: some View {
        List {
            ForEach(words) { record in
                StudyRecordRow(record: record)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)) // Padding cho từng Row
            }
        }
        .navigationTitle("\(words.count) words")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subview: Row hiển thị chi tiết (Design Card + Ngày Giờ)
struct StudyRecordRow: View {
    let record: StudyRecord
    
    var word: Word? { record.word }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let word = word {
                // 1. Hàng trên: Tiếng Anh + Phiên âm + Ngày Giờ + Loa
                HStack(alignment: .center, spacing: 8) {
                    VStack (alignment: .leading, spacing: 8) {
                        // Tiếng Anh
                        Text(word.english)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .layoutPriority(1)
                        
                        // Phiên âm
                        Text(word.phonetic)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    
                    // --- Ngày & Giờ ---
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text("Review again!")
                                .font(.system(size: 10, design: .rounded))
                        }
                        .foregroundColor(.gray)
                        
                        // Hiển thị cả ngày và giờ (Vd: 14:30, 03/01/2026)
                        Text(record.nextReview.formatted(date: .numeric, time: .shortened))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(isOverdue ? .red : .green)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    // Nút Loa
                    Button(action: {
                        AudioManager.shared.playTTS(text: word.english)
                    }) {
                        Image(systemName: "speaker.wave.3.fill")
                    }
                    .buttonStyle(ThreeDCircleButtonStyle(
                        iconColor: .white,
                        backgroundColor: .orange,
                        size: 32,
                        depth: 2
                    ))
                }

                // 3. Nghĩa & Ví dụ
                VStack(alignment: .leading, spacing: 6) {
                    if let firstMeaning = word.meanings.first {
                        HStack {
                            Text(word.partOfSpeech)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                            
                            Text(firstMeaning.vietnamese)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                        
                        if !firstMeaning.exampleEn.isEmpty {
                            Text("\"\(firstMeaning.exampleEn)\"")
                                .font(.system(size: 14, design: .rounded))
                                .italic()
                                .foregroundStyle(.secondary)
                                .padding(.leading, 4)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 2)
                                        .padding(.vertical, 2),
                                    alignment: .leading
                                )
                        }
                    } else {
                        Text("It's not meaningful yet")
                            .font(.system(size: 14, design: .rounded))
                            .italic()
                            .foregroundColor(.gray)
                    }
                }
            } else {
                Text("Data from error!!!")
                    .foregroundColor(.red)
            }
        }
    }
    
    var isOverdue: Bool {
        record.nextReview < Date()
    }
}
