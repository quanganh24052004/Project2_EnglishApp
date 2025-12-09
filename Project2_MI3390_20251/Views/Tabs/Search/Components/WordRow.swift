//
//  WordRow.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//
import SwiftUI

struct WordRow: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(word.english)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                // 2. Phiên âm (phonetic)
                Text(word.phonetic)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 3. Loại từ (partOfSpeech)
                Text("(\(word.partOfSpeech))")
                    .font(.caption2)
                    .italic()
                    .foregroundColor(.gray)
            }
            
            // 4. Hiển thị nghĩa (lấy từ mảng meanings)
            if let firstMeaning = word.meanings.first {
                Text(firstMeaning.vietnamese) // Model dùng 'vietnamese', không phải 'definition'
                    .font(.body)
                
                // 5. Ví dụ (exampleEn)
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
