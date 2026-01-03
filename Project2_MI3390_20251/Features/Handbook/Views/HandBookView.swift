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
                            // Lọc các từ thuộc level hiện tại
                            let wordsInLevel = studyRecords.filter { $0.memoryLevel == level }
                            
                            // Navigation chuyển sang màn hình chi tiết
                            NavigationLink(destination: WordListByLevelView(level: level, words: wordsInLevel)) {
                                LevelCardView(level: level, count: wordsInLevel.count)
                            }
                        }
                    }
                    .padding()
                }
                // 2. Hiển thị tổng số từ lên Navigation Title
                .navigationTitle("\(totalWordsCount) từ ôn tập")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground)) // Màu nền xám nhẹ cho toàn màn hình
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
                // Vòng tròn chứa tên Level (Bên trái)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                    
                    Text("LV\(level)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(cardColor) // Chữ cùng màu với nền thẻ
                }
                .padding(.leading, 20)
                
                // Số lượng từ (Ở giữa)
                Text("\(count) từ")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .frame(height: 80)
            .background(cardColor)
            .cornerRadius(16)
            // Hiệu ứng đổ bóng 3D nhẹ bên dưới
            .shadow(color: cardColor.opacity(0.5), radius: 5, x: 0, y: 5)
        }
    }


#Preview {
    HandBookView()
}
