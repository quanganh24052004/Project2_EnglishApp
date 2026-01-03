//
//  ReviewModels.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//

import Foundation

// MARK: - 1. Định nghĩa 8 loại câu hỏi
enum ReviewQuestionType: CaseIterable {
    // Nhóm 1: Nghe & Chọn
    case listenAndChooseWord        // 1
    case listenAndChooseMeaning     // 6
    case listenToAudioChooseMeaning // 8
    
    // Nhóm 2: Điền từ (Spelling/Typing)
    case fillInTheBlank             // 2
    case listenAndWrite             // 3
    case translateAndFill           // 4
    
    // Nhóm 3: Trắc nghiệm Từ vựng/Nghĩa
    case chooseWordFromContext      // 5
    case chooseMeaningFromContext   // 7
    
    // MARK: - Tiêu đề hiển thị (Computed Property)
    var title: String {
        switch self {
        case .listenAndChooseWord, .listenAndChooseMeaning, .listenToAudioChooseMeaning:
            return "Nghe và chọn đáp án đúng"
            
        case .fillInTheBlank:
            return "Điền từ vào chỗ trống"
            
        case .listenAndWrite:
            return "Nghe và viết lại"
            
        case .translateAndFill:
            return "Sắp xếp lại ký tự"
            
        case .chooseWordFromContext:
            return "Chọn từ thích hợp điền vào chỗ trống"
            
        case .chooseMeaningFromContext:
            return "Chọn nghĩa của từ được gạch chân"
        }
    }
}

// MARK: - 2. Model cho một lựa chọn (Option)
struct ReviewOption: Identifiable, Hashable {
    let id = UUID()
    let content: String       // Nội dung hiển thị (Text hoặc URL Audio tùy type)
    let isCorrect: Bool       // Đánh dấu đây là đáp án đúng
    let originalWord: Word?   // Tham chiếu ngược về Word (nếu cần play TTS cho option đó)
}

// MARK: - 3. Model cho một câu hỏi ôn tập
struct ReviewQuestion: Identifiable {
    let id = UUID()
    let type: ReviewQuestionType
    let word: Word
    // --- INPUT (Đề bài) ---
    let promptText: String?    // Câu ví dụ, Nghĩa tiếng Việt, hoặc Hint
    let audioUrl: String?      // URL Audio đề bài (cho loại 3, 8)
    let highlightedWord: String? // Từ cần gạch chân (cho loại 7)
    
    // --- OUTPUT (Đáp án) ---
    let correctAnswer: String  // Đáp án text đúng (để so sánh)
    let options: [ReviewOption] // Danh sách 4 lựa chọn (nếu là trắc nghiệm)
    
    // --- REFERENCE (Để update DB sau khi học xong) ---
    let targetWord: Word       // Từ vựng đang được học trong câu này
    
    // Helper: Lấy các ký tự xáo trộn cho Spelling (Loại 2, 4)
    var scrambledCharacters: [String] {
        return correctAnswer.map { String($0) }.shuffled()
    }
}



