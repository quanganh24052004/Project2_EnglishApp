//
//  WordRow.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//
import SwiftUI

struct WordRowSearch: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(word.english)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text(word.phonetic)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("(\(word.partOfSpeech))")
                    .font(.caption2)
                    .italic()
                    .foregroundColor(.gray)
            }
            
            if let firstMeaning = word.meanings.first {
                Text(firstMeaning.vietnamese) // Model dùng 'vietnamese', không phải 'definition'
                    .font(.body)
                
                if !firstMeaning.exampleEn.isEmpty {
                    Text("Ex: \(firstMeaning.exampleEn)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
