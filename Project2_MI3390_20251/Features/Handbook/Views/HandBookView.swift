//
//  HandBookView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 3/1/26.
//

import SwiftUI
import SwiftData

struct HandBookView: View {
    @Query private var studyRecords: [StudyRecord]
    
    let levels: [Int] = Array(0...5)
    
    var totalWordsCount: Int {
        studyRecords.count
    }
    
    var body: some View {
        NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(levels, id: \.self) { level in
                            let wordsInLevel = studyRecords.filter { $0.memoryLevel == level }
                            
                            NavigationLink(destination: WordListByLevelView(level: level, words: wordsInLevel)) {
                                LevelCardView(level: level, count: wordsInLevel.count)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("\(totalWordsCount) words for review")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground))
            }
        }
    }

    // MARK: - Subview: Thẻ hiển thị Level (UI giống hình ảnh)
    struct LevelCardView: View {
        let level: Int
        let count: Int
        
        // Hàm chọn màu sắc dựa trên Level
        private var cardColor: Color {
            switch level {
            case 0: return Color.gray        // Lv0: Chưa thuộc
            case 1: return Color.red.opacity(0.8)  // Lv1
            case 2: return Color.yellow      // Lv2
            case 3: return Color.cyan        // Lv3
            case 4: return Color.blue        // Lv4
            case 5: return Color(uiColor: .systemIndigo) // Lv5
            default: return Color.purple     // Lv6+
            }
        }
        
        var body: some View {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                    
                    Text("LV\(level)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(cardColor)
                }
                .padding(.leading, 20)
                Text("\(count) words")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .frame(height: 80)
            .background(cardColor)
            .cornerRadius(16)
            .shadow(color: cardColor.opacity(0.5), radius: 5, x: 0, y: 5)
        }
    }


#Preview {
    HandBookView()
}
