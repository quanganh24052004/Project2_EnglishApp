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
        Group {
            if #available(iOS 18.0, *) {
                // MARK: - Giao diện cho iOS 18+
                TabView(selection: $selectedTab) {
                    Tab(AppTab.review.title, systemImage: AppTab.review.icon, value: .review) {
                        ReviewView()
                    }
                    
                    Tab(value: .learn) {
                        LearnView()
                    } label: {
                        if selectedTab == .learn {
                            Image(systemName: AppTab.learn.selectedIcon)
                            Text(AppTab.learn.title)
                        } else {
                            Image(systemName: AppTab.learn.icon)
                            Text(AppTab.learn.title)
                        }
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
                .tint(.orange)
                
            } else {
                // MARK: - Giao diện cho iOS 17 trở xuống
                TabView(selection: $selectedTab) {
                    ReviewView()
                        .tabItem {
                            Label(AppTab.review.title, systemImage: AppTab.review.icon)
                        }
                        .tag(AppTab.review)
                    
                    LearnView()
                        .tabItem {
                            if selectedTab == .learn {
                                Label(AppTab.learn.title, systemImage: AppTab.learn.selectedIcon)
                            } else {
                                Label(AppTab.learn.title, systemImage: AppTab.learn.icon)
                            }
                        }
                        .tag(AppTab.learn)
                    
                    ProfileView()
                        .tabItem {
                            Label(AppTab.profile.title, systemImage: AppTab.profile.icon)
                        }
                        .tag(AppTab.profile)
                    
                    SettingsView()
                        .tabItem {
                            Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
                        }
                        .tag(AppTab.settings)
                    
                    SearchView()
                        .tabItem {
                            Label(AppTab.search.title, systemImage: AppTab.search.icon)
                        }
                        .tag(AppTab.search)
                }
                .accentColor(.orange)
            }
        }
    }
}

#Preview {
    MainTabView()
}
