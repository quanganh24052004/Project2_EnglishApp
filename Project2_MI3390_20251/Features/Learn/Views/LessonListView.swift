//
//  LessonListView.swift
//  Project2_MI3390_20251
//
//  Created by Antigravity on 3/2/2026.
//

import SwiftUI

/// View hiển thị danh sách bài học (Lessons) trong một Khoá học (Course).
struct LessonListView: View {
    
    // MARK: - Properties
    
    /// Khoá học cần hiển thị bài học.
    let course: Course
    
    // MARK: - Body
    
    var body: some View {
        List {
            // Sắp xếp bài học theo thời gian tạo trước khi hiển thị
            ForEach(course.lessons.sorted(by: { $0.createdAt < $1.createdAt })) { lesson in
                NavigationLink(destination: WordListView(lesson: lesson)) {
                    lessonRow(lesson: lesson)
                }
                .padding(8)
            }
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    /// Một dòng hiển thị thông tin bài học
    private func lessonRow(lesson: Lesson) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(lesson.name)
                    .font(.system(size: 18, design: .rounded))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text(lesson.subName)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color.neutral08)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Badge hiển thị số lượng từ
            HStack(spacing: 4) {
                Image(systemName: "book.closed")
                Text("\(lesson.words.count)")
            }
            .font(.system(size: 12, design: .rounded))
            .foregroundStyle(.orange)
            .padding(8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(16)
        }
    }
}
