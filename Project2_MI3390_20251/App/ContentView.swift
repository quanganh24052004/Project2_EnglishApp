//
//  ContentView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @AppStorage("isOnboardingDone") var isOnboardingDone: Bool = false
    
    var body: some View {
        if isOnboardingDone {
            Text("Màn hình Trang chủ (Sau khi đã thu thập dữ liệu)")
        } else {
            SurveyView(isOnboardingDone: $isOnboardingDone)
        }
    }
}
