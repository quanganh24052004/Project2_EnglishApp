//
//  Word+Extension.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 31/12/25.
//

import Foundation
import SwiftData

extension Word {
    
    // MARK: - Data Mapping
    
    /// Chuyển đổi Model SwiftData `Word` sang Model View `LearningItem`.
    ///
    /// Hàm này giúp tách biệt lớp dữ liệu (Database) và lớp giao diện (View),
    /// giúp View không phụ thuộc trực tiếp vào SwiftData Object.
    ///
    /// - Returns: Đối tượng `LearningItem` dùng để hiển thị trên UI học tập.
    func toLearningItem() -> LearningItem {
        // Lấy nghĩa đầu tiên trong danh sách nghĩa (Meanings) làm nghĩa hiển thị chính.
        // Nếu danh sách rỗng, sử dụng giá trị mặc định an toàn.
        let firstMeaning = self.meanings.first
        
        return LearningItem(
            wordID: self.persistentModelID, // ID định danh duy nhất trong SwiftData
            word: self.english,
            phonetic: self.phonetic,
            partOfSpeech: self.partOfSpeech,
            meaning: firstMeaning?.vietnamese ?? "Đang cập nhật nghĩa",
            example: firstMeaning?.exampleEn ?? "No example available.",
            exampleVi: firstMeaning?.exampleVi ?? "",
            audioUrl: self.audioUrl,
            vietnamese: firstMeaning?.vietnamese ?? "Đang cập nhật"
        )
    }
}
