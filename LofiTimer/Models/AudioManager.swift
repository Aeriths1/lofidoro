import Foundation
import AVFoundation
import UIKit
import AudioToolbox

class AudioManager: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var timerCompletionPlayer: AVAudioPlayer?
    private var effectPlayers: [String: AVAudioPlayer] = [:]
    
    @Published var isPlayingBackgroundMusic = false
    @Published var volume: Float = 0.5 {
        didSet {
            audioPlayer?.volume = volume
            UserDefaults.standard.set(volume, forKey: "musicVolume")
        }
    }
    @Published var effectsVolume: Float = 0.7 {
        didSet {
            UserDefaults.standard.set(effectsVolume, forKey: "effectsVolume")
        }
    }
    @Published var currentMusicCategory: MusicCategory = .nujabes {
        didSet {
            UserDefaults.standard.set(currentMusicCategory.rawValue, forKey: "musicCategory")
            if isPlayingBackgroundMusic {
                changeMusic()
            }
        }
    }
    @Published var currentTrackName: String = ""
    
    private let musicManager = MusicManager.shared
    
    override init() {
        super.init()
        setupAudioSession()
        loadUserPreferences()
        setupBackgroundMusic()
        preloadSoundEffects()
    }
    
    private func loadUserPreferences() {
        volume = UserDefaults.standard.float(forKey: "musicVolume")
        if volume == 0 { volume = 0.5 }
        
        effectsVolume = UserDefaults.standard.float(forKey: "effectsVolume")
        if effectsVolume == 0 { effectsVolume = 0.7 }
        
        if let savedCategory = UserDefaults.standard.string(forKey: "musicCategory"),
           let category = MusicCategory(rawValue: savedCategory) {
            currentMusicCategory = category
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupBackgroundMusic() {
        loadNextTrack()
    }
    
    private func loadNextTrack() {
        // Try to get a track from the selected category
        if let nextTrack = musicManager.getNextTrack(for: currentMusicCategory),
           let url = musicManager.getURL(for: nextTrack, category: currentMusicCategory) {
            loadMusicFromURL(url, trackName: nextTrack)
        } else {
            print("No background music available for category: \(currentMusicCategory.displayName)")
        }
    }
    
    private func loadMusicFromURL(_ url: URL, trackName: String) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = musicManager.isRepeatEnabled ? -1 : 0
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            currentTrackName = musicManager.getDisplayName(for: trackName)
        } catch {
            print("Error loading music from \(url): \(error)")
        }
    }
    
    private func preloadSoundEffects() {
        let effects = ["timer_complete", "timer_start", "timer_pause", "session_change"]
        
        for effectName in effects {
            if let url = findSoundEffect(named: effectName) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    effectPlayers[effectName] = player
                } catch {
                    print("Error preloading effect \(effectName): \(error)")
                }
            }
        }
    }
    
    private func findSoundEffect(named name: String) -> URL? {
        // Try different extensions and locations
        let extensions = ["mp3", "m4a", "wav"]
        
        for ext in extensions {
            // Try in effects subfolder
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "effects") {
                return url
            }
            // Try in Audio/effects
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Audio/effects") {
                return url
            }
            // Try in Resources/Audio/effects
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Resources/Audio/effects") {
                return url
            }
            // Try in main bundle
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        
        return nil
    }
    
    func playBackgroundMusic() {
        guard let player = audioPlayer else { 
            setupBackgroundMusic()
            return
        }
        
        if !player.isPlaying {
            player.play()
            isPlayingBackgroundMusic = true
        }
    }
    
    func pauseBackgroundMusic() {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            isPlayingBackgroundMusic = false
        }
    }
    
    func stopBackgroundMusic() {
        guard let player = audioPlayer else { return }
        
        player.stop()
        player.currentTime = 0
        isPlayingBackgroundMusic = false
    }
    
    func skipToNextTrack() {
        let wasPlaying = isPlayingBackgroundMusic
        stopBackgroundMusic()
        loadNextTrack()
        if wasPlaying {
            playBackgroundMusic()
        }
    }
    
    func changeMusic() {
        let wasPlaying = isPlayingBackgroundMusic
        stopBackgroundMusic()
        musicManager.loadAvailableMusic() // Refresh music list
        loadNextTrack()
        if wasPlaying {
            playBackgroundMusic()
        }
    }
    
    // MARK: - Sound Effects
    
    func playTimerCompletionSound() {
        playEffect(named: "timer_complete")
    }
    
    func playTimerStartSound() {
        playEffect(named: "timer_start")
    }
    
    func playTimerPauseSound() {
        playEffect(named: "timer_pause")
    }
    
    func playSessionChangeSound() {
        playEffect(named: "session_change")
    }
    
    private func playEffect(named effectName: String) {
        if let player = effectPlayers[effectName] {
            player.volume = effectsVolume
            player.stop()
            player.currentTime = 0
            player.play()
        } else if let url = findSoundEffect(named: effectName) {
            // Try to load and play if not preloaded
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = effectsVolume
                player.play()
                effectPlayers[effectName] = player
            } catch {
                print("Error playing effect \(effectName): \(error)")
                // Fallback to system sound
                playSystemSound()
            }
        } else {
            // Use system sound as fallback
            playSystemSound()
        }
        
        // Add haptic feedback
        playHapticFeedback()
    }
    
    private func playSystemSound() {
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
    }
    
    func setEffectsVolume(_ newVolume: Float) {
        effectsVolume = max(0.0, min(1.0, newVolume))
    }
    
    func playHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == audioPlayer && flag {
            // Track finished
            if !musicManager.isRepeatEnabled {
                // Load and play next track
                loadNextTrack()
                if isPlayingBackgroundMusic {
                    playBackgroundMusic()
                }
            }
        }
    }
}