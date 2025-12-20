//
//  AudioManager.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    // Singleton để dùng chung (nếu muốn), hoặc tạo instance riêng trong View
    static let shared = AudioManager()
    
    private var player: AVPlayer?
    
    init() {
        // Cấu hình để âm thanh phát được ngay cả khi điện thoại để chế độ Silent
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Lỗi cấu hình AudioSession: \(error.localizedDescription)")
        }
    }
    
    // Hàm phát audio từ URL với tốc độ tuỳ chỉnh
    // - Parameters:
    //   - urlString: Đường dẫn file mp3
    //   - speed: Tốc độ phát (1.0 là bình thường, 0.5 là chậm)
    func playAudio(url urlString: String?, speed: Float = 1.0) {
        // 1. Kiểm tra URL có tồn tại và hợp lệ không
        guard let urlString = urlString, let url = URL(string: urlString) else {
            print("Audio URL không hợp lệ hoặc bị nil")
            return
        }
        
        // 2. Tạo PlayerItem
        let playerItem = AVPlayerItem(url: url)
        
        // 3. Khởi tạo Player
        player = AVPlayer(playerItem: playerItem)
        
        // 4. Phát ngay lập tức với tốc độ mong muốn
        player?.playImmediately(atRate: speed)
    }
    
    func stop() {
        player?.pause()
    }
}
