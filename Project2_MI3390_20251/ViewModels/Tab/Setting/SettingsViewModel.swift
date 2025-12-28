//
//  SettingsViewModel.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//

import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @AppStorage("isMusicEnabled") var isMusicEnabled: Bool = true
    @AppStorage("musicVolume") var musicVolume: Double = 0.5
    // MARK: - Logic Reset Data
    func resetAllProgress() {
        print("ViewModel: Đã thực hiện lệnh xóa toàn bộ dữ liệu.")

    }
}
