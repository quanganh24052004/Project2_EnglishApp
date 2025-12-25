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
                Section(header: Text("\(localResults.count) Results in the machine")) {
                    ForEach(localResults) { word in
                        // Giả sử bạn có View hiển thị từ (WordRow)
                        // Nếu chưa có, thay bằng Text(word.english)
                        NavigationLink(destination: Text(word.english)) { // Demo destination
                            VStack(alignment: .leading) {
                                Text(word.english).font(.headline)
                                // Text(word.vietnamese).font(.subheadline) // Ví dụ
                            }
                        }
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
        } else if let error = errorMessage {
            ContentUnavailableView("Error", systemImage: "wifi.exclamationmark", description: Text(error))
        } else if !hasSearched {
            ContentUnavailableView("Look up online dictionary", systemImage: "globe", description: Text("Look up the detailed English definition."))
        } else if apiResults.isEmpty {
            ContentUnavailableView.search(text: searchText)
        } else {
            List(apiResults) { entry in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(entry.word).font(.headline).foregroundStyle(.blue)
                        if let phonetic = entry.phonetic {
                            Text(phonetic).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    
                    ForEach(entry.meanings) { meaning in
                        VStack(alignment: .leading) {
                            Text(meaning.partOfSpeech)
                                .font(.caption).bold().foregroundStyle(.orange)
                            
                            ForEach(meaning.definitions.prefix(2)) { def in
                                Text("• \(def.definition)").font(.body)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
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
