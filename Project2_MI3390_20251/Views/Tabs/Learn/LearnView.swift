//
//  ReviewView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import SwiftUI
import SwiftData

struct LearnView: View {
    @Query(sort: \Course.createdAt, order: .forward) private var courses: [Course]

    var body: some View {
        NavigationStack {
            List {
                ForEach(courses) { course in
                    NavigationLink(destination: LessonListView(course: course)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(course.name)
                                .font(.system(size: 20, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color.black)
                            HStack (spacing: 16) {
                                VStack (spacing: 8) {
                                    Image(systemName: "target")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.orange)
                                    
                                    Image(systemName: "graduationcap.fill")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.orange)
                                }

                                VStack (spacing: 8) {
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
            }
            .navigationTitle("course_screen_title")
        }
    }
}

struct LessonListView: View {
    let course: Course
    
    var body: some View {
        List {
            ForEach(course.lessons.sorted(by: { $0.createdAt < $1.createdAt })) { lesson in
                NavigationLink(destination: WordListView(lesson: lesson)) {
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
                .padding(8)
            }
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
