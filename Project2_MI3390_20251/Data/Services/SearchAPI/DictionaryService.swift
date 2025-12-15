//
//  DictionaryService.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 12/12/25.
//


//
//  DictionaryService.swift
//  Project2_MI3390_20251
//
//  Created by [Tên của bạn] on 12/12/25.
//

import Foundation

class DictionaryService {
    // Singleton để dễ dàng gọi từ View
    static let shared = DictionaryService()
    
    private init() {} // Chặn khởi tạo từ bên ngoài
    
    func search(word: String) async throws -> [DictionaryEntry] {
        // 1. Chuẩn bị URL (loại bỏ khoảng trắng thừa, encode ký tự đặc biệt)
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty else { return [] }
        
        let endpoint = "https://api.dictionaryapi.dev/api/v2/entries/en/\(trimmedWord)"
        
        guard let url = URL(string: endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            throw URLError(.badURL)
        }
        
        // 2. Gọi API (async/await)
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // 3. Kiểm tra HTTP Status Code (200 là OK)
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 {
                // API trả về 404 nghĩa là không tìm thấy từ
                throw NSError(domain: "DictionaryAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Không tìm thấy từ này trong từ điển."])
            }
            guard httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
        }
        
        // 4. Decode JSON sang mảng DictionaryEntry
        // Vì bạn đã viết hàm init(from decoder:) rất chuẩn trong Model, việc decode sẽ tự động sinh UUID
        let results = try JSONDecoder().decode([DictionaryEntry].self, from: data)
        return results
    }
}