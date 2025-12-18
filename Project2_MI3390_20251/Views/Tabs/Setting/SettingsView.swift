//
//  SettingsView 2.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 18/12/25.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - ViewModel
    // Dùng @StateObject vì View này sở hữu (tạo ra) ViewModel
    @StateObject private var viewModel = SettingsViewModel()
    
    // MARK: - Properties (Settings UI)
    // Section Trải nghiệm
    @AppStorage("isDarkMode") private var isDarkMode = false // Dark mode
    @AppStorage("enableNotifications") private var enableNotifications = true // Notification
    
    // Section Âm thanh
    @AppStorage("soundEffects") private var isSoundEffectsOn = true    // Sound Effect
    @AppStorage("backgroundMusic") private var isMusicOn = false       // Music
    @AppStorage("musicVolume") private var musicVolume = 0.5    // Volome
    
    // Tagget Study
    @AppStorage("dailyTarget") private var dailyTarget = 10
    
    @State private var showingResetAlert = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Giao diện & Trải nghiệm
                Section(header: Text("Trải nghiệm")) {
                    Toggle("Chế độ tối (Dark Mode)", isOn: $isDarkMode)
                    Toggle("Nhận thông báo nhắc nhở", isOn: $enableNotifications)
                }

                // 2. Section Âm thanh
                Section(header: Text("Âm thanh")) {
                    // Toggle Hiệu ứng đơn giản
                    Toggle("Hiệu ứng âm thanh", isOn: $isSoundEffectsOn)
                    
                    // Group Nhạc nền + Slider
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("Nhạc nền", isOn: $isMusicOn)
                        
                        if isMusicOn {
                            HStack {
                                // Icon loa nhỏ
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(.secondary)
                                
                                // Slider điều chỉnh volume
                                Slider(value: $musicVolume, in: 0...1) {
                                    Text("Âm lượng") // Label cho VoiceOver (Accessibility)
                                }
                                
                                // Icon loa to
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.secondary)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top))) // Animation mượt
                        }
                    }
                    .padding(.vertical, 4) // Tinh chỉnh khoảng cách cho đẹp hơn trong Form
                }
                
                // Section 3: Cấu hình học tập
                Section(header: Text("Mục tiêu học tập")) {
                    Stepper("Mục tiêu: \(dailyTarget) từ/ngày", value: $dailyTarget, in: 5...50, step: 5)
                }
                
                // Section 4: Quản lý dữ liệu
                Section(header: Text("Dữ liệu")) {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("Reset toàn bộ tiến độ", systemImage: "trash")
                    }
                }
                
                // Section 5: Thông tin App
                Section(header: Text("Thông tin")) {
                    HStack {
                        Text("Phiên bản")
                        Spacer()
                        Text(Bundle.main.fullAppVersion)
                            .foregroundColor(.secondary)
                    }
                    Link("Liên hệ tác giả", destination: URL(string: "https://www.facebook.com/quanganh.2405/")!)
                }
            }
            .navigationTitle("Cài đặt")
            .alert("Cảnh báo", isPresented: $showingResetAlert) {
                Button("Hủy", role: .cancel) { }
                Button("Xóa hết", role: .destructive) {
                    viewModel.resetAllProgress()
                }
            } message: {
                Text("Hành động này không thể hoàn tác. Toàn bộ lịch sử học sẽ bị xóa.")
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}


// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

