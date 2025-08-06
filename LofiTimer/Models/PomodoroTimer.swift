import Foundation

enum TimerState {
    case stopped
    case running
    case paused
}

enum SessionType {
    case work
    case shortBreak
    case longBreak
    
    var duration: TimeInterval {
        switch self {
        case .work:
            return 25 * 60
        case .shortBreak:
            return 5 * 60
        case .longBreak:
            return 15 * 60
        }
    }
    
    var displayName: String {
        switch self {
        case .work:
            return "focus time"
        case .shortBreak:
            return "short break"
        case .longBreak:
            return "long break"
        }
    }
}

struct PomodoroSession {
    let type: SessionType
    let duration: TimeInterval
    var timeRemaining: TimeInterval
    var completedPomodoros: Int
    
    init(type: SessionType, completedPomodoros: Int = 0, customDuration: TimeInterval? = nil) {
        self.type = type
        self.duration = customDuration ?? type.duration
        self.timeRemaining = customDuration ?? type.duration
        self.completedPomodoros = completedPomodoros
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return (duration - timeRemaining) / duration
    }
    
    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    mutating func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
    }
    
    var isCompleted: Bool {
        timeRemaining <= 0
    }
    
    mutating func reset() {
        timeRemaining = duration
    }
}

class PomodoroTimer: ObservableObject {
    @Published var currentSession: PomodoroSession
    @Published var state: TimerState = .stopped
    @Published var completedPomodoros: Int = 0
    
    private var timer: Timer?
    
    init() {
        self.currentSession = PomodoroSession(type: .work)
    }
    
    func start() {
        guard state != .running else { return }
        
        state = .running
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        state = .paused
        timer?.invalidate()
        timer = nil
    }
    
    func stop() {
        state = .stopped
        timer?.invalidate()
        timer = nil
        currentSession.reset()
    }
    
    func reset() {
        stop()
        currentSession.reset()
    }
    
    func adjustCurrentSessionDuration(_ newDuration: TimeInterval) {
        guard state == .stopped else { return }
        
        // Create a new session with the adjusted duration
        let adjustedSession = PomodoroSession(
            type: currentSession.type,
            completedPomodoros: currentSession.completedPomodoros,
            customDuration: newDuration
        )
        
        currentSession = adjustedSession
    }
    
    private func tick() {
        currentSession.tick()
        
        if currentSession.isCompleted {
            completeCurrentSession()
        }
    }
    
    private func completeCurrentSession() {
        timer?.invalidate()
        timer = nil
        state = .stopped
        
        switch currentSession.type {
        case .work:
            completedPomodoros += 1
            let nextSessionType: SessionType = (completedPomodoros % 4 == 0) ? .longBreak : .shortBreak
            currentSession = PomodoroSession(type: nextSessionType, completedPomodoros: completedPomodoros)
        case .shortBreak, .longBreak:
            currentSession = PomodoroSession(type: .work, completedPomodoros: completedPomodoros)
        }
    }
    
    func getCurrentPomodoroProgress() -> [Bool] {
        let currentCycle = completedPomodoros % 4
        var progress: [Bool] = []
        
        for i in 0..<4 {
            progress.append(i < currentCycle)
        }
        
        return progress
    }
}