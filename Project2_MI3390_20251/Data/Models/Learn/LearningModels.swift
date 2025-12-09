//
//  Course.swift
//  DataDemo
//
//  Created by Nguyễn Quang Anh on 3/12/25.
//
//
//  LearningModels.swift
//  DataDemo
//
//  Created by Nguyễn Quang Anh on 3/12/25.
//

import Foundation
import SwiftData

// --- CONTENT GROUP ---

@Model
final class Course: Codable {
    var name: String
    var desc: String
    var subDescription: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var lessons: [Lesson] = []
    
    enum CodingKeys: String, CodingKey {
        case name
        case desc = "description" // JSON key là "description", Swift biến là "desc"
        case subDescription, lessons
    }
    
    init(name: String, desc: String, subDescription: String) {
        self.name = name
        self.desc = desc
        self.subDescription = subDescription
        self.createdAt = Date()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.subDescription = try container.decode(String.self, forKey: .subDescription)
        self.createdAt = Date()
        self.lessons = try container.decodeIfPresent([Lesson].self, forKey: .lessons) ?? []
        
        // Gán cha cho con (QUAN TRỌNG)
        for lesson in self.lessons {
            lesson.course = self
        }
    }
    
    func encode(to encoder: Encoder) throws { }
}

@Model
final class Lesson: Codable {
    var name: String
    var subName: String
    var quantityOfWord: Int
    var createdAt: Date
    
    var course: Course?
    @Relationship(deleteRule: .cascade) var words: [Word] = []
    
    enum CodingKeys: String, CodingKey {
        case name, subName, quantityOfWord, words
    }
    
    init(name: String, subName: String, quantityOfWord: Int) {
        self.name = name
        self.subName = subName
        self.quantityOfWord = quantityOfWord
        self.createdAt = Date()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.subName = try container.decode(String.self, forKey: .subName)
        self.quantityOfWord = try container.decode(Int.self, forKey: .quantityOfWord)
        self.createdAt = Date()
        self.words = try container.decodeIfPresent([Word].self, forKey: .words) ?? []
        
        // Gán cha cho con (QUAN TRỌNG)
        for word in self.words {
            word.lesson = self
        }
    }
    
    func encode(to encoder: Encoder) throws { }
}

@Model
final class Word: Codable {
    var english: String
    var phonetic: String
    var partOfSpeech: String
    var audioUrl: String
    var cefr: String
    var createdAt: Date
    
    var lesson: Lesson?
    @Relationship(deleteRule: .cascade) var meanings: [Meaning] = []
    @Relationship(deleteRule: .cascade) var studyRecords: [StudyRecord] = []

    enum CodingKeys: String, CodingKey {
        case english, phonetic, partOfSpeech, audioUrl, meanings
        case cefr = "CEFR" // Map JSON "CEFR" -> Swift "cefr" (Refactor chuẩn)
    }

    init(english: String, phonetic: String, partOfSpeech: String, audioUrl: String, cefr: String) {
        self.english = english
        self.phonetic = phonetic
        self.partOfSpeech = partOfSpeech
        self.audioUrl = audioUrl
        self.cefr = cefr
        self.createdAt = Date()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.english = try container.decode(String.self, forKey: .english)
        self.phonetic = try container.decode(String.self, forKey: .phonetic)
        self.partOfSpeech = try container.decode(String.self, forKey: .partOfSpeech)
        self.audioUrl = try container.decode(String.self, forKey: .audioUrl)
        self.cefr = try container.decode(String.self, forKey: .cefr) // Sử dụng case đã map chuẩn
        self.createdAt = Date()
        self.meanings = try container.decodeIfPresent([Meaning].self, forKey: .meanings) ?? []
        
        // Gán cha cho con (QUAN TRỌNG)
        for meaning in self.meanings {
            meaning.word = self
        }
    }
    
    func encode(to encoder: Encoder) throws { }
}

@Model
final class Meaning: Codable {
    var vietnamese: String
    var exampleEn: String
    var exampleVi: String
    var createdAt: Date
    
    var word: Word?

    enum CodingKeys: String, CodingKey {
        case vietnamese, exampleEn, exampleVi
    }

    init(vietnamese: String, exampleEn: String, exampleVi: String) {
        self.vietnamese = vietnamese
        self.exampleEn = exampleEn
        self.exampleVi = exampleVi
        self.createdAt = Date()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.vietnamese = try container.decode(String.self, forKey: .vietnamese)
        self.exampleEn = try container.decode(String.self, forKey: .exampleEn)
        self.exampleVi = try container.decode(String.self, forKey: .exampleVi)
        self.createdAt = Date()
    }
    
    func encode(to encoder: Encoder) throws { }
}

// --- USER & TRACKING GROUP (Giữ nguyên như cũ) ---
@Model
final class User {
    var name: String
    var phone: String
    var createdAt: Date
    var isPremium: Bool
    var premiumExpiryDate: Date?
    @Relationship(deleteRule: .cascade) var account: Account?
    @Relationship(deleteRule: .cascade) var studyRecords: [StudyRecord] = []
    @Relationship(deleteRule: .cascade) var lessonRecords: [LessonRecord] = []
    init(name: String, phone: String, isPremium: Bool = false) {
        self.name = name
        self.phone = phone
        self.isPremium = isPremium
        self.createdAt = Date()
    }
}

@Model
final class Account {
    var email: String
    var password: String
    var isPremium: Bool
    var preExpirationDate: Date?
    var statusAccount: String
    var user: User?
    init(email: String, password: String, statusAccount: String = "active") {
        self.email = email
        self.password = password
        self.isPremium = false
        self.statusAccount = statusAccount
    }
}

@Model
final class StudyRecord {
    var user: User?
    var word: Word?
    var memoryLevel: Int
    var lastReview: Date
    var nextReview: Date
    var createdAt: Date
    var updatedAt: Date
    init(user: User, word: Word) {
        self.user = user
        self.word = word
        self.memoryLevel = 0
        self.lastReview = Date()
        self.nextReview = Date()
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
final class LessonRecord {
    var user: User?
    var lesson: Lesson?
    var startedAt: Date
    var completedAt: Date?
    var lastAccessed: Date
    var isLearn: Bool
    init(user: User, lesson: Lesson) {
        self.user = user
        self.lesson = lesson
        self.startedAt = Date()
        self.lastAccessed = Date()
        self.isLearn = false
    }
}
