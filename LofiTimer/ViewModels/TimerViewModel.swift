import Foundation
import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    @Published private var pomodoroTimer = PomodoroTimer()
    @Published var audioManager = AudioManager()
    
    private var userSettings: UserSettings?
    private var cancellables = Set<AnyCancellable>()
    
    var currentSession: PomodoroSession {
        pomodoroTimer.currentSession
    }
    
    var state: TimerState {
        pomodoroTimer.state
    }
    
    var completedPomodoros: Int {
        pomodoroTimer.completedPomodoros
    }
    
    var pomodoroProgress: [Bool] {
        pomodoroTimer.getCurrentPomodoroProgress()
    }
    
    var isRunning: Bool {
        state == .running
    }
    
    var isPaused: Bool {
        state == .paused
    }
    
    var isStopped: Bool {
        state == .stopped
    }
    
    var timeDisplayText: String {
        currentSession.formattedTimeRemaining
    }
    
    var sessionTypeText: String {
        currentSession.type.displayName
    }
    
    var progress: Double {
        currentSession.progress
    }
    
    var timeRemaining: TimeInterval {
        currentSession.timeRemaining
    }
    
    var initialDuration: TimeInterval {
        currentSession.duration
    }
    
    var playButtonText: String {
        switch state {
        case .stopped, .paused:
            return "Start"
        case .running:
            return "Pause"
        }
    }
    
    init(userSettings: UserSettings? = nil) {
        self.userSettings = userSettings
        observeTimer()
        observeTimerCompletion()
    }
    
    func setUserSettings(_ settings: UserSettings) {
        self.userSettings = settings
    }
    
    func toggleTimer() {
        audioManager.playHapticFeedback()
        
        switch state {
        case .stopped, .paused:
            pomodoroTimer.start()
            audioManager.playBackgroundMusic()
            audioManager.playTimerStartSound()
        case .running:
            pomodoroTimer.pause()
            audioManager.pauseBackgroundMusic()
            audioManager.playTimerPauseSound()
        }
    }
    
    func resetTimer() {
        audioManager.playHapticFeedback(style: .medium)
        pomodoroTimer.reset()
        audioManager.stopBackgroundMusic()
    }
    
    func toggleBackgroundMusic() {
        if audioManager.isPlayingBackgroundMusic {
            audioManager.pauseBackgroundMusic()
        } else {
            audioManager.playBackgroundMusic()
        }
    }
    
    func adjustTimerDuration(_ minutesToAdd: Int) {
        // Only allow adjustment when timer is stopped and at initial duration
        guard isStopped && timeRemaining == initialDuration else { return }
        
        let secondsToAdd = TimeInterval(minutesToAdd * 60)
        let newDuration = max(300, initialDuration + secondsToAdd) // Minimum 5 minutes
        
        pomodoroTimer.adjustCurrentSessionDuration(newDuration)
        audioManager.playHapticFeedback(style: .light)
    }
    
    private func observeTimer() {
        pomodoroTimer.objectWillChange.sink { [weak self] in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        .store(in: &cancellables)
    }
    
    private func observeTimerCompletion() {
        pomodoroTimer.$currentSession
            .dropFirst()
            .sink { [weak self] session in
                if session.timeRemaining == session.duration {
                    // Update statistics when a session completes
                    if let userSettings = self?.userSettings {
                        if session.type == .work {
                            // A work session just completed
                            userSettings.incrementCompletedPomodoros()
                            userSettings.addStudyTime(session.duration)
                            self?.audioManager.playSessionChangeSound()
                        } else {
                            // A break session just completed
                            self?.audioManager.playTimerCompletionSound()
                        }
                    } else {
                        // Fallback: just play sounds without statistics
                        if session.type == .work {
                            self?.audioManager.playSessionChangeSound()
                        } else {
                            self?.audioManager.playTimerCompletionSound()
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}