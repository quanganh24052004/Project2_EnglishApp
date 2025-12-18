//
//  LanguageManege.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//

import Foundation
import Combine

class LanguageManager: ObservableObject {
    // Lưu ngôn ngữ vào UserDefaults, mặc định là tiếng Anh ("en")
    @Published var currentLanguage: String = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en" {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
        }
    }
}
