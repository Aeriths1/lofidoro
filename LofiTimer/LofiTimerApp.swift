import SwiftUI
import AVFoundation

@main
struct LofiTimerApp: App {
    init() {
        // Configure audio session early in app lifecycle for background playback
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // CRITICAL: Use .playback category without any options for reliable background audio
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            print("✅ Audio session configured at app launch")
            print("   Category: \(audioSession.category.rawValue)")
            print("   Mode: \(audioSession.mode.rawValue)")
        } catch {
            print("❌ Failed to configure audio session at app launch: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}