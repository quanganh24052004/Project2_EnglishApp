//
//  SearchView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import SwiftUI
import SwiftData

// 1. Định nghĩa Enum để quản lý chế độ tìm kiếm
enum SearchMode: String, CaseIterable, Identifiable {
    case local = "Handbook"
    case online = "Online"
    
    var id: String { self.rawValue }
    
    // Icon đại diện cho từng chế độ
    var iconName: String {
        switch self {
        case .local: return "internaldrive" // Icon ổ cứng/nội bộ
        case .online: return "globe"        // Icon quả địa cầu
        }
    }
}

struct SearchView: View {
    // --- Môi trường & SwiftData ---
    @Environment(\.modelContext) private var context
    
    // --- State Quản lý chung ---
    @State private var searchText = ""
    @State private var searchMode: SearchMode = .local // Mặc định tìm Local
    @State private var hasSearched = false
    
    // --- State cho Local Search ---
    @State private var localResults: [Word] = [] // (Giả sử model của bạn tên là Word)
    
    // --- State cho Online Search ---
    @State private var apiResults: [DictionaryEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                // Điều hướng giao diện dựa trên chế độ đang chọn
                switch searchMode {
                case .local:
                    localSearchContent
                case .online:
                    onlineSearchContent
                }
            }
            .navigationTitle(searchMode == .local ? "Look up Offline" : "Look up Online")
            .searchable(text: $searchText, placement: .automatic, prompt: searchMode == .local ? "Find it in the notebook..." : "Search online...")
            
            // Xử lý khi nhấn Enter/Search
            .onSubmit(of: .search) {
                if searchMode == .local {
                    performLocalSearch()
                } else {
                    Task { await performOnlineSearch() }
                }
            }
            // Reset khi xoá text hoặc đổi chế độ
            .onChange(of: searchText) { oldValue, newValue in
                if newValue.isEmpty { resetState() }
            }
            .onChange(of: searchMode) { oldValue, newValue in
                // Khi đổi chế độ tìm kiếm, xoá kết quả cũ đi cho đỡ rối
                resetState()
                searchText = ""
            }
            
            // --- TOOLBAR ---
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Menu cho phép chọn chế độ
                    Menu {
                        Picker("Search mode", selection: $searchMode) {
                            ForEach(SearchMode.allCases) { mode in
                                Label(mode.rawValue, systemImage: mode.iconName)
                                    .tag(mode)
                            }
                        }
                    } label: {
                        // Hiển thị icon của chế độ đang chọn
                        Image(systemName: searchMode.iconName)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
    
    // MARK: - Local Search View
    @ViewBuilder
        private var localSearchContent: some View {
            if !hasSearched {
                ContentUnavailableView("Look up Offline dictionary", systemImage: "book.closed", description: Text("Search in saved data."))
            } else if localResults.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List {
                    Section(header: Text("\(localResults.count) từ vựng trong bộ sưu tập")) {
                        ForEach(localResults) { word in
                            ZStack(alignment: .leading) {
                                WordRow(word: word)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    
    // MARK: - Online Search View
    @ViewBuilder
    private var onlineSearchContent: some View {
        if isLoading {
            ProgressView("Loading data...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
        } else if let error = errorMessage {
            ContentUnavailableView("Error", systemImage: "wifi.exclamationmark", description: Text(error))
        } else if !hasSearched {
            ContentUnavailableView("Look up online dictionary", systemImage: "globe", description: Text("Look up the detailed English definition."))
        } else if apiResults.isEmpty {
            ContentUnavailableView.search(text: searchText)
        } else {
            List(apiResults) { entry in
                VStack(alignment: .leading, spacing: 6) {
                    // --- HEADER: Word + Phonetic + Button ---
                    HStack(alignment: .center, spacing: 8) {
                        Text(entry.word)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        
                        if let phonetic = entry.phonetic {
                            Text(phonetic)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // --- NÚT LOA (Đồng bộ design) ---
                        Button(action: {
                            // Ưu tiên play link audio từ API nếu có, nếu không thì dùng TTS
                            // Ở đây dùng TTS theo yêu cầu của bạn cho đơn giản
                            AudioManager.shared.playTTS(text: entry.word)
                        }) {
                            Image(systemName: "speaker.wave.3.fill")
                        }
                        .buttonStyle(ThreeDCircleButtonStyle(
                            iconColor: .white,
                            backgroundColor: .orange,
                            size: 28
                        ))
                    }
                    .padding(.bottom, 4)
                    
                    Divider()
                        .foregroundColor(Color.orange.opacity(0.3))
                    
                    // --- MEANINGS LIST ---
                    ForEach(entry.meanings) { meaning in
                        VStack(alignment: .leading, spacing: 4) {
                            
                            // Style Badge cho Part of Speech (Đồng bộ)
                            Text(meaning.partOfSpeech)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(6)
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                            
                            ForEach(meaning.definitions.prefix(2)) { def in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundStyle(.secondary)
                                    Text(def.definition)
                                        .font(.system(size: 15, design: .rounded)) // Font rounded
                                        .foregroundStyle(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.bottom, 4)
                    }
                }
                .padding(.vertical, 6)
                .listRowSeparator(.hidden) // Ẩn dòng kẻ list mặc định cho đẹp hơn
            }
            .listStyle(.plain)
        }
    }
    
    // MARK: - Logic Functions
    
    private func resetState() {
        hasSearched = false
        localResults = []
        apiResults = []
        errorMessage = nil
        isLoading = false
    }
    
    private func performLocalSearch() {
        guard !searchText.isEmpty else { return }
        hasSearched = true
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let predicate = #Predicate<Word> { word in
            word.english.localizedStandardContains(query)
        }
        
        let descriptor = FetchDescriptor<Word>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.english)]
        )
        
        do {
            localResults = try context.fetch(descriptor)
        } catch {
            print("❌ Lỗi tìm kiếm local: \(error)")
        }
    }
    
    private func performOnlineSearch() async {
        guard !searchText.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        hasSearched = true
        apiResults = []
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        do {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let results = try await DictionaryService.shared.search(word: query)
            self.apiResults = results
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = "Không tìm thấy hoặc lỗi mạng."
        }
    }
}
