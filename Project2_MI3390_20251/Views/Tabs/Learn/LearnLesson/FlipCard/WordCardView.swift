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
                        .font(.system(size: 28, weight: .bold))
                    
                    Text(item.phonetic) // Word.phonetic
                        .font(.system(size: 20))
                    
                    Divider()
                        .frame(width: 150)
                    
                    Text(item.partOfSpeech) // Word.partOfSpeech
                        .font(.system(size: 18, weight: .semibold))
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text(item.vietnamese) // Meaning: vietnamese
                        .font(.system(size: 18, weight: .regular))
                }
            }

        } back: {
            // MARK: - BACK CARD
            cardFace(color: .white) {
                VStack(spacing: 20) {
                    Text(item.word) // Word.English
                        .font(.system(size: 32, weight: .bold))
                    
                    Text(highlightedExample(sentence: item.example, target: item.word))
                        .font(.system(size: 20, weight: .light))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .onTapGesture {
            isFlipped.toggle()
        }
    }
    
    // Helper tạo khung thẻ
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
        // BƯỚC 1: Tạo môi trường SwiftData ảo (In-Memory)
        // Việc này giúp tạo ra ID hợp lệ mà không cần database thật
        let schema = Schema([PreviewStubEntity.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        
        // BƯỚC 2: Tạo một object giả và insert vào context để nó sinh ra ID
        let mockEntity = PreviewStubEntity()
        container.mainContext.insert(mockEntity)
        
        // BƯỚC 3: Trả về LearningItem với cái ID thật vừa lấy được
        return LearningItem(
            wordID: mockEntity.id,
            word: "Serendipity",
            phonetic: "/ˌser.ənˈdɪp.ə.ti/",
            partOfSpeech: "noun",
            meaning: "Sự tình cờ may mắn",
            example: "Finding this shop was pure serendipity.",
            audioUrl: nil,
            vietnamese: "Sự may mắn tình cờ"
        )
    }
}

//#Preview {
//    ZStack {
//        Color(UIColor.systemGroupedBackground)
//            .ignoresSafeArea()
//        
//        WordCardView(item: LearningItem.dummy)
//    }
//}
