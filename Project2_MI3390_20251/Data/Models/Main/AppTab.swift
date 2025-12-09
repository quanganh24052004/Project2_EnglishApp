import Foundation
import SwiftUI

enum AppTab: Int, Identifiable, CaseIterable {
    case review, learn, settings, profile, search
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .review: return "Ôn tập"
        case .learn: return "Học từ vựng"
        case .profile: return "Cá nhân"
        case .settings: return "Cài đặt"

        case .search: return "Tìm kiếm"
        }
    }
    
    var icon: String {
        switch self {
        case .review: return "chart.bar.fill"
        case .learn: return "character.book.closed.fill"
        case .profile: return "person.fill"
        case .settings: return "gearshape.fill"
        case .search: return "magnifyingglass"
        }
    }
}
