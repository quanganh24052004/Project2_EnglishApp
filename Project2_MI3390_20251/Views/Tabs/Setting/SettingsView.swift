//
//  SettingsView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - ViewModel & Environment
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var languageManager: LanguageManager
    
    // MARK: - AppStorage (Lưu cấu hình đơn giản)
    // General
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Audio
    @AppStorage("soundEffects") private var isSoundEffectsOn = true
    @AppStorage("backgroundMusic") private var isMusicOn = false
    @AppStorage("musicVolume") private var musicVolume = 0.5
    
    // Study Target
    @AppStorage("dailyTarget") private var dailyTarget = 10
    
    // MARK: - UI State
    // Chỉ còn giữ lại Alert cho việc Reset dữ liệu
    @State private var showingResetAlert = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                languageSection
                experienceSection
                audioSection
                studyTargetSection
                dataSection
                aboutSection
            }
            .navigationTitle("Setting")
            
            // --- XỬ LÝ LOGIC (Chỉ còn mỗi cái này) ---
            
            // Alert Reset dữ liệu
            .alert("Warning", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete all", role: .destructive) { viewModel.resetAllProgress() }
            } message: {
                Text("This action cannot be undone.")
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// MARK: - Subviews (Tách nhỏ để code gọn)
private extension SettingsView {
    
    var languageSection: some View {
        Section(header: Text("Language")) {
            Picker("Select Language", selection: $languageManager.currentLanguage) {
                Text("English").tag("en")
                Text("Vietnamese").tag("vi")
            }
            .pickerStyle(.menu)
        }
    }
    
    var experienceSection: some View {
        Section(header: Text("Experience")) {
            Toggle("Dark mode", isOn: $isDarkMode)
        }
    }
    
    var audioSection: some View {
        Section(header: Text("Sound")) {
            Toggle("Sound effect", isOn: $isSoundEffectsOn)
            
            VStack(alignment: .leading) {
                Toggle("Background music", isOn: $isMusicOn)
                if isMusicOn {
                    HStack {
                        Image(systemName: "speaker.fill").foregroundColor(.secondary)
                        Slider(value: $musicVolume, in: 0...1)
                        Image(systemName: "speaker.wave.3.fill").foregroundColor(.secondary)
                    }
                    .transition(.opacity)
                }
            }
        }
    }
    
    var studyTargetSection: some View {
        Section(header: Text("Learning goals")) {
            Stepper("Target: \(dailyTarget) word/day", value: $dailyTarget, in: 5...50, step: 5)
        }
    }
    
    var dataSection: some View {
        Section(header: Text("Data")) {
            Button(role: .destructive) {
                showingResetAlert = true
            } label: {
                Label("Reset the entire progress", systemImage: "trash")
            }
        }
    }
    
    var aboutSection: some View {
        Section(header: Text("Information")) {
            HStack {
                Text("Version")
                Spacer()
                // Dùng extension Bundle nếu có, hoặc dùng code trực tiếp này cho nhanh
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .foregroundColor(.secondary)
            }
            Link("Connect author", destination: URL(string: "https://github.com/yourusername")!)
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LanguageManager())
    }
}
