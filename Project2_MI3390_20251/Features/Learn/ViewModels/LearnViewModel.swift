//
//  LearnViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Antigravity on 3/2/2026.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

/// ViewModel quản lý dữ liệu cho màn hình Học tập (LearnView).
/// Chịu trách nhiệm lấy danh sách khoá học từ SwiftData.
@MainActor
class LearnViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Danh sách các khoá học.
    @Published var courses: [Course] = []
    
    /// Trạng thái loading
    @Published var isLoading: Bool = false
    
    // MARK: - Actions
    
    /// Tải dữ liệu khoá học từ Database.
    /// - Parameter context: ModelContext của SwiftData (được truyền từ View).
    func loadCourses(context: ModelContext) {
        self.isLoading = true
        
        // Tạo Descriptor để fetch dữ liệu, sắp xếp theo thời gian tạo
        let descriptor = FetchDescriptor<Course>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        
        do {
            let fetchedCourses = try context.fetch(descriptor)
            self.courses = fetchedCourses
        } catch {
            print("❌ Lỗi khi lấy danh sách khoá học: \(error.localizedDescription)")
            // Trong thực tế có thể handle error message để hiển thị lên UI
        }
        
        self.isLoading = false
    }
}
