//
//  LearnView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import SwiftUI
import SwiftData

struct LearnView: View {
    // MARK: - Dependencies
    
    /// Context Database để truyền vào ViewModel
    @Environment(\.modelContext) private var modelContext
    
    /// ViewModel quản lý dữ liệu
    @StateObject private var viewModel = LearnViewModel()

    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("course_screen_title")
                .onAppear {
                    // Gọi ViewModel lấy dữ liệu khi màn hình xuất hiện
                    viewModel.loadCourses(context: modelContext)
                }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView("Loading courses...")
        } else if viewModel.courses.isEmpty {
            emptyStateView
        } else {
            courseListView
        }
    }
    
    private var courseListView: some View {
        List {
            ForEach(viewModel.courses) { course in
                NavigationLink(destination: LessonListView(course: course)) {
                    courseRow(course: course)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No courses available yet.")
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
    
    private func courseRow(course: Course) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(course.name)
                .font(.system(size: 20, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color.black)
            
            HStack(spacing: 16) {
                // Icon Column
                VStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.orange)
                }

                // Text Column
                VStack(spacing: 8) {
                    HStack {
                        Text(course.desc)
                            .font(.system(size: 14, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.neutral06)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        Spacer()
                    }
                    HStack {
                        Text(course.subDescription)
                            .font(.system(size: 14, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.neutral06)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        Spacer()
                    }
                }
            }
        }
        .padding(4)
    }
}
