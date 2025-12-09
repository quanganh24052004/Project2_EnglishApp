//
//  LearningItem.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//


// File: LearningItem.swift (hoặc thay thế nội dung Word.swift cũ)
import Foundation

struct LearningItem: Identifiable {
    let id = UUID()
    let term: String       // Từ tiếng Anh (Lấy từ word.english)
    let meaning: String    // Nghĩa tiếng Việt (Lấy từ meaning.vietnamese)
    let audioUrl: String   // Link audio
}