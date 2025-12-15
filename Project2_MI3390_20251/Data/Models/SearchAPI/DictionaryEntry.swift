//
//  DictionaryEntry.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 12/12/25.
//

import Foundation
import Combine
import SwiftUI
import SwiftData

// Cấu trúc phản hồi từ API
struct DictionaryEntry: Codable, Identifiable {
    let id: UUID
    let word: String
    let phonetic: String?
    let meanings: [DictionaryMeaning]

    enum CodingKeys: String, CodingKey {
        case word, phonetic, meanings
    }

    // Khởi tạo tiện lợi khi tạo thủ công
    init(id: UUID = UUID(), word: String, phonetic: String?, meanings: [DictionaryMeaning]) {
        self.id = id
        self.word = word
        self.phonetic = phonetic
        self.meanings = meanings
    }

    // Tự triển khai Decodable để bỏ qua id trong JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.word = try container.decode(String.self, forKey: .word)
        self.phonetic = try container.decodeIfPresent(String.self, forKey: .phonetic)
        self.meanings = try container.decode([DictionaryMeaning].self, forKey: .meanings)
        self.id = UUID()
    }

    // Tự triển khai Encodable để bỏ qua id khi encode JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(word, forKey: .word)
        try container.encodeIfPresent(phonetic, forKey: .phonetic)
        try container.encode(meanings, forKey: .meanings)
    }
}

struct DictionaryMeaning: Codable, Identifiable {
    let id: UUID
    let partOfSpeech: String // Danh từ, động từ...
    let definitions: [DictionaryDefinition]

    enum CodingKeys: String, CodingKey {
        case partOfSpeech, definitions
    }

    init(id: UUID = UUID(), partOfSpeech: String, definitions: [DictionaryDefinition]) {
        self.id = id
        self.partOfSpeech = partOfSpeech
        self.definitions = definitions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.partOfSpeech = try container.decode(String.self, forKey: .partOfSpeech)
        self.definitions = try container.decode([DictionaryDefinition].self, forKey: .definitions)
        self.id = UUID()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(partOfSpeech, forKey: .partOfSpeech)
        try container.encode(definitions, forKey: .definitions)
    }
}

struct DictionaryDefinition: Codable, Identifiable {
    let id: UUID
    let definition: String
    let example: String?

    enum CodingKeys: String, CodingKey {
        case definition, example
    }

    init(id: UUID = UUID(), definition: String, example: String?) {
        self.id = id
        self.definition = definition
        self.example = example
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.definition = try container.decode(String.self, forKey: .definition)
        self.example = try container.decodeIfPresent(String.self, forKey: .example)
        self.id = UUID()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(definition, forKey: .definition)
        try container.encodeIfPresent(example, forKey: .example)
    }
}
