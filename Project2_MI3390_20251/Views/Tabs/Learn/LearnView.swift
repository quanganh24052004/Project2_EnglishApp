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
                        VStack(alignment: .leading) {
                            Text(course.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(course.desc)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
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
                        VStack(alignment: .leading) {
                            Text(lesson.name)
                                .font(.headline)
                            Text(lesson.subName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "book.closed")
                            Text("\(lesson.words.count)")
                        }
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WordListView: View {
    @State private var isLearningSessionActive: Bool = false
    
    let lesson: Lesson
    
    var body: some View {
        List {
            ForEach(lesson.words) { word in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(word.english)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        Text(word.phonetic)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .italic()
                        
                        Text(word.partOfSpeech)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                    .frame(width: 100, alignment: .leading)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let firstMeaning = word.meanings.first {
                            Text(firstMeaning.vietnamese)
                                .font(.body)
                                .fontWeight(.medium)
                            
                            if !firstMeaning.exampleEn.isEmpty {
                                Text("\"\(firstMeaning.exampleEn)\"")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .italic()
                            }
                        } else {
                            Text("No meaning")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(lesson.name)
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    if !lesson.words.isEmpty {
                        isLearningSessionActive = true
                    }
                }) {
                    Text("Learn now").bold()
                }
                .disabled(lesson.words.isEmpty)
            }
        }
        
        .fullScreenCover(isPresented: $isLearningSessionActive) {
            let learningItems = lesson.words.map { dbWord in
                let firstMeaning = dbWord.meanings.first
                
                return LearningItem(
                    wordID: dbWord.persistentModelID,
                    word: dbWord.english,
                    phonetic: dbWord.phonetic,
                    partOfSpeech: dbWord.partOfSpeech,
                    meaning: firstMeaning?.vietnamese ?? "It's not meaningful yet",
                    example: firstMeaning?.exampleEn ?? "There is no example yet",
                    audioUrl: dbWord.audioUrl,
                    vietnamese: firstMeaning?.vietnamese ?? "t's not meaningful yet"
                )
            }
            
            LessonContainerView(items: learningItems)
        }
    }
}


