//
//  WordCardView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//


import SwiftUI

struct WordCardView: View {
    let item: LearningItem 
    
    @Binding var isFlipped: Bool
    
    let cardHeight: CGFloat = 400
    
    var body: some View {
        FlipCardContainer(isFlipped: isFlipped) {
            // MARK: - FRONT CARD
            cardFace(color: .white) {
                VStack(spacing: 16) {
                    Text(item.word)
                        .font(.system(size: 28, design: .rounded))
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)


                    Text(item.phonetic)
                        .font(.system(size: 20, design: .rounded))
                        .padding(.horizontal)

                    Divider()
                        .frame(width: 150)
                    
                    Text(item.partOfSpeech)
                        .font(.system(size: 18, design: .rounded))
                        .fontWeight(.semibold)
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(16)

                    Text(item.vietnamese)
                        .font(.system(size: 18, design: .rounded))
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

        } back: {
            // MARK: - BACK CARD
            cardFace(color: .white) {
                VStack(spacing: 20) {
                    Text(item.word)
                        .font(.system(size: 28, design: .rounded))
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .padding(.horizontal)

                    Text(highlightedExample(sentence: item.example, target: item.word))
                        .font(.system(size: 20, design: .rounded))
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .onTapGesture {
            isFlipped.toggle()
        }
    }
    
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
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }
    
    // MARK: - Helper Logic: Gạch chân từ trong câu
    func highlightedExample(sentence: String, target: String) -> AttributedString {
        var attributedString = AttributedString(sentence)
        
        if let range = attributedString.range(of: target, options: .caseInsensitive) {
            attributedString[range].underlineStyle = .single
            attributedString[range].foregroundColor = .black //
            attributedString[range].font = .system(size: 20, weight: .semibold)
        }
        
        return attributedString
    }
}

// MARK: PREVIEW
import SwiftData
import Foundation

@Model
class PreviewStubEntity {
    var timestamp: Date
    init(timestamp: Date = Date()) { self.timestamp = timestamp }
}

extension LearningItem {
    static var dummy: LearningItem {
        let schema = Schema([PreviewStubEntity.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        
        let mockEntity = PreviewStubEntity()
        container.mainContext.insert(mockEntity)
        
        return LearningItem(
            wordID: mockEntity.id,
            word: "Serendipity",
            phonetic: "/ˌser.ənˈdɪp.ə.ti/",
            partOfSpeech: "noun",
            meaning: "Sự tình cờ may mắn",
            example: "Finding this shop was pure serendipity.",
            exampleVi: "aba",
            audioUrl: nil,
            vietnamese: "Sự may mắn tình cờ"
        )
    }
}

