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
    
    // Lưu trữ câu trả lời: [ID Câu hỏi : Tập hợp ID các đáp án đã chọn]
    @Published var userAnswers: [UUID: Set<UUID>] = [:]
    
    // Kiểm tra xem trang hiện tại đã chọn đáp án nào chưa để enable nút Tiếp tục
    var canProceed: Bool {
        let currentQ = questions[currentIndex]
        let answers = userAnswers[currentQ.id] ?? []
        return !answers.isEmpty
    }
    
    // Logic chọn đáp án
    func selectOption(_ option: SurveyOption, in question: SurveyQuestion) {
        var currentSelected = userAnswers[question.id] ?? Set<UUID>()
        
        if question.type == .singleSelect {
            // Nếu chọn 1: Xóa hết cái cũ, chọn cái mới
            currentSelected = [option.id]
        } else {
            // Nếu chọn nhiều: Nếu có rồi thì bỏ chọn, chưa có thì thêm vào
            if currentSelected.contains(option.id) {
                currentSelected.remove(option.id)
            } else {
                currentSelected.insert(option.id)
            }
        }
        
        userAnswers[question.id] = currentSelected
    }
    
    // Kiểm tra UI xem option này đang được chọn hay không
    func isSelected(_ option: SurveyOption, in question: SurveyQuestion) -> Bool {
        let currentSelected = userAnswers[question.id] ?? Set<UUID>()
        return currentSelected.contains(option.id)
    }
    
    // Xử lý nút Tiếp tục
    func nextStep(onFinish: () -> Void) {
        if currentIndex < questions.count - 1 {
            withAnimation {
                currentIndex += 1
            }
        } else {
            // Đã xong câu hỏi cuối cùng
            submitData()
            onFinish()
        }
    }
        // Cập nhật lại hàm submitData
    func submitData() {
        if let jsonResult = exportSurveyData() {
            print("----- DỮ LIỆU ĐÃ TRÍCH XUẤT (JSON) -----")
            print(jsonResult)
            
            // TODO: Tại đây bạn có thể:
            // 1. Gửi chuỗi này lên Server (API)
            // 2. Lưu vào UserDefaults để dùng sau này
            saveToLocal(jsonString: jsonResult)
        }
    }
}

extension SurveyViewModel {
    
    // Hàm chuyển đổi dữ liệu thô (UUID) thành dữ liệu đọc được (String/JSON)
    func exportSurveyData() -> String? {
        
        var submissionList: [SurveySubmission] = []
        
        // Duyệt qua từng câu hỏi đã trả lời
        for (questionID, answerIDs) in userAnswers {
            // 1. Tìm lại object câu hỏi gốc dựa trên ID
            if let question = questions.first(where: { $0.id == questionID }) {
                
                // 2. Tìm lại các text đáp án dựa trên tập hợp ID đáp án
                let selectedTexts = question.options
                    .filter { answerIDs.contains($0.id) }
                    .map { $0.text }
                
                // 3. Tạo object kết quả
                let submission = SurveySubmission(
                    question: question.text,
                    answer: selectedTexts
                )
                submissionList.append(submission)
            }
        }
        
        // 4. Chuyển đổi thành JSON String để gửi đi hoặc in ra
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
