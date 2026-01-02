//
//  String+Validation.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 7/12/25.
//

import Foundation

extension String {
    
    // MARK: - Common Validations
    
    /// Kiểm tra chuỗi có phải là định dạng Email hợp lệ hay không.
    /// Sử dụng Regex chuẩn để validate cấu trúc email (user@domain.extension).
    /// - Returns: `true` nếu đúng định dạng email, ngược lại là `false`.
    func isValidEmail() -> Bool {
        let regex = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    /// Kiểm tra mật khẩu có đủ mạnh hay không.
    /// - Parameter minLength: Độ dài tối thiểu yêu cầu (mặc định là 6 ký tự).
    /// - Returns: `true` nếu mật khẩu đủ độ dài và không chứa ký tự cấm.
    func isValidPassword(minLength: Int = 6) -> Bool {
        // Loại bỏ khoảng trắng ở đầu/cuối để tránh người dùng nhập toàn dấu cách
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= minLength
    }
    
    /// Kiểm tra chuỗi có phải là số điện thoại hợp lệ hay không.
    /// Chấp nhận số từ 9 đến 11 chữ số (phù hợp với SĐT Việt Nam).
    /// - Returns: `true` nếu là dãy số hợp lệ.
    func isValidPhoneNumber() -> Bool {
        // Regex: Bắt đầu bằng số 0, theo sau là 9-10 chữ số
        let regex = #"^0[0-9]{9,10}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    // MARK: - Helper Properties
    
    /// Kiểm tra xem chuỗi có rỗng hoặc chỉ chứa khoảng trắng không.
    /// Tiện lợi hơn việc gọi `trimmingCharacters` nhiều lần.
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
