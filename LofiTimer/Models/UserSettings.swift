import Foundation

class UserSettings: ObservableObject {
    @Published var workDuration: TimeInterval = 25 * 60 {
        didSet { saveSettings() }
    }
    
    @Published var shortBreakDuration: TimeInterval = 5 * 60 {
        didSet { saveSettings() }
    }
    
    @Published var longBreakDuration: TimeInterval = 15 * 60 {
        didSet { saveSettings() }
    }
    
    @Published var pomodorosUntilLongBreak: Int = 4 {
        didSet { saveSettings() }
    }
    
    @Published var volume: Float = 0.5 {
        didSet { saveSettings() }
    }
    
    @Published var autoStartBreaks: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var autoStartPomodoros: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var enableNotifications: Bool = true {
        didSet { saveSettings() }
    }
    
    @Published var totalCompletedPomodoros: Int = 0 {
        didSet { saveSettings() }
    }
    
    @Published var totalStudyTime: TimeInterval = 0 {
        didSet { saveSettings() }
    }
    
    @Published var selectedGif: String = "lofi-girl" {
        didSet { saveSettings() }
    }
    
    // GIF display mode: "fill", "fit", "stretch", "original"
    @Published var gifDisplayMode: String = "fill" {
        didSet { saveSettings() }
    }
    
    @Published var gifScale: Double = 1.0 {
        didSet { saveSettings() }
    }
    
    @Published var gifOffsetX: Double = 0.0 {
        didSet { saveSettings() }
    }
    
    @Published var gifOffsetY: Double = 0.0 {
        didSet { saveSettings() }
    }
    
    @Published var gifPlaybackSpeed: Double = 1.0 {
        didSet { saveSettings() }
    }
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        workDuration = userDefaults.object(forKey: "workDuration") as? TimeInterval ?? 25 * 60
        shortBreakDuration = userDefaults.object(forKey: "shortBreakDuration") as? TimeInterval ?? 5 * 60
        longBreakDuration = userDefaults.object(forKey: "longBreakDuration") as? TimeInterval ?? 15 * 60
        pomodorosUntilLongBreak = userDefaults.object(forKey: "pomodorosUntilLongBreak") as? Int ?? 4
        volume = userDefaults.object(forKey: "volume") as? Float ?? 0.5
        autoStartBreaks = userDefaults.object(forKey: "autoStartBreaks") as? Bool ?? false
        autoStartPomodoros = userDefaults.object(forKey: "autoStartPomodoros") as? Bool ?? false
        enableNotifications = userDefaults.object(forKey: "enableNotifications") as? Bool ?? true
        totalCompletedPomodoros = userDefaults.object(forKey: "totalCompletedPomodoros") as? Int ?? 0
        totalStudyTime = userDefaults.object(forKey: "totalStudyTime") as? TimeInterval ?? 0
        selectedGif = userDefaults.object(forKey: "selectedGif") as? String ?? "lofi-girl"
        gifDisplayMode = userDefaults.object(forKey: "gifDisplayMode") as? String ?? "fill"
        gifScale = userDefaults.object(forKey: "gifScale") as? Double ?? 1.0
        gifOffsetX = userDefaults.object(forKey: "gifOffsetX") as? Double ?? 0.0
        gifOffsetY = userDefaults.object(forKey: "gifOffsetY") as? Double ?? 0.0
        gifPlaybackSpeed = userDefaults.object(forKey: "gifPlaybackSpeed") as? Double ?? 1.0
    }
    
    private func saveSettings() {
        userDefaults.set(workDuration, forKey: "workDuration")
        userDefaults.set(shortBreakDuration, forKey: "shortBreakDuration")
        userDefaults.set(longBreakDuration, forKey: "longBreakDuration")
        userDefaults.set(pomodorosUntilLongBreak, forKey: "pomodorosUntilLongBreak")
        userDefaults.set(volume, forKey: "volume")
        userDefaults.set(autoStartBreaks, forKey: "autoStartBreaks")
        userDefaults.set(autoStartPomodoros, forKey: "autoStartPomodoros")
        userDefaults.set(enableNotifications, forKey: "enableNotifications")
        userDefaults.set(totalCompletedPomodoros, forKey: "totalCompletedPomodoros")
        userDefaults.set(totalStudyTime, forKey: "totalStudyTime")
        userDefaults.set(selectedGif, forKey: "selectedGif")
        userDefaults.set(gifDisplayMode, forKey: "gifDisplayMode")
        userDefaults.set(gifScale, forKey: "gifScale")
        userDefaults.set(gifOffsetX, forKey: "gifOffsetX")
        userDefaults.set(gifOffsetY, forKey: "gifOffsetY")
        userDefaults.set(gifPlaybackSpeed, forKey: "gifPlaybackSpeed")
    }
    
    func incrementCompletedPomodoros() {
        totalCompletedPomodoros += 1
    }
    
    func addStudyTime(_ duration: TimeInterval) {
        totalStudyTime += duration
    }
    
    func resetStatistics() {
        totalCompletedPomodoros = 0
        totalStudyTime = 0
    }
    
    var formattedTotalStudyTime: String {
        let hours = Int(totalStudyTime) / 3600
        let minutes = (Int(totalStudyTime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}