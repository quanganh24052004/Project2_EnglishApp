//
//  ReviewView.swift
//  Project2_MI3390_20251
//
//  Refactored: Fix lỗi hiển thị từ của User khác
//

import SwiftUI
import SwiftData
import Charts
import Combine
import Supabase

struct ReviewView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    
    // 1. Lấy AuthViewModel để biết ai đang đăng nhập
    @EnvironmentObject var authVM: AuthViewModel
    
    // 2. Thay @Query bằng @State để tự quản lý dữ liệu
    @State private var studyRecords: [StudyRecord] = []
    
    // Trạng thái thời gian thực
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var showPractice = false
    
    // MARK: - Computed Properties
    
    var dueRecords: [StudyRecord] {
        return studyRecords.filter { $0.nextReview <= currentTime }
    }
    
    var nextReviewDate: Date? {
        return studyRecords
            .filter { $0.nextReview > currentTime }
            .map { $0.nextReview }
            .min()
    }
    
    var upcomingCount: Int {
        guard let nextDate = nextReviewDate else { return 0 }
        let windowEnd = nextDate.addingTimeInterval(60 * 60)
        return studyRecords.filter { record in
            return record.nextReview >= nextDate && record.nextReview <= windowEnd
        }.count
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
                            // Bây giờ biến này chỉ đếm số bản ghi của User hiện tại
                            Text("\(studyRecords.count) từ vựng")
                                .font(.system(size: 24, design: .rounded))
                                .fontWeight(.bold)
                        }
                        Spacer()
                        
                        // Circle Indicator
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
                    
                    // 2. Chart
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
                    
                    // 3. Action Area
                    VStack {
                        if !dueRecords.isEmpty {
                            Button(action: { showPractice = true }) {
                                HStack {
                                    Image(systemName: "play.circle.fill").font(.title2)
                                    Text("Bắt đầu ôn tập ngay").fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ThreeDButtonStyle(color: .pGreen))
                            .padding(.horizontal, 20)
                        } else {
                            if let nextDate = nextReviewDate {
                                VStack(spacing: 12) {
                                    Text("Bạn đã hoàn thành tất cả bài ôn tập! 🎉")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                    
                                    HStack {
                                        Image(systemName: "clock")
                                        Text("Bài tiếp theo sau: \(timeString(to: nextDate))")
                                            .font(.system(.body, design: .monospaced))
                                    }
                                    .foregroundColor(.gray)
                                    
                                    Divider().padding(.horizontal, 40)
                                    
                                    HStack(spacing: 4) {
                                        Text("Sắp có").foregroundColor(.gray)
                                        Text("\(upcomingCount)").fontWeight(.bold).foregroundColor(.blue)
                                        Text("từ chuẩn bị ôn tập").foregroundColor(.gray)
                                    }
                                    .font(.caption)
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
            .background(Color(.neutral01))
            .navigationTitle("Ôn tập")
            .onReceive(timer) { input in currentTime = input }
            .fullScreenCover(isPresented: $showPractice) {
                // Khi đóng màn hình ôn tập về, cần load lại dữ liệu để cập nhật progress
                ReviewContainerView(modelContext: modelContext)
                    .onDisappear {
                        loadDashboardData()
                    }
            }
        }
        // 3. Gọi hàm load dữ liệu khi màn hình xuất hiện
        .onAppear {
            loadDashboardData()
        }
        // 4. Load lại khi trạng thái đăng nhập thay đổi (User A -> User B)
        .onChange(of: authVM.currentUser) { _, _ in
            loadDashboardData()
        }
    }
    
    // MARK: - Data Loading Logic
    // Hàm này lọc dữ liệu chính xác theo User ID
    func loadDashboardData() {
        let userID = authVM.currentUser?.id.uuidString ?? "guest_user_id"
        
        // Predicate: Chỉ lấy record của user hiện tại
        let descriptor = FetchDescriptor<StudyRecord>(
            predicate: #Predicate { $0.user?.id == userID }
        )
        
        do {
            self.studyRecords = try modelContext.fetch(descriptor)
        } catch {
            print("❌ Dashboard Load Error: \(error)")
            self.studyRecords = []
        }
    }
    
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
