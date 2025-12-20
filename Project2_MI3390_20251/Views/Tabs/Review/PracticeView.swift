//
//  PracticeView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 20/12/25.
//

import SwiftUI

struct PracticeView: View {
    let records: [StudyRecord]
    var body: some View {
        Text("Review Screen")
    }
}

struct LevelStat: Identifiable {
    let id = UUID()
    let level: String
    let count: Int
    let color: Color
}
