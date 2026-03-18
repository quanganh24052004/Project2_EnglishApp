//
//  WordListView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 31/12/25.
//


import SwiftUI
import SwiftData

struct WordListView: View {
    // MARK: - Properties
    
    @State private var isLearningSessionActive: Bool = false
    @State private var sortOption: WordSortOption = .alphabeticalAsc
    
    let lesson: Lesson
    
    // MARK: - Computed Properties
    
    private var sortedWords: [Word] {
        switch sortOption {
        case .alphabeticalAsc:
            return lesson.words.sorted(by: { $0.english.localizedStandardCompare($1.english) == .orderedAscending })
        case .alphabeticalDesc:
            return lesson.words.sorted(by: { $0.english.localizedStandardCompare($1.english) == .orderedDescending })
        case .partOfSpeech:
            return lesson.words.sorted(by: { $0.partOfSpeech.localizedStandardCompare($1.partOfSpeech) == .orderedAscending })
        case .shuffled:
            return lesson.words.shuffled()
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(sortedWords) { word in
                WordRow(word: word)
            }
        }
        .navigationTitle(lesson.name)
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    sortMenu
                    
                    Button(action: {
                        if !sortedWords.isEmpty {
                            isLearningSessionActive = true
                        }
                    }) {
                        Text("Learn now")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .disabled(sortedWords.isEmpty)
                }
            }
        }
        
        .fullScreenCover(isPresented: $isLearningSessionActive) {
            let learningItems = sortedWords.map { word in
                 LearningItem(
                    wordID: word.persistentModelID,
                    word: word.english,
                    phonetic: word.phonetic,
                    partOfSpeech: word.partOfSpeech,
                    meaning: word.meanings.first?.vietnamese ?? "",
                    example: word.meanings.first?.exampleEn ?? "",
                    exampleVi: word.meanings.first?.exampleVi ?? "",
                    audioUrl: word.audioUrl,
                    vietnamese: word.meanings.first?.vietnamese ?? ""
                )
            }
            LessonContainerView(items: learningItems)
        }
    }
    
    // MARK: - Components
    
    private var sortMenu: some View {
        Menu {
            Section("Sắp xếp từ vựng") {
                ForEach(WordSortOption.allCases, id: \.self) { option in
                    Button {
                        sortOption = option
                    } label: {
                        Label(option.displayName, systemImage: sortOption == option ? "checkmark" : option.iconName)
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
}

/// Các tuỳ chọn sắp xếp cho danh sách từ vựng
enum WordSortOption: String, CaseIterable {
    case alphabeticalAsc
    case alphabeticalDesc
    case partOfSpeech
    case shuffled
    
    var displayName: String {
        switch self {
        case .alphabeticalAsc: return "A -> Z"
        case .alphabeticalDesc: return "Z -> A"
        case .partOfSpeech: return "Từ loại"
        case .shuffled: return "Trộn ngẫu nhiên"
        }
    }
    
    var iconName: String {
        switch self {
        case .alphabeticalAsc, .alphabeticalDesc: return "textformat.abc"
        case .partOfSpeech: return "tag"
        case .shuffled: return "shuffle"
        }
    }
}
