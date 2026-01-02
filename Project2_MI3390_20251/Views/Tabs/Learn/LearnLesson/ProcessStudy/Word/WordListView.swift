//
//  WordListView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 31/12/25.
//


import SwiftUI
import SwiftData

struct WordListView: View {
    @State private var isLearningSessionActive: Bool = false
    let lesson: Lesson
    
    var body: some View {
        List {
            ForEach(lesson.words) { word in
                WordRow(word: word)
            }
        }
        .navigationTitle(lesson.name)
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    if !lesson.words.isEmpty {
                        isLearningSessionActive = true
                    }
                }) {
                    Text("Learn now")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .disabled(lesson.words.isEmpty)
            }
        }
        
        .fullScreenCover(isPresented: $isLearningSessionActive) {
            let learningItems = lesson.words.map { word in
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
}
