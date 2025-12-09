//
//  LearningItem.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import Foundation

struct LearningItem: Identifiable {
    let id = UUID()
    let word: String           // Thay vì chứa object Word, ta chứa String (English)
    let phonetic: String       // [MỚI] Thêm trường phiên âm
    let partOfSpeech: String   // [MỚI] Thêm từ loại (Noun, Verb...)
    let meaning: String        // Nghĩa tiếng Việt
    let example: String        // [MỚI] Câu ví dụ
//    let audioUrl: String
    let vietnamese: String
}
