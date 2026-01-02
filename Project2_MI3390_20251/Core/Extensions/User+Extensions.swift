//
//  User+Extensions.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//  Refactored for Clean Code & Documentation.
//

import Foundation
import Supabase

extension Auth.User {
    
    // MARK: - Constants
    
    /// Các Key được sử dụng trong userMetadata
    private struct MetadataKeys {
        static let firstName = "first_name"
        static let lastName = "last_name"
        static let phone = "phone"
    }
    
    // MARK: - Computed Properties
    
    /// Tên (First Name) của người dùng lấy từ metadata.
    /// Trả về chuỗi rỗng nếu không tìm thấy.
    var firstName: String {
        return getString(forKey: MetadataKeys.firstName)
    }
    
    /// Họ (Last Name) của người dùng lấy từ metadata.
    /// Trả về chuỗi rỗng nếu không tìm thấy.
    var lastName: String {
        return getString(forKey: MetadataKeys.lastName)
    }
    
    /// Số điện thoại người dùng.
    ///
    /// Ưu tiên lấy từ `metadata` (nếu người dùng tự cập nhật),
    /// nếu không có sẽ lấy số điện thoại gốc khi đăng ký (`self.phone`).
    var phoneNumber: String {
        let metaPhone = getString(forKey: MetadataKeys.phone)
        if !metaPhone.isEmpty {
            return metaPhone
        }
        return self.phone ?? "Chưa cập nhật"
    }
    
    /// Tên hiển thị đầy đủ (Họ + Tên).
    /// Tự động loại bỏ khoảng trắng thừa.
    var fullName: String {
        let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? (email ?? "Người dùng") : name
    }
    
    /// Lấy 2 chữ cái đầu của tên để làm Avatar (Initials).
    ///
    /// Ví dụ: "Nguyen Quang" -> "NQ"
    /// Nếu không có tên, sẽ lấy 2 ký tự đầu của Email.
    var initials: String {
        let f = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let l = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Nếu có cả họ và tên
        if !f.isEmpty && !l.isEmpty {
            return "\(f.prefix(1))\(l.prefix(1))".uppercased()
        }
        
        // Nếu chỉ có tên hoặc họ
        let combined = f + l
        if !combined.isEmpty {
            return String(combined.prefix(2)).uppercased()
        }
        
        // Fallback: Lấy từ email nếu chưa cập nhật tên
        if let email = self.email, !email.isEmpty {
            return String(email.prefix(2)).uppercased()
        }
        
        return "U" // Default cho User
    }
    
    // MARK: - Helper Methods
    
    /// Hàm tiện ích để lấy giá trị String từ userMetadata an toàn.
    /// - Parameter key: Key cần lấy trong JSON object.
    /// - Returns: Giá trị String hoặc chuỗi rỗng nếu không tồn tại/sai kiểu.
    private func getString(forKey key: String) -> String {
        // Kiểm tra xem key có tồn tại và value có phải là String không
        if let json = userMetadata[key],
           case .string(let value) = json {
            return value
        }
        return ""
    }
}
