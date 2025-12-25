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
    @Query var studyRecords: [StudyRecord]
    
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - COMPUTED PROPERTIES
    
    var dueRecords: [StudyRecord] {
        return studyRecords.filter { $0.nextReview <= currentTime }
    }
    
    var nextReviewDate: Date? {
        return studyRecords
            .filter { $0.nextReview > currentTime }
            .map { $0.nextReview }
            .min()
    }
    
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
            
            LevelStat(level: "3", count: counts[3], color: .green),
            
            LevelStat(level: "4", count: counts[4], color: .orange),
            
            LevelStat(level: "5", count: counts[5], color: .purple)
        ]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - SECTION 1: TRẠNG THÁI ÔN TẬP
                    if !dueRecords.isEmpty {
                        activeReviewCard
                    } else {
                        countdownCard
                    }
                    
                    // MARK: - SECTION 2: BIỂU ĐỒ
                    statsCard
                }
                .padding()
            }
            .navigationTitle("CapyVocab")
            .background(Color(UIColor.systemGroupedBackground))
            .onReceive(timer) { input in
                currentTime = input
            }
        }
    }
    
    // MARK: - SUBVIEWS
    
    var activeReviewCard: some View {
        VStack(alignment: .leading) {
            Text("It's time to study")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(dueRecords.count)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                    Text("word to review")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "book.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            NavigationLink(destination: PracticeView(records: dueRecords)) {
                Text("Start now")
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
    
    var countdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                
                VStack(alignment: .leading) {
                    Text("Finished!")
                        .font(.headline)
                    Text("You have reviewed all the current words.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            if let targetDate = nextReviewDate {
                HStack {
                    VStack(alignment: .leading) {
                        Text("The next session:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
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
                Text("There is no new review schedule yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 3)
    }
    
    var statsCard: some View {
        VStack(alignment: .leading) {
            Text("Memory progress")
                .font(.title2.bold())
            
            if studyRecords.isEmpty {
                ContentUnavailableView("No data yet", systemImage: "chart.bar")
            } else {
                Chart(levelStats) { item in
                    BarMark(
                        x: .value("Level", item.level),
                        y: .value("Number of words", item.count)
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
        
        if hours > 24 {
            let days = hours / 24
            return "\(days) more days"
        }
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct LevelStat: Identifiable {
    let id = UUID()
    let level: String
    let count: Int
    let color: Color
}
