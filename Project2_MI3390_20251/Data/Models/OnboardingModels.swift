//
//  OnboardingModels.swift
//  OnboardingApp
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import Foundation

struct OnboardingData: Codable {
    let onboardingFlow: [OnboardingStep]
}

enum StepType: String, Codable {
    case intro
    case question
    case info
    case permission
    case outro
}

struct OnboardingStep: Codable, Identifiable {
    var id: Int { step }
    let step: Int
    let type: StepType
    
    // Fields specific to step types
    let mascotMessages: [String]?
    let questionText: String?
    let options: [OnboardingOption]?
    let title: String?
    let benefits: [OnboardingBenefit]?
    let permissionType: String?
    let message: String?
    let action: String?
}

struct OnboardingOption: Codable, Identifiable {
    let id: String
    let label: String
    let mascotResponse: String?
    let difficulty: String?
    let description: String?
}

struct OnboardingBenefit: Codable, Identifiable {
    var id: String { title }
    let title: String
    let description: String
}
