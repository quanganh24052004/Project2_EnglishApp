import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    // Singleton (tuỳ chọn, nhưng tiện nếu dùng chung toàn app)
    static let shared = AudioManager()
    
    private var player: AVPlayer?
    
    init() {
        configureAudioSession()
    }
    
    // Cấu hình để nghe được âm thanh ngay cả khi bật chế độ Silent (Gạt rung)
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Lỗi cấu hình Audio Session: \(error.localizedDescription)")
        }
    }
    
    // Hàm phát âm thanh
    func playAudio(url: String, rate: Float = 1.0) {
        // 1. Kiểm tra URL hợp lệ
        guard let validURL = URL(string: url) else {
            print("Invalid URL: \(url)")
            return
        }
        
        // 2. Tạo PlayerItem
        let playerItem = AVPlayerItem(url: validURL)
        
        // 3. Khởi tạo hoặc cập nhật Player
        // Lưu ý: Tạo mới AVPlayer mỗi lần play để đảm bảo reset state cũ
        player = AVPlayer(playerItem: playerItem)
        
        // 4. Phát ngay lập tức với tốc độ mong muốn
        // playImmediately(atRate:) hiệu quả hơn việc gọi play() rồi set rate sau
        player?.playImmediately(atRate: rate)
    }
    
    func stopAudio() {
        player?.pause()
    }
}