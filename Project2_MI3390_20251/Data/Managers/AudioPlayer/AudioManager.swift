//
//  AudioManager.swift
//  Project2_MI3390_20251
//
//  Created by Nguyễn Quang Anh on 9/12/25.
//
    
import Foundation
import AVFoundation
import Combine
import AudioToolbox
import UIKit

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    private var player: AVPlayer?
    
    private let synthesizer = AVSpeechSynthesizer()
    
    @Published var isSpeaking: Bool = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Lỗi cấu hình AudioSession: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Chức năng 1: Text-to-Speech
    func playTTS(text: String, language: String = "en-US", speed: Float = 0.5) {
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
        if isCorrect {
            AudioServicesPlaySystemSound(1407)
        } else {
            AudioServicesPlaySystemSound(1053)
        }
        
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
