import SwiftUI

// Component hiển thị 1 lựa chọn trắc nghiệm
struct ReviewOptionButton: View {
    let text: String
    let isSelected: Bool
    let isAudioMode: Bool // True nếu là nút nghe (Scenario 1, 6)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isAudioMode {
                    // Dùng lại AudioButton của bạn hoặc icon loa
                    Image(systemName: isSelected ? "speaker.wave.3.fill" : "speaker.wave.2")
                        .foregroundColor(isSelected ? .white : .blue)
                    Text("Nghe đáp án") // Hoặc ẩn text đi nếu chỉ muốn hiện loa
                } else {
                    Text(text)
                        .font(.body)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
        .onAppear {
            if isAudioMode && isSelected {
                // Logic play sound (nếu cần play khi vừa chọn)
                // AudioManager.shared.playTTS(text) 
            }
        }
    }
}