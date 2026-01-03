//
//  ReviewView.swift
//  Project2_MI3390_20251
//
//  Refactored: Fixed Navigation & Touch Events
//

import SwiftUI
import SwiftData
import Charts
import Combine
import Supabase

struct ReviewView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var languageManager: LanguageManager

    @State private var studyRecords: [StudyRecord] = []
    
    // Trạng thái
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var navigateToHandbook = false
    @State private var showPractice = false
    
    // MARK: - Computed Properties
    // (Giữ nguyên các logic tính toán của bạn)
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
            LevelStat(level: "0", count: counts[0], color: .gray),
            LevelStat(level: "1", count: counts[1], color: .red.opacity(0.8)),
            LevelStat(level: "2", count: counts[2], color: .yellow),
            LevelStat(level: "3", count: counts[3], color: .cyan),
            LevelStat(level: "4", count: counts[4], color: .blue),
            LevelStat(level: "5", count: counts[5], color: .purple)
        ]
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    ZStack {
                        HStack(spacing: 8) {
                            Text("The Notebook has")
                                .font(.system(size: 20, design: .rounded))
                                .fontWeight(.regular)
                            Text("\(studyRecords.count)")
                                .font(.system(size: 20, design: .rounded))
                                .fontWeight(.semibold)
                            Text("words")
                                .font(.system(size: 20, design: .rounded))
                                .fontWeight(.regular)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.neutral04)
                        .cornerRadius(16)
                        .padding(.horizontal, 32)
                        
                        HStack(spacing: 8) {
                            HandbookButton {}
                                .allowsHitTesting(false) // ✅ FIX: Để tap xuyên qua nút này
                            Spacer()
                        }
                        .padding(.leading, 16)
                    }
                    .contentShape(Rectangle()) // ✅ FIX: Mở rộng vùng bấm
                    .onTapGesture {
                        navigateToHandbook = true
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        if studyRecords.isEmpty {
                            ContentUnavailableView("To activate the Review feature, learn new words!", systemImage: "chart.bar")
                                .frame(height: 200)
                        } else {
                            ReviewChartView(
                                dataPoints: levelStats.map { $0.count }
                            )
                        }
                    }
                    
                    VStack {
                        if !dueRecords.isEmpty {
                            HStack(spacing: 4) {
                                Text("Prepare to review: ")
                                    .font(.system(size: 18, design: .rounded))
                                    .fontWeight(.semibold)
                                Text("\(dueRecords.count)")
                                    .font(.system(size: 18, design: .rounded))
                                    .fontWeight(.semibold)
                                Text("words")
                                    .font(.system(size: 18, design: .rounded))
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            
                            Button(action: { showPractice = true }) {
                                HStack {
                                    Text("Review now!")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ThreeDButtonStyle(color: .pGreen))
                            .padding(.horizontal, 48)
                        } else {
                            if let nextDate = nextReviewDate {
                                VStack(spacing: 12) {
                                    Text("You have completed all the review exercises!🎉")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                    
                                    HStack {
                                        Image(systemName: "clock")
                                        Text("Next review: \(timeString(to: nextDate))")
                                            .font(.system(.body, design: .monospaced))
                                    }
                                    .foregroundColor(.gray)
                                    
                                    Divider().padding(.horizontal, 40)
                                    
                                    HStack(spacing: 4) {
                                        Text("Coming soon")
                                            .foregroundColor(.gray)
                                        Text("\(upcomingCount)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                        Text("words to review")
                                            .foregroundColor(.gray)
                                    }
                                    .font(.caption)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(16)
                            } else {
                                Text("Learn more new words to start reviewing!")
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
            .navigationTitle(languageManager.currentLanguage == "vi" ? "Ôn tập" : "Review")
            .navigationDestination(isPresented: $navigateToHandbook) {
                HandBookView()
            }
            .onReceive(timer) { input in currentTime = input }
            .fullScreenCover(isPresented: $showPractice) {
                ReviewContainerView(modelContext: modelContext)
                    .onDisappear {
                        loadDashboardData()
                    }
            }
        }
        .onAppear {
            loadDashboardData()
        }
        .onChange(of: authVM.currentUser) { _, _ in
            loadDashboardData()
        }
    }
    
    // MARK: - Logic
    
    func loadDashboardData() {
        let userID = authVM.currentUser?.id.uuidString ?? "guest_user_id"
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
        if diff <= 0 { return "Ready" }
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let seconds = Int(diff) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// Model phụ
struct LevelStat: Identifiable {
    let id = UUID()
    let level: String
    let count: Int
    let color: Color
}
