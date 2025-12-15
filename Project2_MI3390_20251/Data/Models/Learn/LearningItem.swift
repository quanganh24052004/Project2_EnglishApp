//
//  LearningItem.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import Foundation

struct LearningItem: Identifiable {
    let id = UUID()
    let word: String           
    let phonetic: String
    let partOfSpeech: String
    let meaning: String
    let example: String
    let audioUrl: String?
    let vietnamese: String
}
