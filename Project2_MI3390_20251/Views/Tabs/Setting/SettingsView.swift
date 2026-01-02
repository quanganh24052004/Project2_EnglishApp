//
//  SettingsView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    // MARK: - ViewModel & Environment
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - AppStorage (Lưu cấu hình đơn giản)
    @AppStorage("soundEffects") private var isSoundEffectsOn = true
    @AppStorage("musicVolume") private var musicVolume = 0.5
    
    @AppStorage("dailyTarget") private var dailyTarget = 10
    
    // MARK: - UI State
    @State private var showingResetAlert = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                languageSection
                audioSection
                studyTargetSection
                dataSection
                aboutSection
            }
            .navigationTitle(languageManager.currentLanguage == "vi" ? "Cài đặt" : "Settings")
                        
            .alert("Đặt lại tiến độ?", isPresented: $showingResetAlert) {
                Button("Hủy", role: .cancel) { }
                Button("Xóa tất cả", role: .destructive) {
                    viewModel.resetAllProgress(modelContext: modelContext)
                }
            } message: {
                Text("Hành động này sẽ xóa toàn bộ lịch sử học tập, từ vựng đã lưu và đưa ứng dụng về trạng thái ban đầu. Bạn không thể hoàn tác.")
            }
        }
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
    
    var audioSection: some View {
        Section(header: Text("Sound")) {
            Toggle("Sound effect", isOn: $isSoundEffectsOn)
            
            VStack(alignment: .leading) {
                Toggle("Background music", isOn: $viewModel.isMusicEnabled)
                .onChange(of: viewModel.isMusicEnabled) { oldValue, newValue in
                    if newValue {
                        AudioManager.shared.playBackgroundMusic()
                    } else {
                        AudioManager.shared.stopBackgroundMusic()
                    }
                }
            }
            if viewModel.isMusicEnabled {
            VStack(alignment: .leading) {
                Text("Âm lượng: \(Int(viewModel.musicVolume * 100))%")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Slider(value: $viewModel.musicVolume, in: 0.0...1.0, step: 0.05)
                        // THÊM: Cập nhật volume ngay khi kéo thanh trượt
                        .onChange(of: viewModel.musicVolume) { oldValue, newValue in
                            AudioManager.shared.setVolume(Float(newValue))
                        }
                    
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            .padding(.vertical, 5)
            }
        }
    }
    
    var studyTargetSection: some View {
        Section(header: Text("Learning goals")) {
            Stepper("Target: \(dailyTarget) word/day", value: $dailyTarget, in: 5...50, step: 5)
        }
    }
    
    var dataSection: some View {
        Section(header: Text("Dữ liệu")) {
            Button(role: .destructive) {
                showingResetAlert = true // Kích hoạt Alert
            } label: {
                Label("Reset toàn bộ tiến độ", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
    }
    
    var aboutSection: some View {
        Section(header: Text("Information")) {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .foregroundColor(.secondary)
            }
            Link("Connect author (Quang Anh)", destination: URL(string: "https://m.me/quanganh.2405")!)
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

