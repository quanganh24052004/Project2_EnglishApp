//
//  ReviewView.swift
//  Project2_MI3390_20251
//
//  Refactored: Dashboard & Navigation to Review Session
//

import SwiftUI
import SwiftData
import Charts
import Combine

struct ReviewView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext // Cần để truyền sang màn hình ôn tập
    @Query var studyRecords: [StudyRecord]
    
    // Trạng thái thời gian thực
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Trạng thái điều hướng
    @State private var showPractice = false
    
    // MARK: - Computed Properties
    
    // Lọc các bản ghi đã đến hạn (NextReview <= Now)
    var dueRecords: [StudyRecord] {
        return studyRecords.filter { $0.nextReview <= currentTime }
    }
    
    // Tìm thời gian review tiếp theo gần nhất (nếu chưa có bài nào)
    var nextReviewDate: Date? {
        return studyRecords
            .filter { $0.nextReview > currentTime }
            .map { $0.nextReview }
            .min()
    }
    
    // Thống kê cho biểu đồ cột
    var levelStats: [LevelStat] {
        var counts = [Int](repeating: 0, count: 6)
        for record in studyRecords {
            let level = min(max(record.memoryLevel, 0), 5)
            counts[level] += 1
        }
        return [
            LevelStat(level: "0", count: counts[0], color: .gray.opacity(0.8)),
            LevelStat(level: "1", count: counts[1], color: .blue.opacity(0.6)),
            LevelStat(level: "2", count: counts[2], color: .blue),
            LevelStat(level: "3", count: counts[3], color: .green.opacity(0.6)),
            LevelStat(level: "4", count: counts[4], color: .green),
            LevelStat(level: "5", count: counts[5], color: .orange)
        ]
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // 1. Header & Summary
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Tổng quan")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("\(studyRecords.count) từ vựng")
                                .font(.title)
                                .bold()
                        }
                        Spacer()
                        
                        // Circle Indicator: Số từ cần ôn ngay
                        ZStack {
                            Circle()
                                .fill(dueRecords.isEmpty ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            VStack(spacing: 0) {
                                Text("\(dueRecords.count)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(dueRecords.isEmpty ? .green : .red)
                                Text("cần ôn")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // 2. Chart (Biểu đồ thống kê)
                    VStack(alignment: .leading) {
                        Text("Mức độ ghi nhớ")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        if studyRecords.isEmpty {
                            ContentUnavailableView("Chưa có dữ liệu", systemImage: "chart.bar")
                                .frame(height: 200)
                        } else {
                            Chart(levelStats) { item in
                                BarMark(
                                    x: .value("Level", item.level),
                                    y: .value("Number of words", item.count)
                                )
                                .foregroundStyle(item.color.gradient)
                                .annotation(position: .top) {
                                    if item.count > 0 {
                                        Text("\(item.count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .frame(height: 220)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // 3. Action Area (Nút Bắt đầu hoặc Đếm ngược)
                    VStack {
                        if !dueRecords.isEmpty {
                            // CASE A: Có bài để học -> Hiện nút Start
                            Button(action: {
                                showPractice = true
                            }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)
                                    Text("Bắt đầu ôn tập ngay")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 5)
                            }
                        } else {
                            // CASE B: Chưa có bài -> Hiện Countdown
                            if let nextDate = nextReviewDate {
                                VStack(spacing: 8) {
                                    Text("Bạn đã hoàn thành tất cả bài ôn tập! 🎉")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                    
                                    HStack {
                                        Image(systemName: "clock")
                                        Text("Bài tiếp theo sau: \(timeString(to: nextDate))")
                                            .font(.system(.body, design: .monospaced))
                                    }
                                    .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(16)
                            } else {
                                Text("Hãy học thêm từ mới để bắt đầu ôn tập!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                    }
                    .animation(.easeInOut, value: dueRecords.isEmpty)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Ôn tập")
            .onReceive(timer) { input in
                currentTime = input
            }
            // MARK: - Navigation
            .fullScreenCover(isPresented: $showPractice) {
                // Mở màn hình ôn tập full màn hình
                ReviewContainerView(modelContext: modelContext)
            }
        }
    }
    
    // Helper: Format thời gian đếm ngược
    func timeString(to target: Date) -> String {
        let diff = target.timeIntervalSince(currentTime)
        if diff <= 0 { return "Sẵn sàng" }
        
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let seconds = Int(diff) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// Model phụ cho biểu đồ
struct LevelStat: Identifiable {
    let id = UUID()
    let level: String
    let count: Int
    let color: Color
}
