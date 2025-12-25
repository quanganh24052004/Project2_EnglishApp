//
//  PracticeView.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 20/12/25.
//

import SwiftUI
import SwiftData

struct PracticeView: View {
    var records: [StudyRecord]
    
    @Environment(\.modelContext) private var modelContext
    @State private var learningManager: LearningManager?
    
    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false
    @State private var showResult: Bool = false // Hiện popup kết quả cuối cùng
    
    var currentRecord: StudyRecord? {
        if records.isEmpty || currentIndex >= records.count { return nil }
        return records[currentIndex]
    }
    
    var body: some View {
        VStack {
            ProgressView(value: Double(currentIndex), total: Double(max(records.count, 1)))
                .padding()
            
            Spacer()
            
            if let record = currentRecord, let word = record.word {
                // MARK: - FLASHCARD AREA
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 5)
                    
                    VStack(spacing: 20) {
                        if isFlipped {
                            Text(word.meanings.first?.vietnamese ?? "Chưa cập nhật nghĩa")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                            
                            Text(word.partOfSpeech)
                                .italic()
                                .foregroundColor(.secondary)
                        } else {
                            Text(word.english)
                                .font(.system(size: 40, weight: .bold))
                        }
                    }
                    .padding()
                }
                .frame(height: 400)
                .padding(.horizontal)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        isFlipped.toggle()
                    }
                }
                
                Spacer()
                
                // MARK: - BUTTONS AREA
                if isFlipped {
                    HStack(spacing: 30) {
                        Button(action: { handleAnswer(isCorrect: false) }) {
                            VStack {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 40))
                                Text("Quên")
                                    .font(.headline)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(15)
                        }
                        
                        Button(action: { handleAnswer(isCorrect: true) }) {
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                Text("Nhớ")
                                    .font(.headline)
                            }
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Text("Chạm vào thẻ để xem đáp án")
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            } else {
                VStack {
                    Text("🎉")
                        .font(.system(size: 80))
                    Text("Đã hoàn thành ôn tập!")
                        .font(.title2.bold())
                }
            }
            
            Spacer()
        }
        .navigationTitle("Ôn tập")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.learningManager = LearningManager(modelContext: modelContext)
        }
        .alert("Hoàn thành", isPresented: $showResult) {
            Button("Đóng", role: .cancel) {
            }
        }
    }
    
    // MARK: - Logic Xử lý Trả lời
    func handleAnswer(isCorrect: Bool) {
        guard let record = currentRecord else { return }
        
        learningManager?.processReviewResult(record: record, isCorrect: isCorrect)
        
        withAnimation {
            isFlipped = false // Úp thẻ lại
            
            if currentIndex < records.count - 1 {
                currentIndex += 1
            } else {
                showResult = true // Đã hết danh sách
            }
        }
    }
}
