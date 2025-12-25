//
//  CorrectSheetView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 25/12/25.
//

import SwiftUI

struct CorrectSheetView: View {
    var body: some View {
        VStack (spacing: 16) {
            HStack {
                Image (systemName: "checkmark.seal.fill")
                Spacer()
                Button("Báo lỗi") {
                    print("Báo lỗi")
                }
                Button("Ẩn sheet") {
                    print("Ẩn sheet")
                }
            }
            HStack (spacing: 8) {
                VStack {
                    AudioButton() {
                        print("Phát âm thanh của từ")
                    }
                }
                
                VStack (spacing: 16) {
                    Text("Nghĩa tiếng anh + Loại từ")
                    Text("IPA phát âm")
                    Text("Nghĩa tiếng Việt")
                    Text("Ví dụ tiếng Anh + Button dịch")
                    Text("Ví dụ tiếng Việt (Khi bấm button dịch thì ẩn hoặc hiện")
                }
            }
        }

    }
}

#Preview {
    CorrectSheetView()
}
