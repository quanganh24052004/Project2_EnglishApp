//
//  SpellingView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//
import SwiftUI

struct SpellingView: View {
    let question: ReviewQuestion
    @Binding var currentInput: [String] // Mảng các ký tự người dùng đã chọn
    @State private var availableChars: [String] = [] // Pool ký tự để chọn
    
    var body: some View {
        VStack(spacing: 30) {
            ReviewPromptView(question: question)
            
            // 1. Khu vực hiển thị đáp án (Slots)
            HStack(spacing: 8) {
                ForEach(0..<question.correctAnswer.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 40, height: 45)
                        
                        // Gạch chân
                        VStack {
                            Spacer()
                            Rectangle().frame(height: 2).foregroundColor(.blue)
                        }
                        
                        if index < currentInput.count {
                            Text(currentInput[index])
                                .font(.title3)
                                .bold()
                                .transition(.scale)
                        }
                    }
                    .onTapGesture {
                        // Bấm vào slot để xóa ký tự (trả về pool)
                        if index < currentInput.count {
                            returnCharToPool(at: index)
                        }
                    }
                }
            }
            .padding(.vertical)
            
            Spacer()
            
            // 2. Khu vực phím bấm (Available Chars)
            WrapLayout(items: availableChars) { char in
                Button(action: {
                    selectChar(char)
                }) {
                    Text(char)
                        .font(.title3)
                        .frame(width: 45, height: 45)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }
                .disabled(currentInput.count >= question.correctAnswer.count)
            }
        }
        .padding()
        .onAppear {
            // Init pool ký tự (có thể thêm ký tự nhiễu nếu muốn khó hơn)
            availableChars = question.scrambledCharacters
        }
    }
    
    // Logic xử lý chọn/xóa ký tự
    func selectChar(_ char: String) {
        currentInput.append(char)
        if let index = availableChars.firstIndex(of: char) {
            availableChars.remove(at: index)
        }
    }
    
    func returnCharToPool(at index: Int) {
        let char = currentInput.remove(at: index)
        availableChars.append(char)
    }
}

// Helper: WrapLayout để tự xuống dòng các ký tự (Grid đơn giản)
struct WrapLayout<Content: View>: View {
    let items: [String]
    let content: (String) -> Content
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                content(item)
            }
        }
    }
}
