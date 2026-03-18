import SwiftData
import SwiftUI
import Combine
import Observation
import UIKit

struct SearchView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel: SearchViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = State(wrappedValue: SearchViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.searchMode {
                case .local:
                    localSearchContent
                case .online:
                    onlineSearchContent
                }
            }
            .navigationTitle(viewModel.searchMode == .local ? "Look up Offline" : "Look up Online")
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: viewModel.searchMode == .local ? "Find it in the notebook..." : "Search online...")
            
            .onSubmit(of: .search) {
                viewModel.performSearch()
            }
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                if newValue.isEmpty { viewModel.resetState() }
            }
            .onChange(of: viewModel.searchMode) { oldValue, newValue in
                viewModel.resetState()
                viewModel.searchText = ""
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Search mode", selection: $viewModel.searchMode) {
                            ForEach(SearchViewModel.SearchMode.allCases) { mode in
                                Label(mode.rawValue, systemImage: mode.iconName)
                                    .tag(mode)
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.searchMode.iconName)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
    
    // MARK: - Local Search View
    @ViewBuilder
    private var localSearchContent: some View {
        if !viewModel.hasSearched {
            ContentUnavailableView("Look up Offline dictionary", systemImage: "book.closed", description: Text("Search in saved data."))
        } else if viewModel.localResults.isEmpty {
            ContentUnavailableView.search(text: viewModel.searchText)
        } else {
            List {
                Section(header: Text("\(viewModel.localResults.count) words in the collection")) {
                    ForEach(viewModel.localResults) { word in
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
        if viewModel.isLoading {
            ProgressView("Loading data...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView("Error", systemImage: "wifi.exclamationmark", description: Text(error))
        } else if !viewModel.hasSearched {
            ContentUnavailableView("Look up online dictionary", systemImage: "globe", description: Text("Look up the detailed English definition."))
        } else if viewModel.apiResults.isEmpty {
            ContentUnavailableView.search(text: viewModel.searchText)
        } else {
            List(viewModel.apiResults) { entry in
                VStack(alignment: .leading, spacing: 6) {
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
                        
                        Button(action: {
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
                    
                    ForEach(entry.meanings) { meaning in
                        VStack(alignment: .leading, spacing: 4) {
                            
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
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.bottom, 4)
                    }
                }
                .padding(.vertical, 6)
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - ViewModel

@Observable
@MainActor
class SearchViewModel {
    enum SearchMode: String, CaseIterable, Identifiable {
        case local = "Handbook"
        case online = "Online"
        
        var id: String { self.rawValue }
        
        var iconName: String {
            switch self {
            case .local: return "book"
            case .online: return "globe"
            }
        }
    }

    private var modelContext: ModelContext
    
    var searchText: String = ""
    var searchMode: SearchMode = .online
    var hasSearched: Bool = false
    
    var localResults: [Word] = []
    var apiResults: [DictionaryEntry] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func resetState() {
        hasSearched = false
        localResults = []
        apiResults = []
        errorMessage = nil
        isLoading = false
    }
    
    func performSearch() {
        if searchMode == .local {
            performLocalSearch()
        } else {
            Task { await performOnlineSearch() }
        }
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
            localResults = try modelContext.fetch(descriptor)
        } catch {
            print("❌ Search error: \(error)")
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
            self.errorMessage = "Not found or network error."
        }
    }
}
