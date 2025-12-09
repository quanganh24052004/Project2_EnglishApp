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
        // 1. Cấu hình Schema đầy đủ
        let schema = Schema([
            Course.self, Lesson.self, Word.self, Meaning.self,
            User.self, Account.self, StudyRecord.self, LessonRecord.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Gọi hàm kiểm tra và nạp dữ liệu
            checkAndSeedData()
            
        } catch {
            fatalError("❌ Lỗi nghiêm trọng: Không thể tạo ModelContainer: \(error)")
        }
    }
    
    @MainActor
    func checkAndSeedData() {
        let context = sharedModelContainer.mainContext
        
        // KIỂM TRA DỮ LIỆU CŨ
        let descriptor = FetchDescriptor<Course>()
        do {
            let existingCourses = try context.fetch(descriptor)
            
            // Logic cho Dev: Nếu trong DB đã có dữ liệu nhưng bạn muốn nạp lại từ JSON mới sửa -> Uncomment dòng dưới
            // if !existingCourses.isEmpty { try? context.delete(model: Course.self) }
            
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
        
        // TIẾN HÀNH NẠP DỮ LIỆU
        print("⏳ Database trống. Bắt đầu nạp JSON...")
        
        // Validate File JSON
        guard let url = Bundle.main.url(forResource: "courses_data", withExtension: "json") else {
            print("❌ LỖI LỚN: Không tìm thấy file 'courses_data.json'!")
            print("👉 Hướng dẫn fix: Kiểm tra file inspector bên phải Xcode -> Tích chọn Target Membership.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            // Sử dụng JSONDecoder để decode
            let decoder = JSONDecoder()
            
            // In ra JSON dạng String để debug nếu cần
            // if let jsonString = String(data: data, encoding: .utf8) { print("JSON Content: \(jsonString)") }
            
            let courses = try decoder.decode([Course].self, from: data)
            
            if courses.isEmpty {
                print("⚠️ Cảnh báo: File JSON được tìm thấy nhưng là mảng rỗng []")
                return
            }
            
            // Lưu vào SwiftData
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
//            RootView()
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
