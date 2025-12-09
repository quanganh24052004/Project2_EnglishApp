//
//  WordCardView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//


import SwiftUI

struct WordCardView: View {
    let item: LearningItem 
    
    @State private var isFlipped: Bool = false
    
    let cardHeight: CGFloat = 400
    
    var body: some View {
        FlipCardContainer(isFlipped: isFlipped) {
            // MARK: - FRONT CARD
            cardFace(color: Color(UIColor.systemGray6)) {
                VStack(spacing: 15) {
                    Text(item.word)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                    
                    Text(item.phonetic) // Word.phonetic
                        .font(.title3)
                        .italic()
                        .foregroundColor(.gray)
                    
                    Divider()
                        .frame(width: 100)
                    
                    Text(item.partOfSpeech) // Word.partOfSpeech
                        .font(.headline)
                        .padding(5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(5)
                    
                    Text(item.vietnamese) // Meaning: vietnamese
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }

        } back: {
            // MARK: - BACK CARD
            cardFace(color: .white) {
                VStack(spacing: 20) {
                    Text(item.word) // Word.English
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    // Hàm xử lý gạch chân text
                    Text(highlightedExample(sentence: item.example, target: item.word))
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            }
        }
        .onTapGesture {
            isFlipped.toggle()
        }
    }
    
    // Helper tạo khung thẻ (DRY - Don't Repeat Yourself)
    @ViewBuilder
    func cardFace<Content: View>(color: Color, @ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            
            content()
        }
        .frame(height: cardHeight) // Chiều cao thẻ
        .padding()
    }
    
    // MARK: - Helper Logic: Gạch chân từ trong câu
    func highlightedExample(sentence: String, target: String) -> AttributedString {
        var attributedString = AttributedString(sentence)
        
        // Tìm range của từ cần gạch chân (case insensitive)
        if let range = attributedString.range(of: target, options: .caseInsensitive) {
            attributedString[range].underlineStyle = .single
            attributedString[range].foregroundColor = .red // Highlight thêm màu đỏ cho rõ
            attributedString[range].font = .system(size: 20, weight: .bold)
        }
        
        return attributedString
    }
}
