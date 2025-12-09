//
//  TabView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        // Khởi tạo TabView
        SwiftUI.TabView(selection: $selectedTab) {
            
            // Màn hình 1
            Text("Màn hình Trang chủ")
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0) // Tag dùng để định danh tab này
            
            // Màn hình 2
            Text("Màn hình Cài đặt")
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(1)
            
            // Màn hình 3
            Text("Màn hình Cá nhân")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
        }
        // Thay đổi màu sắc của icon khi được chọn (tuỳ chọn)
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
