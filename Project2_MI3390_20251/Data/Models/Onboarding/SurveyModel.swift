//
//  SurveyModel.swift
//  OnboardingApp
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import Foundation

// Loại câu hỏi
enum QuestionType {
    case singleSelect
    case multiSelect
}

// Cấu trúc một đáp án
struct SurveyOption: Identifiable, Hashable {
    let id: UUID = UUID()
    let iconName: String
    let text: String
}

// Cấu trúc một câu hỏi
struct SurveyQuestion: Identifiable {
    let id = UUID()
    let text: String
    let type: QuestionType
    let options: [SurveyOption]
}

struct SurveySubmission: Codable {
    let question: String
    let answer: [String]
}

// Dữ liệu mẫu (Mock Data dựa trên ảnh bạn gửi)
extension SurveyQuestion {
    static let samples: [SurveyQuestion] = [
        SurveyQuestion(
            text: "Kỳ thi tiếng Anh sắp tới của bạn là gì?",
            type: .singleSelect,
            options: [
                SurveyOption(iconName: "book.circle.fill", text: "IELTS"),
                SurveyOption(iconName: "graduationcap.circle.fill", text: "TOEIC"),
                SurveyOption(iconName: "doc.text.fill", text: "THPT"),
                SurveyOption(iconName: "ellipsis.circle.fill", text: "Chưa, mình chỉ học từ vựng thôi")
            ]
        ),
        SurveyQuestion(
            text: "Trình độ hiện tại của bạn là gì?",
            type: .singleSelect,
            options: [
                SurveyOption(iconName: "star.fill", text: "Mình mới bắt đầu học"),
                SurveyOption(iconName: "chart.bar.fill", text: "Trình độ cơ bản"),
                SurveyOption(iconName: "chart.line.uptrend.xyaxis", text: "Trình độ nâng cao")
            ]
        ),
        SurveyQuestion(
            text: "Mục tiêu của bạn là gì? (Có thể chọn nhiều)",
            type: .multiSelect,
            options: [
                SurveyOption(iconName: "airplane", text: "Du học / Định cư"),
                SurveyOption(iconName: "briefcase.fill", text: "Phát triển sự nghiệp"),
                SurveyOption(iconName: "gamecontroller.fill", text: "Để giải trí"),
                SurveyOption(iconName: "brain.head.profile", text: "Rèn luyện trí não")
            ]
        )
    ]
}
