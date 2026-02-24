//
//  AudioManager.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//

import Foundation
import AVFoundation
import Combine
import UIKit
import SwiftUI

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    //Player riêng cho nhạc nền
    private var backgroundPlayer: AVAudioPlayer?
    
    // Player cho âm thanh hiệu ứng (đúng/sai) - dùng file MP3 local
    private var effectPlayer: AVAudioPlayer?
    private let synthesizer = AVSpeechSynthesizer()
    
    private var player: AVPlayer?
    
    // MARK: - Quản lý Trạng thái (Settings)
    @AppStorage("isMusicEnabled") var isMusicEnabled: Bool = true {
        didSet {
            // Khi người dùng gạt switch trong Settings, xử lý ngay lập tức
            if isMusicEnabled {
                playBackgroundMusic()
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    // Cài đặt âm thanh hiệu ứng (TTS + phản hồi đúng/sai)
    @AppStorage("soundEffects") var isSoundEffectsEnabled: Bool = true
    
    @Published var isSpeaking: Bool = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            // .duckOthers: giảm âm lượng app khác khi phát audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Config Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Nhạc nền (Background Music)
    func setVolume(_ volume: Float) {
        backgroundPlayer?.volume = volume
    }
    
    func playBackgroundMusic(filename: String = "BackGroundMusic", type: String = "mp3") {
        guard isMusicEnabled else { return }
        
        // Nếu player đang chạy, chỉ cần đảm bảo volume đúng
        if let player = backgroundPlayer, player.isPlaying {
            // Lấy volume hiện tại từ UserDefaults (hoặc để nguyên nếu không muốn đọc lại từ disk liên tục)
            // Ở đây ta set lại volume cho chắc chắn
            let savedVolume = UserDefaults.standard.float(forKey: "musicVolume")
            player.volume = (savedVolume == 0) ? 0.5 : savedVolume
            return
        }
        
        guard let path = Bundle.main.path(forResource: filename, ofType: type) else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1
            
            // LẤY VOLUME TỪ USERDEFAULTS (Vì AppStorage lưu vào UserDefaults)
            let savedVolume = UserDefaults.standard.double(forKey: "musicVolume")
            // Nếu chưa có setting (bằng 0.0 do chưa lưu lần nào), ta lấy mặc định 0.5
            // Lưu ý: Logic này check nếu user chưa từng chỉnh sửa setting
            let volumeToPlay = (savedVolume == 0.0 && UserDefaults.standard.object(forKey: "musicVolume") == nil) ? 0.5 : Float(savedVolume)
            
            backgroundPlayer?.volume = volumeToPlay
            
            backgroundPlayer?.prepareToPlay()
            backgroundPlayer?.play()
        } catch {
            print("Lỗi phát nhạc nền: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
    }
    
    // Hàm này dùng để gọi lại nhạc khi quay về màn hình chính (nếu setting cho phép)
    func resumeBackgroundMusic() {
        if isMusicEnabled {
            backgroundPlayer?.play()
        }
    }
    
    // MARK: - Chức năng 1: Text-to-Speech
    func playTTS(text: String, language: String = "en-US", speed: Float = 0.5) {
        guard isSoundEffectsEnabled else { return }
        stop()
        
        let utterance = AVSpeechUtterance(string: text)
        
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        let languageVoices = allVoices.filter { $0.language == language }
        
        if let premiumVoice = languageVoices.first(where: { $0.quality == .premium }) {
            utterance.voice = premiumVoice
        } else if let enhancedVoice = languageVoices.first(where: { $0.quality == .enhanced }) {
            utterance.voice = enhancedVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        }
        
        utterance.rate = speed
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    // MARK: - Chức năng 2: Phát Audio từ URL
    func playAudio(url urlString: String?, speed: Float = 1.0) {
        stop()
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            print("Audio URL không hợp lệ")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.playImmediately(atRate: speed)
    }
    // MARK: - Chức năng 3: Hiệu ứng Phản hồi
    func playFeedback(isCorrect: Bool) {
        // Phát âm thanh MP3 local (nếu setting cho phép)
        if isSoundEffectsEnabled {
            let soundName = isCorrect ? "Correct" : "Incorrect"
            if let path = Bundle.main.path(forResource: soundName, ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
                do {
                    effectPlayer = try AVAudioPlayer(contentsOf: url)
                    effectPlayer?.prepareToPlay()
                    effectPlayer?.play()
                } catch {
                    print("Lỗi phát âm thanh hiệu ứng: \(error.localizedDescription)")
                }
            }
        }
        
        // Haptic feedback luôn chạy bất kể setting âm thanh
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        
        if isCorrect {
            generator.notificationOccurred(.success)
        } else {
            generator.notificationOccurred(.error)
        }
    }
    // MARK: - Chung
    func stop() {
        player?.pause()
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

extension AudioManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}
