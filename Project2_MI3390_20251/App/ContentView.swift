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
        // Dùng DispatchQueue.main.async để đảm bảo chạy sau khi View được tạo
                Text("Hello")
                    .onAppear {
                        DispatchQueue.main.async {
                            // Dùng UIKit API để in ra tất cả các font khả dụng
                            for family in UIFont.familyNames.sorted() {
                                let names = UIFont.fontNames(forFamilyName: family)
                                print("Family: \(family) | Names: \(names)")
                            }
                        }
                    }
                
                // Ví dụ: sử dụng font của bạn để test
                Text("Test Custom Font")
                    .font(.appFont(size: 20, weight: .bold))
    }
}
