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
    @Environment(AuthViewModel.self) var authVM
    @EnvironmentObject var languageManager: LanguageManager

    @State private var viewModel: ReviewViewModel
    
    // Trạng thái điều hướng
    @State private var navigateToHandbook = false
    @State private var showPractice = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        let manager = LearningManager(modelContext: modelContext)
        _viewModel = State(wrappedValue: ReviewViewModel(modelContext: modelContext, learningManager: manager))
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
                            Text("\(viewModel.studyRecords.count)")
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
                        
                        HStack(spacing: 16) {
                            HandbookButton {}
                                .allowsHitTesting(false)
                            Spacer()
                        }
                        .padding(.leading, 16)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigateToHandbook = true
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        if viewModel.studyRecords.isEmpty {
                            ContentUnavailableView("To activate the Review feature, learn new words!", systemImage: "chart.bar")
                                .frame(height: 200)
                        } else {
                            ReviewChartView(
                                dataPoints: viewModel.levelStats.map { $0.count }
                            )
                        }
                    }
                    
                    VStack {
                        if !viewModel.dueRecords.isEmpty {
                            HStack(spacing: 4) {
                                Text("Prepare to review: ")
                                    .font(.system(size: 18, design: .rounded))
                                    .fontWeight(.semibold)
                                Text("\(viewModel.dueRecords.count)")
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
                            .capyButton(.primary(color: CapyColors.green, shadow: CapyColors.greenShadow))
                            .padding(.horizontal, 48)
                        } else {
                            if let nextDate = viewModel.nextReviewDate {
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
                                        Text("\(viewModel.upcomingCount)")
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
                    .animation(.smooth, value: viewModel.dueRecords.isEmpty)
                }
                .padding(8)
            }
            .background(.primaryBG)
            .navigationTitle(languageManager.currentLanguage == "vi" ? "Ôn tập" : "Review")
            .navigationDestination(isPresented: $navigateToHandbook) {
                HandBookView()
            }
            .onReceive(timer) { _ in viewModel.updateCurrentTime() }
            .fullScreenCover(isPresented: $showPractice) {
                ReviewContainerView(modelContext: modelContext)
                    .onDisappear {
                        viewModel.loadDashboardData(currentUser: authVM.currentUser)
                    }
            }
        }
        .onAppear {
            viewModel.loadDashboardData(currentUser: authVM.currentUser)
        }
        .onChange(of: authVM.currentUser) { _, _ in
            viewModel.loadDashboardData(currentUser: authVM.currentUser)
        }
    }
    
    // MARK: - Helpers
    
    func timeString(to target: Date) -> String {
        let diff = target.timeIntervalSince(viewModel.currentTime)
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
