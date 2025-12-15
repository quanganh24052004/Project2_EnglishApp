//
//  InputStepView.swift
//  DemoQuaTrinhHoc1Tu
//
//  Created by Nguyễn Quang Anh on 28/11/25.
//
import SwiftUI

struct InputStepView: View {
    let title: String
    let item: LearningItem
    var onCheck: (String) -> Void
    
    @State private var textInput: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title).font(.headline)
            
            // Nếu là nghe chép thì hiện nút loa, điền từ thì hiện câu gợi ý...
            Button(action: {}) { Image(systemName: "speaker.wave.3.fill").font(.largeTitle) }
            
            if !textInput.isEmpty || true { // Luôn hiện hoặc tùy logic
                Text("Gợi ý: \(item.meaning)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            AppTextField(text: $textInput, placeholder: "Nhập từ vựng...", iconName: "", isSecure: false)
//            TextField("Nhập từ vựng...", text: $textInput)
//                .textFieldStyle(.roundedBorder)
//                .padding()
            
            Spacer()
            
            Button("Kiểm tra") {
                onCheck(textInput)
                textInput = ""
            }
            .buttonStyle(.borderedProminent)
            .disabled(textInput.isEmpty)
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}
