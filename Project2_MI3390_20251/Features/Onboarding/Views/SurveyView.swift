//
//  SurveyView.swift
//  OnboardingApp
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI
import UserNotifications

struct SurveyView: View {
    @StateObject private var viewModel = SurveyViewModel()
    @Binding var isOnboardingDone: Bool
    let shape = RoundedCorner(radius: 16, corners: [.topRight, .bottomLeft, .bottomRight])

    var body: some View {
        VStack(spacing: 0) {
            if let step = viewModel.currentStep {
                ScrollView {
                    VStack(spacing: 20) {
                        switch step.type {
                        case .intro, .outro:
                            IntroOutroStepView(step: step, shape: shape)
                        case .question:
                            QuestionStepView(step: step, viewModel: viewModel, shape: shape)
                        case .info:
                            InfoStepView(step: step)
                        case .permission:
                            PermissionStepView(step: step, shape: shape)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                VStack {
                    Button(action: {
                        viewModel.nextStep {
                            withAnimation {
                                isOnboardingDone = true
                            }
                        }
                    }) {
                        Text(viewModel.currentIndex == viewModel.steps.count - 1 ? "Hoàn thành" : "Tiếp tục")
                    }
                    .capyButton(.primary(color: CapyColors.green, shadow: CapyColors.greenShadow))
                    .disabled(!viewModel.canProceed)
                    .padding()
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.primaryBG))
    }
}

// MARK: - Step Views

struct IntroOutroStepView: View {
    let step: OnboardingStep
    let shape: RoundedCorner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let messages = step.mascotMessages {
                ForEach(Array(messages.enumerated()), id: \.offset) { index, msg in
                    HStack(alignment: .top, spacing: 10) {
                        Image(.imgHappy)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.primary01)
                        
                        Text(msg)
                            .font(.system(size: 18, design: .rounded))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.primaryBG)
                            .clipShape(shape)
                            .overlay(shape.stroke(Color.border, lineWidth: 2))
                    }
                    .padding(.horizontal)
                    // Optional animation to bring messages one by one
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .padding(.top, 40)
    }
}

struct QuestionStepView: View {
    let step: OnboardingStep
    @ObservedObject var viewModel: SurveyViewModel
    let shape: RoundedCorner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(.imgHappy)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.primary01)
                    .padding(.top, 20)
                
                if let questionText = step.questionText {
                    Text(questionText)
                        .font(.system(size: 18, design: .rounded))
                        .fontWeight(.regular)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.primaryBG)
                        .clipShape(shape)
                        .overlay(shape.stroke(Color.border, lineWidth: 2))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            if let options = step.options {
                VStack(spacing: 12) {
                    ForEach(options) { option in
                        SurveyOptionRow(
                            option: option,
                            isSelected: viewModel.isSelected(option, in: step)
                        ) {
                            withAnimation {
                                viewModel.selectOption(option, in: step)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct InfoStepView: View {
    let step: OnboardingStep
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(.imgHappy)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 40)
            
            if let title = step.title {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if let benefits = step.benefits {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(benefits) { benefit in
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 24))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(benefit.title)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Text(benefit.description)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding(20)
                .background(.primaryBG)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.border, lineWidth: 1))
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
    }
}

struct PermissionStepView: View {
    let step: OnboardingStep
    let shape: RoundedCorner
    @State private var requested = false
    
    var body: some View {
        VStack(spacing: 30) {
            if let message = step.message {
                HStack(alignment: .top, spacing: 10) {
                    Image(.imgHappy)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.primary01)
                    
                    Text(message)
                        .font(.system(size: 18, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.primaryBG)
                        .clipShape(shape)
                        .overlay(shape.stroke(Color.border, lineWidth: 2))
                }
                .padding(.horizontal)
                .padding(.top, 40)
            }
            
            Image(systemName: "bell.badge.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.yellow)
            
            if let action = step.action {
                Button(action: {
                    requestNotificationPermission()
                }) {
                    Text(requested ? "Đã yêu cầu quyền" : action)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(requested ? Color.gray.opacity(0.2) : Color.blue.opacity(0.1))
                        .foregroundColor(requested ? .gray : .blue)
                        .cornerRadius(12)
                }
                .disabled(requested)
                .padding(.horizontal)
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.requested = true
            }
            print("Quyền thông báo: \(granted)")
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
