//
//  DictionaryService.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 12/12/25.
//

import Foundation

class DictionaryService {
    static let shared = DictionaryService()
    
    private init() {}
    
    func search(word: String) async throws -> [DictionaryEntry] {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty else { return [] }
        
        let endpoint = "https://api.dictionaryapi.dev/api/v2/entries/en/\(trimmedWord)"
        
        guard let url = URL(string: endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 {
                throw NSError(domain: "DictionaryAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy từ này trong từ điển."])
            }
            guard httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
        }
        
        let results = try JSONDecoder().decode([DictionaryEntry].self, from: data)
        return results
    }
}
