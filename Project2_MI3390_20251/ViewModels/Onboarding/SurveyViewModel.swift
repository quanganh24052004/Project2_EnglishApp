//
//  SurveyViewModel.swift
//  OnboardingApp
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//


import SwiftUI
import Combine
class SurveyViewModel: ObservableObject {
    @Published var questions: [SurveyQuestion] = SurveyQuestion.samples
    @Published var currentIndex: Int = 0
    
    @Published var userAnswers: [UUID: Set<UUID>] = [:]
    
    var canProceed: Bool {
        let currentQ = questions[currentIndex]
        let answers = userAnswers[currentQ.id] ?? []
        return !answers.isEmpty
    }
    
    func selectOption(_ option: SurveyOption, in question: SurveyQuestion) {
        var currentSelected = userAnswers[question.id] ?? Set<UUID>()
        
        if question.type == .singleSelect {
            currentSelected = [option.id]
        } else {
            if currentSelected.contains(option.id) {
                currentSelected.remove(option.id)
            } else {
                currentSelected.insert(option.id)
            }
        }
        
        userAnswers[question.id] = currentSelected
    }
    
    func isSelected(_ option: SurveyOption, in question: SurveyQuestion) -> Bool {
        let currentSelected = userAnswers[question.id] ?? Set<UUID>()
        return currentSelected.contains(option.id)
    }
    
    func nextStep(onFinish: () -> Void) {
        if currentIndex < questions.count - 1 {
            withAnimation {
                currentIndex += 1
            }
        } else {
            submitData()
            onFinish()
        }
    }
    func submitData() {
        if let jsonResult = exportSurveyData() {
            print("----- DỮ LIỆU ĐÃ TRÍCH XUẤT (JSON) -----")
            print(jsonResult)
            
            // TODO: Tại đây bạn có thể:
            saveToLocal(jsonString: jsonResult)
        }
    }
}

extension SurveyViewModel {
    
    func exportSurveyData() -> String? {
        
        var submissionList: [SurveySubmission] = []
        
        for (questionID, answerIDs) in userAnswers {
            if let question = questions.first(where: { $0.id == questionID }) {
                
                let selectedTexts = question.options
                    .filter { answerIDs.contains($0.id) }
                    .map { $0.text }
                
                let submission = SurveySubmission(
                    question: question.text,
                    answer: selectedTexts
                )
                submissionList.append(submission)
            }
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Format cho đẹp dễ đọc
        
        do {
            let jsonData = try encoder.encode(submissionList)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            print("Lỗi encode JSON: \(error)")
            return nil
        }
    }
    

    // Ví dụ lưu vào máy người dùng
    private func saveToLocal(jsonString: String) {
        UserDefaults.standard.set(jsonString, forKey: "UserSurveyResult")
        print("Đã lưu kết quả vào bộ nhớ máy!")
    }
}
