//
//  UserSyncManager.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 29/12/25.
//

import Foundation
import SwiftData
import Supabase

class UserSyncManager {
    static let shared = UserSyncManager()
    
    private init() {}
    
    // ID cố định cho người dùng Khách (chưa đăng nhập)
    private let GUEST_ID = "guest_user_id"
    
    // MARK: - 1. Lấy (hoặc tạo) User Khách
    // Dùng khi người dùng chưa đăng nhập nhưng muốn học thử
    @MainActor
    func getGuestUser(in context: ModelContext) -> User {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == GUEST_ID })
        
        if let guest = try? context.fetch(descriptor).first {
            return guest
        } else {
            // Chưa có thì tạo mới user khách
            let newGuest = User(
                id: GUEST_ID,
                name: "Khách",
                phone: ""
            )
            context.insert(newGuest)
            // Lưu lại ngay để đảm bảo ID tồn tại
            try? context.save()
            return newGuest
        }
    }
    
    // MARK: - 2. Đồng bộ User từ Supabase về SwiftData
    // Gọi hàm này ngay khi đăng nhập thành công
    @MainActor
    func syncUser(from supabaseUser: Auth.User, in modelContext: ModelContext) {
        let userId = supabaseUser.id.uuidString
        
        // --- Xử lý Metadata ---
        var firstName = ""
        var lastName = ""
        var phone = ""
        
        // 👇 SỬA LỖI Ở ĐÂY:
        // userMetadata không phải Optional, nên gán trực tiếp, không dùng 'if let'
        let metadata = supabaseUser.userMetadata
        
        // Sau đó truy xuất từng key bên trong (các key này mới là Optional)
        if let firstJSON = metadata["first_name"], case .string(let val) = firstJSON {
            firstName = val
        }
        if let lastJSON = metadata["last_name"], case .string(let val) = lastJSON {
            lastName = val
        }
        if let phoneJSON = metadata["phone"], case .string(let val) = phoneJSON {
            phone = val
        }
        
        // Ghép tên
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        let finalName = fullName.isEmpty ? "Người dùng" : fullName
        
        // --- Kiểm tra trong Database nội bộ ---
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == userId })
        
        do {
            let results = try modelContext.fetch(descriptor)
            
            if let existingUser = results.first {
                print("♻️ [SwiftData] Updating existing user: \(existingUser.name)")
                existingUser.name = finalName
                existingUser.phone = phone
            } else {
                print("🆕 [SwiftData] Creating new user: \(finalName)")
                let newUser = User(
                    id: userId,
                    name: finalName,
                    phone: phone
                )
                modelContext.insert(newUser)
            }
            
            try modelContext.save()
            
        } catch {
            print("❌ Error syncing user to SwiftData: \(error)")
        }
    }
    
    // MARK: - 3. Helper lấy User hiện tại (Real User)
    // Dùng để kiểm tra xem ID Supabase này đã có trong máy chưa
    @MainActor
    func getCurrentLocalUser(supabaseID: String, in context: ModelContext) -> User? {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == supabaseID })
        return try? context.fetch(descriptor).first
    }
}
