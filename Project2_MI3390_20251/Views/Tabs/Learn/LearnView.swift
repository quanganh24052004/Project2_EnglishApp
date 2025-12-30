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

struct WordListView: View {
    @State private var isLearningSessionActive: Bool = false
    
    let lesson: Lesson
    
    var body: some View {
        List {
            ForEach(lesson.words) { word in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(word.english)
                            .font(.system(size: 16, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                        
                        Text(word.phonetic)
                            .font(.system(size: 8, design: .rounded))
                            .fontWeight(.regular)
                            .foregroundStyle(.neutral07)
                            .italic()
                        
                        Text(word.partOfSpeech)
                            .font(.system(size: 8, design: .rounded))
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .frame(width: 100, alignment: .leading)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let firstMeaning = word.meanings.first {
                            Text(firstMeaning.vietnamese)
                                .font(.system(size: 14, design: .rounded))
                                .fontWeight(.medium)
                            
                            if !firstMeaning.exampleEn.isEmpty {
                                Text("\"\(firstMeaning.exampleEn)\"")
                                    .font(.system(size: 8, design: .rounded))
                                    .fontWeight(.regular)
                                    .foregroundStyle(.neutral07)
                                    .italic()
                            }
                            
                            if !firstMeaning.exampleVi.isEmpty {
                                Text("\"\(firstMeaning.exampleVi)\"")
                                    .font(.system(size: 8, design: .rounded))
                                    .fontWeight(.regular)
                                    .foregroundStyle(.neutral07)
                                    .italic()
                            }
                        } else {
                            Text("No meaning")
                                .font(.system(size: 14, design: .rounded))
                                .fontWeight(.medium)
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
                    Text("Learn now")
                        .font(.system(size: 14,design: .rounded))
                        .fontWeight(.bold)
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


