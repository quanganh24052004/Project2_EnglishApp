import Foundation
import SwiftUI

enum AppTab: Hashable {
    case search, learn, review, forum, settings

    var title: String {
        switch self {
        case .search:   return "Tra từ"
        case .learn:    return "Học"
        case .review:   return "Ôn tập"
        case .forum:    return "Diễn đàn"
        case .settings: return "Cài đặt"
        }
    }

    var systemImage: String {
        switch self {
        case .search:   return "magnifyingglass"
        case .learn:    return "book.fill"
        case .review:   return "clock.fill"
        case .forum:    return "bubble.left.and.bubble.right.fill"
        case .settings: return "gearshape"
        }
    }
}
