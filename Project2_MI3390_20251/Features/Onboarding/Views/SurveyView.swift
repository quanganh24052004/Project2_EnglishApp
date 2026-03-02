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
    let shape = RoundedCorner(radius: 16, corners: [.topRight, .bottomLeft, .bottomRight])

    var body: some View {
        VStack(spacing: 0) {
            
            // Question
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(.imgHappy)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.primary01)
                        .padding(.top, 20)
                    
                    if viewModel.currentIndex < viewModel.questions.count {
                        
                        Text(viewModel.questions[viewModel.currentIndex].text)
                            .font(.system(size: 18, design: .rounded))
                            .fontWeight(.regular)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading) // Thêm dòng này để text căn trái đẹp hơn nếu câu hỏi dài
                            .background(Color("SecondaryBG")) // Đảm bảo tên màu trong Assets đúng
                            
                            // 2. Cắt nền theo shape
                            .clipShape(shape)
                            
                            // 3. Vẽ viền đè lên theo đúng shape đó
                            .overlay(
                                shape.stroke(Color.border, lineWidth: 2)
                            )
                            
                            // 4. Animation
                            .transition(.opacity.combined(with: .scale(scale: 0.95))) // Hiệu ứng mờ + phóng to nhẹ sẽ mượt hơn
                            .id("Question-\(viewModel.currentIndex)")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
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
                .buttonStyle(PrimaryPhysicalButtonStyle())
                .disabled(!viewModel.canProceed)
                .padding()
            }
        }
        .background(Color(.primaryBG))
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
