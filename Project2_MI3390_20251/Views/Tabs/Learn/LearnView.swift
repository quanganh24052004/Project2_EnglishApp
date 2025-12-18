//
//  ReviewView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import SwiftUI
import SwiftData

struct LearnView: View {
    // Lấy dữ liệu Course từ Database, sắp xếp theo ngày tạo
    @Query(sort: \Course.createdAt, order: .forward) private var courses: [Course]

    var body: some View {
        NavigationStack {
            List {
                ForEach(courses) { course in
                    // NavigationLink để chuyển sang màn hình danh sách bài học
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
            .navigationTitle("Khóa học của tôi")
        }
    }
}

// --- MÀN HÌNH 2: DANH SÁCH BÀI HỌC (LESSON) ---
struct LessonListView: View {
    let course: Course
    
    var body: some View {
        List {
            // Lấy danh sách lesson từ quan hệ trong model Course
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
                        
                        // Hiển thị số lượng từ thực tế có trong database
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

// --- MÀN HÌNH 3: DANH SÁCH TỪ VỰNG (WORD) ---
struct WordListView: View {
    @State private var isLearningSessionActive: Bool = false
    
    let lesson: Lesson
    
    var body: some View {
        List {
            // Lấy danh sách words từ model Lesson
            ForEach(lesson.words) { word in
                HStack(alignment: .top) {
                    // Cột bên trái: Từ tiếng Anh và phát âm
                    VStack(alignment: .leading, spacing: 4) {
                        Text(word.english)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        Text(word.phonetic)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .italic()
                        
                        // Hiển thị loại từ (noun, verb...)
                        Text(word.partOfSpeech)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                    .frame(width: 100, alignment: .leading) // Cố định chiều rộng cột trái
                    
                    Divider()
                    
                    // Cột bên phải: Nghĩa tiếng Việt
                    VStack(alignment: .leading, spacing: 4) {
                        // Lấy nghĩa đầu tiên (nếu có) để hiển thị tóm tắt
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
                            Text("Chưa có nghĩa")
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
        
        // NÚT HỌC TRÊN TOOLBAR
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    if !lesson.words.isEmpty {
                        isLearningSessionActive = true
                    }
                }) {
                    Text("Học ngay").bold()
                }
                .disabled(lesson.words.isEmpty)
            }
        }
        
        // FULL SCREEN COVER
        .fullScreenCover(isPresented: $isLearningSessionActive) {
            // LOGIC MAPPING: [Word] (Database) -> [LearningItem] (Học)
            let learningItems = lesson.words.map { dbWord in
                let firstMeaning = dbWord.meanings.first
                
                return LearningItem(
                    wordID: dbWord.persistentModelID, // 👈 QUAN TRỌNG: Phải truyền dòng này (Cần sửa struct LearningItem ở Bước 1)
                    word: dbWord.english,
                    phonetic: dbWord.phonetic,
                    partOfSpeech: dbWord.partOfSpeech,
                    meaning: firstMeaning?.vietnamese ?? "Chưa có nghĩa",
                    example: firstMeaning?.exampleEn ?? "",
                    audioUrl: dbWord.audioUrl,
                    vietnamese: firstMeaning?.vietnamese ?? "Chưa có nghĩa"
                )
            }
            
            LessonContainerView(items: learningItems)
        }
    }
}


