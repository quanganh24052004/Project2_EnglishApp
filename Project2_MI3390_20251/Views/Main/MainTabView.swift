//
//  TabView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .review
    
    var body: some View {
        // --- 4 Tab chính ---
        TabView(selection: $selectedTab) {
            Tab(AppTab.review.title, systemImage: AppTab.review.icon, value: .review) {
                ReviewView()
            }
                        
            Tab(AppTab.learn.title, systemImage: AppTab.learn.icon, value: .learn) {
                LearnView()
            }
            
            Tab(AppTab.profile.title, systemImage: AppTab.profile.icon, value: .profile) {
                ProfileView()
            }
            
            Tab(AppTab.settings.title, systemImage: AppTab.settings.icon, value: .settings) {
                SettingsView()
            }
            

            
            Tab(AppTab.search.title, systemImage: AppTab.search.icon, value: .search, role: .search) {
                SearchView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)

    }
}

#Preview {
    MainTabView()
}
