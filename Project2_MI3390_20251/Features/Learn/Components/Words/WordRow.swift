//
//  WordRow.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 31/12/25.
//


import SwiftUI

struct WordRow: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                Text(word.english)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                Text(word.phonetic)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(word.partOfSpeech)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(6)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    AudioManager.shared.playTTS(text: word.english)
                }) {
                    Image(systemName: "speaker.wave.3.fill")
                }
                .buttonStyle(ThreeDCircleButtonStyle(
                    iconColor: .white,
                    backgroundColor: .orange,
                    size: 28,
                ))
            }
            .padding(.bottom, 4)
            Divider()
                .foregroundColor(Color.orange.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 6) {
                if let firstMeaning = word.meanings.first {
                    Text(firstMeaning.vietnamese)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    if !firstMeaning.exampleEn.isEmpty {
                        Text("\"\(firstMeaning.exampleEn)\"")
                            // 👇 Font Rounded, Italic, Size 13
                            .font(.system(size: 13, design: .rounded))
                            .italic()
                            .foregroundStyle(.secondary)
                            .padding(.top, 1)
                    }
                    
                    if !firstMeaning.exampleVi.isEmpty {
                        Text("\"\(firstMeaning.exampleVi)\"")
                            .font(.system(size: 13, design: .rounded))
                            .italic()
                            .foregroundStyle(.secondary)
                            .padding(.top, 1)
                    }
                } else {
                    Text("It's not meaningful yet")
                        .font(.system(size: 14, design: .rounded))
                        .italic()
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
