//
//  User+Extensions.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//

import Foundation
import Supabase

extension Auth.User {
    
    // 1. Lấy First Name
    var firstName: String {
        // Sửa lỗi: Truy cập trực tiếp userMetadata (vì nó không nil)
        // Kiểm tra xem key "first_name" có tồn tại và có phải là String không
        if let json = userMetadata["first_name"],
           case .string(let value) = json {
            return value
        }
        return ""
    }
    
    // 2. Lấy Last Name
    var lastName: String {
        if let json = userMetadata["last_name"],
           case .string(let value) = json {
            return value
        }
        return ""
    }
    
    // 3. Lấy Phone (Ưu tiên metadata, nếu không có thì lấy phone chính của User)
    var phoneNumber: String {
        if let json = userMetadata["phone"],
           case .string(let value) = json {
            return value
        }
        return self.phone ?? "Chưa cập nhật"
    }
    
    // 4. Tên hiển thị đầy đủ (Computed Property)
    var fullName: String {
        let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Người dùng" : name
    }
    
    // 5. Lấy 2 chữ cái đầu để làm Avatar
    var initials: String {
        let f = firstName.first.map(String.init) ?? ""
        let l = lastName.first.map(String.init) ?? ""
        let result = f + l
        
        // Nếu không có tên, trả về ký tự đầu của email hoặc "U"
        if result.isEmpty {
            return email?.prefix(1).uppercased() ?? "U"
        }
        
        return result.uppercased()
    }
}
