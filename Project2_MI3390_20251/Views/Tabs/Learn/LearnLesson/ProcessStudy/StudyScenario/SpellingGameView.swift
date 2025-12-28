//
//  SpellingGameView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 19/12/25.
//

import SwiftUI

struct WordToken: Identifiable {
    var id: String { "\(text)_\(globalStartIndex)" }
    let text: String
    let globalStartIndex: Int
}

struct LineModel: Identifiable {
    var id: String { tokens.first?.id ?? UUID().uuidString }
    let tokens: [WordToken]
}

struct SpellingGameView: View {
    @EnvironmentObject var viewModel: LessonViewModel
    let item: LearningItem
    var onCheck: (String) -> Void
    
    @State private var userInput: String = ""
    @FocusState private var isFocused: Bool
    @State private var hintIndices: Set<Int> = []
    
    private var fontSize: CGFloat {
        item.word.count > 12 ? 14 : 18
    }
    
    private let underlineHeight: CGFloat = 2.5
    
    private var lines: [LineModel] {
        breakIntoLines(text: item.word)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            TextField("", text: $userInput)
                .focused($isFocused)
                .keyboardType(.asciiCapable)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .accentColor(.clear)
                .foregroundColor(.clear)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: userInput) { oldValue, newValue in
                    handleInputChange(newValue)
                }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Text("Fill in the word")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.neutral06)
                        
                        Text(item.meaning)
                            .font(.system(size: 24, weight: .regular))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - KHU VỰC ĐIỀN TỪ
                    VStack(spacing: 24) {
                        ForEach(lines) { line in
                            HStack(spacing: 12) {
                                ForEach(line.tokens) { token in
                                    wordView(token: token)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(UIColor.neutral04), lineWidth: 1.5)
                    )
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Text("\(userInput.count) / \(item.word.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .monospacedDigit()
                        .padding(.top, 10)
                }
                .padding(.bottom, 20)
            }
            .onTapGesture {
                isFocused = true
                viewModel.playCurrentAudio()
            }
            
            Spacer()
            
            // MARK: - [MỚI] Nút Check
            Button("Check") {
                onCheck(userInput)
            }
            .buttonStyle(ThreeDButtonStyle(color: .blue)) // Dùng style giống dự án
            .padding(.horizontal, 40)
            .padding(.bottom, 20) // Khoảng cách với đáy màn hình/bàn phím
        }
        .onAppear {
            setupGame()
        }
        .onChange(of: item.id) { oldValue, newValue in
            setupGame()
        }
    }
        
    func setupGame() {
        userInput = ""
        generateHints()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFocused = true
        }
    }
    
    func handleInputChange(_ newValue: String) {
        if newValue.count > item.word.count {
            userInput = String(newValue.prefix(item.word.count))
        }
    }
    
    func generateHints() {
        let word = item.word
        let totalChars = word.count
        let hintCount = max(1, Int(ceil(Double(totalChars) * 0.2)))
        var indices = Set<Int>()
        var attempts = 0
        while indices.count < hintCount && attempts < 100 {
            let rIndex = Int.random(in: 0..<totalChars)
            let char = getChar(at: rIndex, from: word)
            if char != " " { indices.insert(rIndex) }
            attempts += 1
        }
        hintIndices = indices
    }
        
    @ViewBuilder
    func wordView(token: WordToken) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<token.text.count, id: \.self) { localIndex in
                let globalIndex = token.globalStartIndex + localIndex
                charView(index: globalIndex)
            }
        }
    }
    
    @ViewBuilder
    func charView(index: Int) -> some View {
        let targetChar = getChar(at: index, from: item.word)
        
        if targetChar == " " {
            Spacer().frame(width: 8)
        } else {
            let userChar = getChar(at: index, from: userInput)
            let isHint = hintIndices.contains(index)
            let isActiveCursor = index == userInput.count
            
            VStack(spacing: 4) {
                ZStack {
                    if let uChar = userChar {
                        Text(uChar)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .transition(.scale)
                    } else if isHint {
                        Text(targetChar ?? "")
                            .fontWeight(.bold)
                            .foregroundColor(.gray.opacity(0.3))
                    } else {
                        Text("w")
                            .fontWeight(.bold)
                            .foregroundColor(.clear)
                    }
                }
                .font(.system(size: fontSize, design: .monospaced))
                
                Rectangle()
                    .fill(lineColor(userChar: userChar, isActive: isActiveCursor))
                    .frame(width: fontSize * 0.7, height: underlineHeight)
                    .cornerRadius(underlineHeight/2)
            }
        }
    }
    
    func lineColor(userChar: String?, isActive: Bool) -> Color {
        if userChar != nil {
            return .orange // Màu khi đã nhập
        } else if isActive {
            return .orange.opacity(0.6) // Màu con trỏ nhấp nháy (hoặc vị trí active)
        } else {
            return Color(UIColor.neutral04) // Màu mặc định
        }
    }
    
    func getChar(at index: Int, from text: String) -> String? {
        guard index < text.count else { return nil }
        let i = text.index(text.startIndex, offsetBy: index)
        return String(text[i])
    }
        
    func breakIntoLines(text: String) -> [LineModel] {
        var tokens: [WordToken] = []
        var currentIndex = 0
        
        let words = text.components(separatedBy: " ")
        for (i, word) in words.enumerated() {
            if !word.isEmpty {
                tokens.append(WordToken(text: word, globalStartIndex: currentIndex))
                currentIndex += word.count
            }
            if i < words.count - 1 {
                tokens.append(WordToken(text: " ", globalStartIndex: currentIndex))
                currentIndex += 1
            }
        }
        
        var lines: [LineModel] = []
        var currentTokens: [WordToken] = []
        var currentLength = 0
        let maxCharsPerLine = 12
        
        for token in tokens {
            if token.text == " " {
                currentTokens.append(token)
                currentLength += 1
                continue
            }
            
            if currentLength + token.text.count > maxCharsPerLine && !currentTokens.isEmpty {
                lines.append(LineModel(tokens: currentTokens))
                currentTokens = [token]
                currentLength = token.text.count
            } else {
                currentTokens.append(token)
                currentLength += token.text.count
            }
        }
        
        if !currentTokens.isEmpty {
            lines.append(LineModel(tokens: currentTokens))
        }
        
        return lines
    }
}
