//
//  SurveyView.swift
//  OnboardingApp
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//


import SwiftUI

struct SurveyView: View {
    @StateObject private var viewModel = SurveyViewModel()
    @Binding var isOnboardingDone: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(.imgHappy)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.orange)
                        .padding(.top, 20)
                    
                    if viewModel.currentIndex < viewModel.questions.count {
                        Text(viewModel.questions[viewModel.currentIndex].text)
                            .font(.headline)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20, corners: [.topRight, .bottomLeft, .bottomRight])
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 2, y: 2)
                            .transition(.opacity) // Hiệu ứng mờ dần khi đổi câu hỏi
                            .id("Question-\(viewModel.currentIndex)") // 
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.primary01))
            
            ScrollView {
                VStack(spacing: 12) {
                    if viewModel.currentIndex < viewModel.questions.count {
                        let currentQuestion = viewModel.questions[viewModel.currentIndex]
                        
                        ForEach(currentQuestion.options) { option in
                            SurveyOptionRow(
                                option: option,
                                isSelected: viewModel.isSelected(option, in: currentQuestion)
                            ) {
                                viewModel.selectOption(option, in: currentQuestion)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.primary01))
            
            VStack {
                Button(action: {
                    viewModel.nextStep {
                        withAnimation {
                            isOnboardingDone = true
                        }
                    }
                }) {
                    Text(viewModel.currentIndex == viewModel.questions.count - 1 ? "Finish" : "Continue")
                }
                .buttonStyle(ThreeDButtonStyle(
                    color: viewModel.canProceed ? .pGreen : .gray
                ))
                .disabled(!viewModel.canProceed)
                .padding()
            }
            .background(Color(.primary01)) // Nền toàn màn hình
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
