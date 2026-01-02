//
//  Project2_MI3390_20251App.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI
import SwiftData

@main
struct Project2_MI3390_20251App: App {
    
    // MARK: - Properties
    
    /// Container chứa dữ liệu SwiftData chia sẻ toàn ứng dụng
    let sharedModelContainer: ModelContainer
    
    /// Quản lý ngôn ngữ, sử dụng @StateObject để đảm bảo MainActor
    @StateObject private var languageManager = LanguageManager()
    
    // MARK: - Initialization
    
    init() {
        // Định nghĩa Schema cho SwiftData
        let schema = Schema([
            Course.self, Lesson.self, Word.self, Meaning.self,
            User.self, Account.self, StudyRecord.self, LessonRecord.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            // Khởi tạo ModelContainer
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            sharedModelContainer = container
            
            // Gọi hàm Seed Data (Dùng Static để gọi được trong init)
            Self.checkAndSeedData(context: container.mainContext)
            
        } catch {
            fatalError("❌ [Fatal Error] Không thể tạo ModelContainer: \(error)")
        }
        
        // Yêu cầu quyền thông báo khi khởi động
        NotificationManager.shared.requestPermission()
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.locale, .init(identifier: languageManager.currentLanguage))
                .environmentObject(languageManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Data Seeding Extension

extension Project2_MI3390_20251App {
    
    /// Kiểm tra và đồng bộ dữ liệu từ file JSON vào Database.
    /// Hàm này thực hiện chiến lược "Upsert" (Cập nhật nếu có, Thêm mới nếu chưa).
    /// - Parameter context: ModelContext chính của ứng dụng.
    @MainActor
    static func checkAndSeedData(context: ModelContext) {
        print("🔄 [Sync] Bắt đầu đồng bộ dữ liệu khởi tạo...")
        
        guard let url = Bundle.main.url(forResource: "courses_data", withExtension: "json") else {
            print("❌ [Sync] Lỗi: Không tìm thấy file 'courses_data.json'")
            return
        }
        
        do {
            // Bước 1: Đọc và decode JSON
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonCourses = try decoder.decode([Course].self, from: data)
            
            if jsonCourses.isEmpty { return }
            
            // Bước 2: Lấy dữ liệu hiện có trong DB để so sánh
            let descriptor = FetchDescriptor<Course>()
            let existingCourses = try context.fetch(descriptor)
            
            // Tạo Map để tra cứu nhanh (Tránh lỗi crash nếu trùng key bằng uniquingKeysWith)
            let existingCourseMap = Dictionary(existingCourses.map { ($0.name, $0) }, uniquingKeysWith: { (first, _) in first })
            
            var newCourseCount = 0
            var updatedCourseCount = 0
            
            // Bước 3: Duyệt và Upsert
            for jsonCourse in jsonCourses {
                if let dbCourse = existingCourseMap[jsonCourse.name] {
                    // Update: Nếu khóa học đã tồn tại
                    updateCourse(target: dbCourse, source: jsonCourse, context: context)
                    updatedCourseCount += 1
                } else {
                    // Insert: Nếu là khóa học mới
                    context.insert(jsonCourse)
                    newCourseCount += 1
                }
            }
            
            // Bước 4: Lưu thay đổi
            if context.hasChanges {
                try context.save()
                print("✅ [Sync] Đồng bộ hoàn tất: Thêm mới (\(newCourseCount)), Cập nhật (\(updatedCourseCount))")
            } else {
                print("✅ [Sync] Dữ liệu đã ở phiên bản mới nhất.")
            }
            
        } catch {
            print("❌ [Sync] Lỗi ngoại lệ: \(error)")
        }
    }
    
    // MARK: - Helper Update Functions
    
    /// Cập nhật thông tin Course và các Lesson con.
    static private func updateCourse(target: Course, source: Course, context: ModelContext) {
        // Cập nhật thuộc tính cơ bản
        if target.desc != source.desc { target.desc = source.desc }
        if target.subDescription != source.subDescription { target.subDescription = source.subDescription }
        
        // Map các Lesson hiện có để so sánh
        let existingLessonMap = Dictionary(target.lessons.map { ($0.name, $0) }, uniquingKeysWith: { (first, _) in first })
        
        for jsonLesson in source.lessons {
            if let dbLesson = existingLessonMap[jsonLesson.name] {
                updateLesson(target: dbLesson, source: jsonLesson, context: context)
            } else {
                // Thêm Lesson mới vào Course cũ
                jsonLesson.course = target
                target.lessons.append(jsonLesson)
            }
        }
    }
    
    /// Cập nhật thông tin Lesson và các Word con.
    static private func updateLesson(target: Lesson, source: Lesson, context: ModelContext) {
        if target.subName != source.subName { target.subName = source.subName }
        if target.quantityOfWord != source.quantityOfWord { target.quantityOfWord = source.quantityOfWord }
        
        // Map các Word hiện có
        let existingWordMap = Dictionary(target.words.map { ($0.english, $0) }, uniquingKeysWith: { (first, _) in first })
        
        for jsonWord in source.words {
            if let dbWord = existingWordMap[jsonWord.english] {
                updateWord(target: dbWord, source: jsonWord, context: context)
            } else {
                // Thêm Word mới vào Lesson cũ
                jsonWord.lesson = target
                target.words.append(jsonWord)
            }
        }
    }
    
    /// Cập nhật thông tin Word và Meaning.
    static private func updateWord(target: Word, source: Word, context: ModelContext) {
        // Cập nhật metadata của từ
        if target.phonetic != source.phonetic { target.phonetic = source.phonetic }
        if target.partOfSpeech != source.partOfSpeech { target.partOfSpeech = source.partOfSpeech }
        if target.audioUrl != source.audioUrl { target.audioUrl = source.audioUrl }
        if target.cefr != source.cefr { target.cefr = source.cefr }
        
        // Cập nhật Meaning: So sánh mảng String để tối ưu hiệu suất ghi
        let oldMeanings = target.meanings.map { "\($0.vietnamese)|\($0.exampleEn)" }.sorted()
        let newMeanings = source.meanings.map { "\($0.vietnamese)|\($0.exampleEn)" }.sorted()
        
        if oldMeanings != newMeanings {
            // Nếu có thay đổi nghĩa: Xóa cũ -> Thêm mới (chiến lược Clean Replace)
            for oldM in target.meanings { context.delete(oldM) }
            target.meanings.removeAll()
            
            for newM in source.meanings {
                newM.word = target
                target.meanings.append(newM)
            }
        }
    }
}
