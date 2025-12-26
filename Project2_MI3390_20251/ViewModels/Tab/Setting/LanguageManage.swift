//
//  LanguageManege.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//

import Foundation
import Combine

class LanguageManager: ObservableObject {
    @Published var currentLanguage: String = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "vi" {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
        }
    }
}
