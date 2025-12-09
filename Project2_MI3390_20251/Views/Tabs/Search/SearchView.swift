//
//  SearchView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//
import SwiftUI
import SwiftData

struct SearchView: View {
    // 1. Lấy context để thực hiện truy vấn thủ công
    @Environment(\.modelContext) private var context
    
    // 2. State quản lý tìm kiếm
    @State private var searchText = ""
    @State private var searchResults: [Word] = [] // Mảng chứa kết quả
    @State private var hasSearched = false // Biến cờ để biết đã bấm tìm chưa
    
    var body: some View {
        NavigationStack {
            Group { // Dùng Group để tránh lồng quá nhiều lớp View không cần thiết
                if !hasSearched {
                    // TRẠNG THÁI 1: Chưa tìm
                    ContentUnavailableView("Nhập từ vựng để tra cứu", systemImage: "magnifyingglass")
                } else if searchResults.isEmpty {
                    // TRẠNG THÁI 2: Không tìm thấy
                    ContentUnavailableView.search(text: searchText)
                } else {
                    // TRẠNG THÁI 3: Có kết quả
                    // Bỏ VStack lồng nhau, dùng thẳng List
                    List {
                        // Hiển thị số lượng kết quả như một Section Header (Chuẩn iOS)
                        Section(header: Text("\(searchResults.count) kết quả tìm được")) {
                            ForEach(searchResults) { word in
                                WordRow(word: word)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Tra Từ Điển")
            // Modifier search chuẩn
            .searchable(text: $searchText, placement: .automatic, prompt: "Nhập từ tiếng Anh...")
            
            // QUAN TRỌNG: Chặn tìm kiếm live, chỉ tìm khi ấn Return (Submit)
            .onSubmit(of: .search) {
                performSearch()
            }
            // (Tuỳ chọn) Xoá kết quả khi người dùng xoá hết chữ trên thanh search
            .onChange(of: searchText) { oldValue, newValue in
                if newValue.isEmpty {
                    hasSearched = false
                    searchResults = []
                }
            }
        }
    }
    
    // --- Logic Tìm Kiếm SwiftData ---
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // SỬA LỖI: Dùng 'english' thay vì 'term'
        let predicate = #Predicate<Word> { word in
            word.english.localizedStandardContains(query)
        }
        
        let descriptor = FetchDescriptor<Word>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.english)] // Sắp xếp theo tên tiếng Anh
        )
        
        do {
            searchResults = try context.fetch(descriptor)
            hasSearched = true
        } catch {
            print("❌ Lỗi tìm kiếm: \(error)")
        }
    }
}

// Subview để hiển thị từng dòng từ vựng cho đẹp
struct WordRow: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(word.english)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                // 2. Phiên âm (phonetic)
                Text(word.phonetic)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 3. Loại từ (partOfSpeech)
                Text("(\(word.partOfSpeech))")
                    .font(.caption2)
                    .italic()
                    .foregroundColor(.gray)
            }
            
            // 4. Hiển thị nghĩa (lấy từ mảng meanings)
            if let firstMeaning = word.meanings.first {
                Text(firstMeaning.vietnamese) // Model dùng 'vietnamese', không phải 'definition'
                    .font(.body)
                
                // 5. Ví dụ (exampleEn)
                if !firstMeaning.exampleEn.isEmpty {
                    Text("Ex: \(firstMeaning.exampleEn)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
