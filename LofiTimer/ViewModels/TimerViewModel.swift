import Foundation
import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    @Published private var pomodoroTimer = PomodoroTimer()
    @Published var audioManager = AudioManager()
    
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
    
    var playButtonText: String {
        switch state {
        case .stopped, .paused:
            return "Start"
        case .running:
            return "Pause"
        }
    }
    
    init() {
        observeTimer()
        observeTimerCompletion()
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
                    // Play different sounds for different transitions
                    if session.type == .work {
                        self?.audioManager.playSessionChangeSound()
                    } else {
                        self?.audioManager.playTimerCompletionSound()
                    }
                }
            }
            .store(in: &cancellables)
    }
}