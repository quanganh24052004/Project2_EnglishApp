struct TypingView: View {
    let question: ReviewQuestion
    @Binding var textInput: String
    
    var body: some View {
        VStack(spacing: 30) {
            // Nút nghe to ở giữa
            Button(action: {
                // Play Audio
                // AudioManager.shared.play(question.audioUrl)
            }) {
                ZStack {
                    Circle().fill(Color.blue.opacity(0.1)).frame(width: 100, height: 100)
                    Image(systemName: "speaker.wave.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 40)
            
            Text("Nghe và viết lại từ chính xác")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Input Field
            TextField("Nhập câu trả lời...", text: $textInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .submitLabel(.done)
            
            Spacer()
        }
        .padding()
    }
}