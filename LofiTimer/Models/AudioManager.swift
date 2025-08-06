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
    @Published var randomStartEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(randomStartEnabled, forKey: "randomStartEnabled")
        }
    }
    
    @Published var enableBackgroundAudio: Bool = true {
        didSet {
            UserDefaults.standard.set(enableBackgroundAudio, forKey: "enableBackgroundAudio")
            updateAudioSessionForBackgroundMode()
        }
    }
    
    private let musicManager = MusicManager.shared
    
    override init() {
        super.init()
        setupAudioSession()
        loadUserPreferences()
        setupBackgroundMusic()
        preloadSoundEffects()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        if UserDefaults.standard.object(forKey: "randomStartEnabled") == nil {
            randomStartEnabled = true // Default to true if not set
        } else {
            randomStartEnabled = UserDefaults.standard.bool(forKey: "randomStartEnabled")
        }
        
        if UserDefaults.standard.object(forKey: "enableBackgroundAudio") == nil {
            enableBackgroundAudio = true // Default to true if not set
        } else {
            enableBackgroundAudio = UserDefaults.standard.bool(forKey: "enableBackgroundAudio")
        }
    }
    
    private func setupAudioSession() {
        // Configure audio session for background playback immediately
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // Use .playback category for background audio
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            print("✅ Audio session configured successfully for background playback")
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
        setupBackgroundTaskSupport()
    }
    
    private func updateAudioSessionForBackgroundMode() {
        // This method is now only called when the setting changes
        // Don't change audio session if music is currently playing
        if isPlayingBackgroundMusic {
            print("⚠️ Not changing audio session while music is playing")
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            if enableBackgroundAudio {
                // Set category to playback for background audio
                try audioSession.setCategory(.playback, mode: .default, options: [])
                try audioSession.setActive(true)
                print("✅ Audio session updated for background playback")
            } else {
                // Only switch to ambient if user explicitly disabled background audio
                try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
                try audioSession.setActive(true)
                print("ℹ️ Audio session updated for foreground-only playback")
            }
        } catch {
            print("❌ Failed to update audio session: \(error)")
        }
    }
    
    private func setupBackgroundTaskSupport() {
        // Register for notifications when the app enters/exits background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    @objc private func handleAppDidEnterBackground() {
        // Keep audio playing in background if music is currently playing and background audio is enabled
        if isPlayingBackgroundMusic && enableBackgroundAudio {
            // Ensure audio session stays active
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("✅ App entered background - continuing audio playback")
                print("   Audio player is playing: \(audioPlayer?.isPlaying ?? false)")
                print("   Audio session category: \(AVAudioSession.sharedInstance().category.rawValue)")
            } catch {
                print("❌ Failed to keep audio session active in background: \(error)")
            }
        } else if isPlayingBackgroundMusic && !enableBackgroundAudio {
            pauseBackgroundMusic()
            print("ℹ️ App entered background - pausing audio (background playback disabled)")
        }
    }
    
    @objc private func handleAppWillEnterForeground() {
        // Reactivate audio session when returning to foreground
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ App returning to foreground - audio session reactivated")
        } catch {
            print("❌ Failed to reactivate audio session: \(error)")
        }
    }
    
    @objc private func handleAudioRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            // Headphones were unplugged - pause music
            if isPlayingBackgroundMusic {
                pauseBackgroundMusic()
            }
        case .newDeviceAvailable:
            // New audio device connected - continue playing if was playing
            break
        default:
            break
        }
    }
    
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Audio session was interrupted (e.g., phone call)
            if isPlayingBackgroundMusic {
                pauseBackgroundMusic()
            }
        case .ended:
            // Audio session interruption ended
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Resume playback if appropriate
                playBackgroundMusic()
            }
        @unknown default:
            break
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
            
            // Set random start position if enabled
            if randomStartEnabled {
                setRandomStartPosition()
            }
        } catch {
            print("Error loading music from \(url): \(error)")
        }
    }
    
    private func setRandomStartPosition() {
        guard let player = audioPlayer else { return }
        
        let duration = player.duration
        
        // Don't start too late in the song - use first 70% of the track
        let maxStartTime = duration * 0.7
        
        // Don't start too early either - skip first 10% to avoid intros
        let minStartTime = duration * 0.1
        
        // Generate random start time within the range
        let randomStartTime = Double.random(in: minStartTime...maxStartTime)
        
        player.currentTime = randomStartTime
        
        print("Starting track at \(Int(randomStartTime))s of \(Int(duration))s total")
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
        // Ensure audio session is active before playing
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session activated before playback")
        } catch {
            print("❌ Failed to activate audio session: \(error)")
        }
        
        guard let player = audioPlayer else { 
            setupBackgroundMusic()
            return
        }
        
        if !player.isPlaying {
            player.play()
            isPlayingBackgroundMusic = true
            print("🎵 Started playing background music")
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
    
    func toggleRandomStart() {
        randomStartEnabled.toggle()
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