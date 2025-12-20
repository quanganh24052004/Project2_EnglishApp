//
//  ReviewView.swift
//  Project2_MI3390_20251
//
//  Refactored with Countdown Timer
//

import SwiftUI
import SwiftData
import Charts
import Combine

struct ReviewView: View {
    // 1. Dữ liệu từ SwiftData
    @Query var studyRecords: [StudyRecord]
    
    // 2. Timer để cập nhật UI mỗi giây
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - COMPUTED PROPERTIES
    
    // A. Những từ ĐÃ đến hạn (Tính theo currentTime)
    var dueRecords: [StudyRecord] {
        return studyRecords.filter { $0.nextReview <= currentTime }
    }
    
    // B. Tìm thời gian của từ SẮP đến hạn nhất (để đếm ngược)
    var nextReviewDate: Date? {
        // Lấy các từ chưa đến hạn -> sắp xếp tăng dần -> lấy cái đầu tiên
        return studyRecords
            .filter { $0.nextReview > currentTime }
            .map { $0.nextReview }
            .min()
    }
    
    // C. Thống kê (Giữ nguyên logic cũ)
    var levelStats: [LevelStat] {
        var counts = [0, 0, 0, 0, 0, 0]
        for record in studyRecords {
            let level = min(max(record.memoryLevel, 0), 5)
            if level >= 1 { counts[level] += 1 }
        }
        return [
            LevelStat(level: "Mới", count: counts[1], color: .blue),
            LevelStat(level: "Nhớ ít", count: counts[2], color: .cyan),
            LevelStat(level: "Khá", count: counts[3], color: .green),
            LevelStat(level: "Tốt", count: counts[4], color: .orange),
            LevelStat(level: "Thuộc", count: counts[5], color: .purple)
        ]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - SECTION 1: TRẠNG THÁI ÔN TẬP
                    if !dueRecords.isEmpty {
                        // TRƯỜNG HỢP 1: CÓ BÀI CẦN HỌC
                        activeReviewCard
                    } else {
                        // TRƯỜNG HỢP 2: ĐÃ HỌC HẾT -> HIỆN ĐỒNG HỒ ĐẾM NGƯỢC
                        countdownCard
                    }
                    
                    // MARK: - SECTION 2: BIỂU ĐỒ
                    statsCard
                }
                .padding()
            }
            .navigationTitle("Tổng quan")
            .background(Color(UIColor.systemGroupedBackground))
            // Quan trọng: Cập nhật biến currentTime mỗi giây
            .onReceive(timer) { input in
                currentTime = input
            }
        }
    }
    
    // MARK: - SUBVIEWS
    
    // Card hiển thị khi có bài
    var activeReviewCard: some View {
        VStack(alignment: .leading) {
            Text("Đã đến giờ học!")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(dueRecords.count)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                    Text("từ vựng cần ôn")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "book.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            // Nút chuyển sang màn hình PracticeView
            NavigationLink(destination: PracticeView(records: dueRecords)) {
                Text("Bắt đầu ngay")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    // Card đếm ngược
    var countdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                
                VStack(alignment: .leading) {
                    Text("Hoàn thành!")
                        .font(.headline)
                    Text("Bạn đã ôn tập hết các từ hiện tại.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // LOGIC ĐỒNG HỒ
            if let targetDate = nextReviewDate {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Phiên tiếp theo sau:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        // Hiển thị thời gian đếm ngược
                        Text(timeString(to: targetDate))
                            .font(.title2.monospacedDigit().bold()) // Font số đơn cách để không bị nhảy
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                    Image(systemName: "hourglass")
                        .font(.title)
                        .foregroundStyle(.orange.opacity(0.6))
                }
            } else {
                Text("Chưa có lịch ôn tập mới.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 3)
    }
    
    // Card thống kê
    var statsCard: some View {
        VStack(alignment: .leading) {
            Text("Tiến độ ghi nhớ")
                .font(.title2.bold())
            
            if studyRecords.isEmpty {
                ContentUnavailableView("Chưa có dữ liệu", systemImage: "chart.bar")
            } else {
                Chart(levelStats) { item in
                    BarMark(
                        x: .value("Mức độ", item.level),
                        y: .value("Số từ", item.count)
                    )
                    .foregroundStyle(item.color.gradient)
                    .annotation(position: .top) {
                        if item.count > 0 {
                            Text("\(item.count)").font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 250)
                .padding(.top)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    // MARK: - HELPER FUNCTION: Đổi thời gian ra chuỗi
    func timeString(to target: Date) -> String {
        let diff = target.timeIntervalSince(currentTime)
        
        if diff <= 0 { return "00:00:00" }
        
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let seconds = Int(diff) % 60
        
        // Nếu còn > 24 giờ thì hiện số ngày
        if hours > 24 {
            let days = hours / 24
            return "\(days) ngày nữa"
        }
        
        // Format dạng 01:05:09
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

