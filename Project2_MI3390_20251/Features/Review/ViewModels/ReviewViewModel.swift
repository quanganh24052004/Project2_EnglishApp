//
//  ReviewViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//

import SwiftUI
import SwiftData
import AVFoundation
import Combine
import Supabase
import Observation

@Observable
@MainActor
class ReviewViewModel {
    // MARK: - Properties
    private var modelContext: ModelContext
    private var learningManager: LearningManager
    
    // Dữ liệu cho Dashboard Review
    var studyRecords: [StudyRecord] = []
    var currentTime: Date = Date()
    
    // Dữ liệu hiển thị phiên học
    var questions: [ReviewQuestion] = []
    var currentIndex: Int = 0
    var progress: Double = 0.0
    
    // Trạng thái phiên học
    var isLoading: Bool = true
    var isSessionCompleted: Bool = false
    
    // Inputs của User (Binding với View)
    var selectedOptionID: UUID? = nil // Cho trắc nghiệm
    var textInput: String = ""        // Cho Typing
    var spellingInput: [String] = []  // Cho Spelling
    
    // Kết quả check
    var showResult: Bool = false
    var isLastAnswerCorrect: Bool = false
    var currentFeedbackMessage: String = ""
    
    // Cache StudyRecord để update sau khi trả lời
    private var currentStudyRecord: StudyRecord? {
        guard currentIndex < questions.count else { return nil }
        // Trick: Ta cần map ngược từ Question về StudyRecord
        // Cách tốt nhất: Lưu map [QuestionID: StudyRecord] hoặc tìm trong list gốc
        let currentQ = questions[currentIndex]
        return reviewMap[currentQ.id]
    }
    
    // Dictionary để map câu hỏi về Record gốc (để update DB)
    private var reviewMap: [UUID: StudyRecord] = [:]
    
    // MARK: - Computed Properties for Dashboard
    
    var dueRecords: [StudyRecord] {
        return studyRecords.filter { $0.nextReview <= currentTime }
    }
    
    var nextReviewDate: Date? {
        return studyRecords
            .filter { $0.nextReview > currentTime }
            .map { $0.nextReview }
            .min()
    }
    
    var upcomingCount: Int {
        guard let nextDate = nextReviewDate else { return 0 }
        let windowEnd = nextDate.addingTimeInterval(60 * 60)
        return studyRecords.filter { record in
            return record.nextReview >= nextDate && record.nextReview <= windowEnd
        }.count
    }
    
    var levelStats: [LevelStat] {
        var counts = [Int](repeating: 0, count: 6)
        for record in studyRecords {
            let level = min(max(record.memoryLevel, 0), 5)
            counts[level] += 1
        }
        return [
            LevelStat(level: "0", count: counts[0], color: .gray),
            LevelStat(level: "1", count: counts[1], color: .red.opacity(0.8)),
            LevelStat(level: "2", count: counts[2], color: .yellow),
            LevelStat(level: "3", count: counts[3], color: .cyan),
            LevelStat(level: "4", count: counts[4], color: .blue),
            LevelStat(level: "5", count: counts[5], color: .purple)
        ]
    }
    
    // MARK: - Init
    init(modelContext: ModelContext, learningManager: LearningManager) {
        self.modelContext = modelContext
        self.learningManager = learningManager
    }
    
    // MARK: - Dashboard Actions
    
    func updateCurrentTime() {
        self.currentTime = Date()
    }
    
    func loadDashboardData(currentUser: Auth.User?) {
        let userID = currentUser?.id.uuidString ?? "guest_user_id"
        let descriptor = FetchDescriptor<StudyRecord>(
            predicate: #Predicate { $0.user?.id == userID }
        )
        do {
            self.studyRecords = try modelContext.fetch(descriptor)
        } catch {
            print("❌ Dashboard Load Error: \(error)")
            self.studyRecords = []
        }
    }
    
    // MARK: - 1. Load Data & Generate Questions
    func loadReviewSession(currentUser: Auth.User?) {
        isLoading = true
        let currentUserID = currentUser?.id.uuidString ?? "guest_user_id"
        
        do {
            // A. Lấy các từ đến hạn VÀ thuộc về User này
            let now = Date()
            
            let descriptor = FetchDescriptor<StudyRecord>(
                predicate: #Predicate { record in
                    record.nextReview <= now && record.user?.id == currentUserID
                },
                sortBy: [SortDescriptor(\.nextReview)]
            )
            
            let dueRecords = try modelContext.fetch(descriptor)
            
            if dueRecords.isEmpty {
                self.questions = []
                self.isLoading = false
                return
            }
            
            // B. Lấy pool từ vựng (Distractors)
            let allWordsDescriptor = FetchDescriptor<Word>()
            let allWords = try modelContext.fetch(allWordsDescriptor)
            
            var generatedQuestions: [ReviewQuestion] = []
            
            // C. Sinh câu hỏi
            for record in dueRecords {
                guard let targetWord = record.word else { continue }
                
                let type = determineQuestionType(level: record.memoryLevel)
                
                let distractors = Array(allWords
                    .filter { $0.english != targetWord.english }
                    .shuffled()
                    .prefix(3))
                
                if let question = ReviewQuestion.create(type: type, target: targetWord, distractors: distractors) {
                    generatedQuestions.append(question)
                    reviewMap[question.id] = record
                }
            }
            
            self.questions = generatedQuestions.shuffled()
            self.isLoading = false
            
        } catch {
            print("❌ Error loading review session: \(error)")
            self.isLoading = false
        }
    }
    
    // MARK: - 2. Logic Chọn Loại Câu Hỏi (Adaptive)
    private func determineQuestionType(level: Int) -> ReviewQuestionType {
        // Tỷ lệ random để tránh nhàm chán (30% cơ hội nhận câu hỏi ngẫu nhiên bất kể level)
        if Bool.random() && Bool.random() { // ~25% chance
            return ReviewQuestionType.allCases.randomElement()!
        }
        
        switch level {
        case 0...1: // Mới học -> Thiên về Nghe & Chọn
            return [.listenAndChooseWord, .listenAndChooseMeaning, .chooseWordFromContext].randomElement()!

        case 2...3: // Đang nhớ -> Thiên về Điền từ (Spelling)
            return [.fillInTheBlank, .translateAndFill, .chooseMeaningFromContext].randomElement()!
            
        case 4...5: // Thành thạo -> Thiên về Gõ (Typing) & Nghe khó
            return [.listenAndWrite, .listenToAudioChooseMeaning, .fillInTheBlank].randomElement()!
            
        default:
            return .listenAndChooseWord
        }
    }
    
    // MARK: - 3. Check Answer & Navigation
    func checkAnswer() {
        guard currentIndex < questions.count else { return }
        let currentQ = questions[currentIndex]
        
        // Logic so sánh đáp án
        var isCorrect = false
        
        switch currentQ.type {
        case .listenAndChooseWord, .listenAndChooseMeaning, .chooseWordFromContext,
             .chooseMeaningFromContext, .listenToAudioChooseMeaning:
            // Trắc nghiệm: So sánh selectedOptionID với Option đúng
            if let selectedID = selectedOptionID,
               let option = currentQ.options.first(where: { $0.id == selectedID }) {
                isCorrect = option.isCorrect
            }
            
        case .fillInTheBlank, .translateAndFill:
            // Spelling: Join mảng ký tự lại
            let userAnswer = spellingInput.joined()
            isCorrect = userAnswer.caseInsensitiveCompare(currentQ.correctAnswer) == .orderedSame
            
        case .listenAndWrite:
            // Typing: So sánh string (bỏ khoảng trắng thừa)
            let cleanInput = textInput.trimmingCharacters(in: .whitespacesAndNewlines)
            isCorrect = cleanInput.caseInsensitiveCompare(currentQ.correctAnswer) == .orderedSame
        }
        
        // Cập nhật State hiển thị
        self.isLastAnswerCorrect = isCorrect
        self.showResult = true
        self.currentFeedbackMessage = isCorrect ? "Chính xác! 🎉" : "Đáp án đúng: \(currentQ.correctAnswer)"
        
        // QUAN TRỌNG: Cập nhật DB qua LearningManager
        if let record = currentStudyRecord {
            learningManager.processReviewResult(for: record, isCorrect: isCorrect)
        }
        
        // Play sound feedback (Optional)
        if isCorrect {
            // AudioService.shared.playCorrectSound()
        } else {
            // AudioService.shared.playIncorrectSound()
        }
    }
    
    func nextQuestion() {
        if currentIndex < questions.count - 1 {
            withAnimation {
                currentIndex += 1
                progress = Double(currentIndex) / Double(questions.count)
            }
            resetInputState()
        } else {
            // Kết thúc phiên
            progress = 1.0
            isSessionCompleted = true
        }
    }
    
    // Reset inputs cho câu mới
    private func resetInputState() {
        selectedOptionID = nil
        textInput = ""
        spellingInput = []
        showResult = false
        isLastAnswerCorrect = false
    }
}

extension ReviewQuestion {
    // Hàm Factory: Tạo câu hỏi dựa trên Từ vựng + Loại câu hỏi + Danh sách từ gây nhiễu (distractors)
    static func create(type: ReviewQuestionType, target: Word, distractors: [Word]) -> ReviewQuestion? {
        // Lấy nghĩa đầu tiên (hoặc random) để làm đề bài
        guard let mainMeaning = target.meanings.first else { return nil }
        
        let answerEnglish = target.english
        let answerVietnamese = mainMeaning.vietnamese
        let exampleEn = mainMeaning.exampleEn
        
        // Helper: Tạo câu khuyết từ (thay từ target bằng ____)
        // Lưu ý: Cần xử lý case-insensitive và punctuation trong thực tế
        let clozeSentence = exampleEn.replacingOccurrences(of: target.english, with: "________", options: [.caseInsensitive, .literal])
        
        var promptText: String? = nil
        var audioUrl: String? = nil
        var highlighted: String? = nil
        var options: [ReviewOption] = []
        var finalAnswer = answerEnglish // Mặc định đáp án là từ tiếng Anh
        
        switch type {
            
        // 1. Nghe và chọn đáp án đúng (Context: Câu khuyết -> Option: 4 Audio)
        case .listenAndChooseWord:
            promptText = clozeSentence
            // Tạo options là các Audio của các từ khác
            options = ReviewQuestion.generateOptions(correct: target, wrong: distractors) { w in w.audioUrl } // Hoặc dùng TTS text
            
        // 2. Điền từ (Context: Câu khuyết -> Option: Spelling)
        case .fillInTheBlank:
            promptText = clozeSentence
            // Không cần options, View tự lấy scrambledCharacters
            
        // 3. Nghe và viết lại (Context: Audio -> Option: Typing)
        case .listenAndWrite:
            audioUrl = target.audioUrl
            
        // 4. Điền từ (Context: Nghĩa Việt -> Option: Spelling)
        case .translateAndFill:
            promptText = answerVietnamese
            
        // 5. Chọn từ thích hợp (Context: Câu khuyết -> Option: 4 Text English)
        case .chooseWordFromContext:
            promptText = clozeSentence
            options = ReviewQuestion.generateOptions(correct: target, wrong: distractors) { w in w.english }
            
        // 6. Nghe và chọn đáp án (Context: Nghĩa Việt -> Option: 4 Audio)
        case .listenAndChooseMeaning:
            promptText = answerVietnamese
            options = ReviewQuestion.generateOptions(correct: target, wrong: distractors) { w in w.audioUrl }
            
        // 7. Chọn nghĩa của từ gạch chân (Context: Câu full -> Option: 4 Nghĩa Việt)
        case .chooseMeaningFromContext:
            promptText = exampleEn // Hiển thị cả câu đầy đủ
            highlighted = target.english // View sẽ gạch chân từ này
            finalAnswer = answerVietnamese // Đáp án lúc này là tiếng Việt
            // Lưu ý: distractors ở đây phải lấy nghĩa tiếng Việt của các từ sai
            options = ReviewQuestion.generateOptions(correct: target, wrong: distractors) { w in w.meanings.first?.vietnamese ?? "N/A" }
            
        // 8. Nghe chọn đáp án (Context: Audio -> Option: 4 Nghĩa Việt)
        case .listenToAudioChooseMeaning:
            audioUrl = target.audioUrl
            finalAnswer = answerVietnamese
            options = ReviewQuestion.generateOptions(correct: target, wrong: distractors) { w in w.meanings.first?.vietnamese ?? "N/A" }
        }
        
        return ReviewQuestion(
            type: type,
            word: target,
            promptText: promptText,
            audioUrl: audioUrl,
            highlightedWord: highlighted,
            correctAnswer: finalAnswer,
            options: options,
            targetWord: target
        )
    }
    
    // Hàm helper sinh Options ngẫu nhiên
    private static func generateOptions(correct: Word, wrong: [Word], contentExtractor: (Word) -> String) -> [ReviewOption] {
        var opts = [ReviewOption(content: contentExtractor(correct), isCorrect: true, originalWord: correct)]
        
        // Lấy 3 từ sai, đảm bảo không trùng
        let shuffledWrong = wrong.shuffled().prefix(3)
        for w in shuffledWrong {
            opts.append(ReviewOption(content: contentExtractor(w), isCorrect: false, originalWord: w))
        }
        
        return opts.shuffled()
    }
}
