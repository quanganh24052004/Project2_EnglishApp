//
//  SpellingView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 26/12/25.
//

import SwiftUI

struct SpellingView: View {
    // MARK: - Properties
    let question: ReviewQuestion
    @Binding var currentInput: [String]
    @State private var availableChars: [String] = []
    @State private var isProcessing = false
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // 1. Câu hỏi
            ReviewPromptView(question: question)
                .padding(.bottom, 48)
            
            // 2. Khu vực hiển thị đáp án
            answerSection
            
            Spacer()
            
            // 3. Bàn phím
            keyboardSection
            
            Spacer()
        }
        .padding()
        .onAppear { initializeData() }
    }
}

// MARK: - Subviews (Sections)
private extension SpellingView {
    
    var answerSection: some View {
        CenteredFlowLayout(spacing: 8) {
            ForEach(0..<question.correctAnswer.count, id: \.self) { index in
                Button(action: {
                    if index < currentInput.count {
                        returnCharToPool(at: index)
                    }
                }) {
                    // Logic hiển thị từng ô được tách riêng
                    AnswerSlotItem(
                        char: currentInput[safe: index],
                        isEmpty: index >= currentInput.count
                    )
                }
                .buttonStyle(.plain)
                .disabled(index >= currentInput.count)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentInput)
    }
    
    var keyboardSection: some View {
        VStack {
            Text("Chọn các ký tự bên dưới")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 8)
            
            CenteredFlowLayout(spacing: 8) {
                ForEach(Array(availableChars.enumerated()), id: \.offset) { index, char in
                    Button(action: {
                        selectChar(char, at: index)
                    }) {
                        Text(char)
                    }
                    .buttonStyle(TileButtonStyle())
                    .disabled(currentInput.count >= question.correctAnswer.count)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: availableChars)
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Component Views (Small reusable parts)
/// View hiển thị một ô đáp án (Có chữ hoặc Trống)
private struct AnswerSlotItem: View {
    let char: String?
    let isEmpty: Bool
    
    var body: some View {
        ZStack {
            if isEmpty {
                // Trạng thái: Ô trống (Placeholder)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .frame(width: 45, height: 52)
                    .background(Color.gray.opacity(0.05).cornerRadius(12))
            } else if let char = char {
                // Trạng thái: Đã điền (Filled)
                Text(char)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 45, height: 52)
                    .background(Color.orange)
                    .cornerRadius(12)
                    .shadow(color: Color.orange.opacity(0.5), radius: 0, x: 0, y: 4)
                    .offset(y: -4)
            }
        }
    }
}

// MARK: - Logic & Actions
private extension SpellingView {
    func initializeData() {
        if availableChars.isEmpty && currentInput.isEmpty {
            availableChars = question.scrambledCharacters
        }
    }
    
    func selectChar(_ char: String, at index: Int) {
            guard !isProcessing else { return }
            
            guard availableChars.indices.contains(index) else {
                print("⚠️ Ignored select: Index \(index) out of range")
                return
            }
            
            isProcessing = true
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            currentInput.append(char)
            availableChars.remove(at: index)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isProcessing = false
            }
        }
    
    func returnCharToPool(at index: Int) {
        // Chặn nếu đang xử lý hoặc index sai
        guard !isProcessing, currentInput.indices.contains(index) else { return }
        
        // Khóa tương tác
        isProcessing = true
        
        let char = currentInput.remove(at: index)
        availableChars.append(char)
        
        // Mở khóa sau thời gian ngắn (đủ để animation chạy xong)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isProcessing = false
        }
    }
}

// MARK: - Styles
struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.neutral04)
            .frame(width: 55, height: 60)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.3), radius: 0, x: 0, y: isPressed ? 0 : 4)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            .offset(y: isPressed ? 4 : 0)
            .animation(.linear(duration: 0.1), value: isPressed)
    }
}

// MARK: - Custom Layout
struct CenteredFlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let totalHeight = rows.last?.maxY ?? 0
        let maxRowWidth = rows.map { $0.width }.max() ?? 0
        return CGSize(width: maxRowWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        for row in rows {
            // Căn giữa dòng bằng cách tính offset
            let rowXOffset = (bounds.width - row.width) / 2
            
            for item in row.items {
                item.view.place(
                    at: CGPoint(x: bounds.minX + rowXOffset + item.x, y: bounds.minY + item.y),
                    proposal: ProposedViewSize(width: item.width, height: item.height)
                )
            }
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row(spacing: spacing)
        let maxWidth = proposal.width ?? .infinity
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            // Nếu thêm phần tử mới mà vượt quá chiều rộng -> Xuống dòng
            if !currentRow.items.isEmpty && (currentRow.width + spacing + size.width > maxWidth) {
                currentRow.maxY = (rows.last?.maxY ?? 0) + currentRow.height + spacing
                rows.append(currentRow)
                currentRow = Row(spacing: spacing)
                currentRow.yStart = rows.last?.maxY ?? 0
            }
            
            currentRow.add(view: subview, size: size)
        }
        
        if !currentRow.items.isEmpty {
            currentRow.maxY = (rows.last?.maxY ?? 0) + currentRow.height
            rows.append(currentRow)
        }
        
        return rows
    }
    
    struct Row {
        var items: [Item] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
        var spacing: CGFloat
        var yStart: CGFloat = 0
        var maxY: CGFloat = 0
        
        mutating func add(view: LayoutSubview, size: CGSize) {
            // SỬA LỖI TẠI ĐÂY:
            // Tính toán vị trí X dựa trên width hiện tại (nếu items rỗng thì x=0, ngược lại cộng thêm spacing)
            let xPosition = items.isEmpty ? 0 : width + spacing
            
            items.append(Item(view: view, x: xPosition, y: yStart, width: size.width, height: size.height))
            
            // Cập nhật width mới = vị trí mép phải của phần tử vừa thêm
            width = xPosition + size.width
            
            // Cập nhật chiều cao dòng (lấy chiều cao lớn nhất trong dòng)
            height = max(height, size.height)
        }
    }
    
    struct Item {
        let view: LayoutSubview
        let x, y, width, height: CGFloat
    }
}
