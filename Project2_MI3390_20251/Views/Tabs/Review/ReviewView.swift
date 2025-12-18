//
//  ReviewView 2.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 17/12/25.
//


import SwiftUI
import SwiftData
import Charts // Thư viện biểu đồ của Apple

struct ReviewView: View {
    // Query lấy toàn bộ StudyRecord của User
    // (Ở đây demo lấy tất cả, thực tế bạn có thể filter theo User hiện tại nếu app có login)
    @Query var studyRecords: [StudyRecord]
    
    // Tính toán thống kê theo Level (1-5)
    var levelStats: [LevelStat] {
        var counts = [0, 0, 0, 0, 0, 0] // Index 0 bỏ qua, dùng 1-5
        
        for record in studyRecords {
            // Đảm bảo level nằm trong khoảng 1-5
            if record.memoryLevel >= 1 && record.memoryLevel <= 5 {
                counts[record.memoryLevel] += 1
            }
        }
        
        return [
            LevelStat(level: "Mới học", count: counts[1], color: .blue),
            LevelStat(level: "Nhớ ít", count: counts[2], color: .cyan),
            LevelStat(level: "Khá", count: counts[3], color: .green),
            LevelStat(level: "Tốt", count: counts[4], color: .orange),
            LevelStat(level: "Thành thạo", count: counts[5], color: .purple)
        ]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // CARD TỔNG QUAN
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Tổng số từ đã học")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("\(studyRecords.count)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    Text("Mức độ ghi nhớ")
                        .font(.title2.bold())
                        .padding(.top)
                    
                    // BIỂU ĐỒ (CHART)
                    if studyRecords.isEmpty {
                        Text("Bạn chưa học từ nào. Hãy bắt đầu ngay!")
                            .foregroundStyle(.secondary)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                    } else {
                        Chart(levelStats) { item in
                            BarMark(
                                x: .value("Mức độ", item.level),
                                y: .value("Số từ", item.count)
                            )
                            .foregroundStyle(item.color.gradient)
                            .annotation(position: .top) {
                                Text("\(item.count)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(height: 300)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Tổng quan")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

// Struct phụ để vẽ biểu đồ
struct LevelStat: Identifiable {
    let id = UUID()
    let level: String
    let count: Int
    let color: Color
}

#Preview {
    ReviewView()
        .modelContainer(for: [StudyRecord.self, User.self, Word.self]) // Mock data cho preview
}