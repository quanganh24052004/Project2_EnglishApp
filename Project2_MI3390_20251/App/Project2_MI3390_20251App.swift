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
    let sharedModelContainer: ModelContainer
    
    init() {
        let schema = Schema([
            Course.self, Lesson.self, Word.self, Meaning.self,
            User.self, Account.self, StudyRecord.self, LessonRecord.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            checkAndSeedData()
            
        } catch {
            fatalError("❌ Lỗi nghiêm trọng: Không thể tạo ModelContainer: \(error)")
        }
    }
    
    @MainActor
    func checkAndSeedData() {
        let context = sharedModelContainer.mainContext
        
        let descriptor = FetchDescriptor<Course>()
        do {
            let existingCourses = try context.fetch(descriptor)
            
            if !existingCourses.isEmpty {
                print("✅ Dữ liệu đã tồn tại: \(existingCourses.count) khóa học.")
                // Kiểm tra sơ bộ xem dữ liệu có con không
                if let firstCourse = existingCourses.first {
                    print("   - Khóa học đầu: \(firstCourse.name)")
                    print("   - Số bài học: \(firstCourse.lessons.count)")
                }
                return
            }
        } catch {
            print("⚠️ Lỗi khi fetch dữ liệu cũ: \(error)")
        }
        
        print("⏳ Database trống. Bắt đầu nạp JSON...")
        
        guard let url = Bundle.main.url(forResource: "courses_data", withExtension: "json") else {
            print("❌ LỖI LỚN: Không tìm thấy file 'courses_data.json'!")
            print("👉 Hướng dẫn fix: Kiểm tra file inspector bên phải Xcode -> Tích chọn Target Membership.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            let decoder = JSONDecoder()
            
            let courses = try decoder.decode([Course].self, from: data)
            
            if courses.isEmpty {
                print("⚠️ Cảnh báo: File JSON được tìm thấy nhưng là mảng rỗng []")
                return
            }
            
            for course in courses {
                context.insert(course)
            }
            
            try context.save()
            print("✅ NẠP THÀNH CÔNG: \(courses.count) khóa học vào Database.")
            
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ Lỗi dữ liệu JSON hỏng: \(context.debugDescription)")
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ Lỗi thiếu Key: '\(key.stringValue)' không tìm thấy. Path: \(context.codingPath)")
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Lỗi sai kiểu dữ liệu: Cần kiểu \(type), nhưng JSON khác. Path: \(context.codingPath)")
        } catch let DecodingError.valueNotFound(value, context) {
            print("❌ Lỗi thiếu giá trị: '\(value)' không tìm thấy. Path: \(context.codingPath)")
        } catch {
            print("❌ Lỗi không xác định khi nạp JSON: \(error)")
        }
    }


    var body: some Scene {
        WindowGroup {
            RootView()
//                .font(.appFont(size: 16, weight: .regular))
        }
        .modelContainer(sharedModelContainer)
    }
}


