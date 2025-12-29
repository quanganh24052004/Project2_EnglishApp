//
//  AppleSignInUtils.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//


//
//  AppleSignInUtils.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//

import Foundation
import CryptoKit

struct AppleSignInUtils {
    // Tạo chuỗi nonce ngẫu nhiên
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess { fatalError("Unable to generate nonce") }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return randomBytes.map { charset[Int($0) % charset.count] }.map { String($0) }.joined()
    }
    
    // Hash nonce bằng SHA256 để gửi cho Apple
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}