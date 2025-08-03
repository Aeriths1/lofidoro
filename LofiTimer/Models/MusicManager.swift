import Foundation
import AVFoundation

enum MusicCategory: String, CaseIterable {
    case nujabes = "nujabes"
    case kudasai = "kudasai"
    case zelda = "zelda"
    
    var displayName: String {
        switch self {
        case .nujabes:
            return "Nujabes"
        case .kudasai:
            return "Kudasai"
        case .zelda:
            return "Zelda & Gaming"
        }
    }
    
    var description: String {
        switch self {
        case .nujabes:
            return "Jazz-influenced hip-hop beats"
        case .kudasai:
            return "Modern lofi with guitar"
        case .zelda:
            return "Gaming lofi remixes"
        }
    }
    
    var iconName: String {
        switch self {
        case .nujabes:
            return "music.note"
        case .kudasai:
            return "guitars"
        case .zelda:
            return "gamecontroller"
        }
    }
}

class MusicManager: ObservableObject {
    static let shared = MusicManager()
    
    @Published var availableMusic: [MusicCategory: [String]] = [:]
    @Published var currentCategory: MusicCategory = .nujabes
    @Published var currentTrack: String?
    @Published var isShuffleEnabled: Bool = true
    @Published var isRepeatEnabled: Bool = true
    
    private var playedTracks: Set<String> = []
    
    private init() {
        loadAvailableMusic()
    }
    
    /// Load all available music tracks organized by category
    func loadAvailableMusic() {
        availableMusic = [:]
        
        for category in MusicCategory.allCases {
            availableMusic[category] = getMusicFiles(for: category)
        }
        
        print("Loaded music library: \(availableMusic)")
    }
    
    /// Get all music files for a specific category
    private func getMusicFiles(for category: MusicCategory) -> [String] {
        var musicFiles: [String] = []
        
        // Try to find music in the bundle
        if let resourcePath = Bundle.main.resourcePath {
            let categoryPath = (resourcePath as NSString).appendingPathComponent("music/\(category.rawValue)")
            
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: categoryPath)
                musicFiles = files.filter { file in
                    let lowercased = file.lowercased()
                    return lowercased.hasSuffix(".mp3") || 
                           lowercased.hasSuffix(".m4a") || 
                           lowercased.hasSuffix(".wav")
                }
                .map { String($0.dropLast(4)) } // Remove extension
                .sorted()
            } catch {
                print("Could not load music for \(category.displayName): \(error)")
            }
        }
        
        // Also check for files directly in bundle with category prefix
        let categoryPrefix = category.rawValue
        if let urls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) {
            let categoryFiles = urls
                .compactMap { $0.lastPathComponent }
                .filter { $0.hasPrefix(categoryPrefix) }
                .map { String($0.dropLast(4)) }
            
            musicFiles.append(contentsOf: categoryFiles)
        }
        
        // Remove duplicates and sort
        return Array(Set(musicFiles)).sorted()
    }
    
    /// Get next track to play
    func getNextTrack(for category: MusicCategory) -> String? {
        guard let tracks = availableMusic[category], !tracks.isEmpty else {
            return nil
        }
        
        if isShuffleEnabled {
            // Shuffle mode: pick random track, avoid recently played
            let unplayedTracks = tracks.filter { !playedTracks.contains($0) }
            
            if unplayedTracks.isEmpty {
                // All tracks played, reset and pick random
                playedTracks.removeAll()
                return tracks.randomElement()
            } else {
                let nextTrack = unplayedTracks.randomElement()
                if let track = nextTrack {
                    playedTracks.insert(track)
                }
                return nextTrack
            }
        } else {
            // Sequential mode
            if let current = currentTrack,
               let currentIndex = tracks.firstIndex(of: current) {
                let nextIndex = (currentIndex + 1) % tracks.count
                return tracks[nextIndex]
            } else {
                return tracks.first
            }
        }
    }
    
    /// Get the file URL for a music track
    func getURL(for trackName: String, category: MusicCategory) -> URL? {
        // Try multiple extensions
        let extensions = ["mp3", "m4a", "wav"]
        
        for ext in extensions {
            // Try in category subfolder
            if let url = Bundle.main.url(
                forResource: trackName,
                withExtension: ext,
                subdirectory: "music/\(category.rawValue)"
            ) {
                return url
            }
            
            // Try in main bundle
            if let url = Bundle.main.url(
                forResource: trackName,
                withExtension: ext
            ) {
                return url
            }
        }
        
        return nil
    }
    
    /// Get display name for a track
    func getDisplayName(for trackName: String) -> String {
        // Remove category prefix if present
        var name = trackName
        for category in MusicCategory.allCases {
            if name.hasPrefix(category.rawValue + "_") || name.hasPrefix(category.rawValue + "-") {
                name = String(name.dropFirst(category.rawValue.count + 1))
                break
            }
        }
        
        // Format the name nicely
        return name
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { word in
                word.prefix(1).uppercased() + word.dropFirst().lowercased()
            }
            .joined(separator: " ")
    }
    
    /// Check if any music is available
    func hasMusicAvailable() -> Bool {
        return availableMusic.values.contains { !$0.isEmpty }
    }
    
    /// Get track count for a category
    func getTrackCount(for category: MusicCategory) -> Int {
        return availableMusic[category]?.count ?? 0
    }
}