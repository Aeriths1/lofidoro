import Foundation
import AVFoundation

enum MusicCategory: String, CaseIterable {
    case nujabes = "nujabes"
    case kudasai = "kudasai"
    case zelda = "zelda"
    case billevans = "BillEvans"
    case chetbaker = "ChetBaker"
    
    var displayName: String {
        switch self {
        case .nujabes:
            return "Nujabes"
        case .kudasai:
            return "Kudasai"
        case .zelda:
            return "Zelda"
        case .billevans:
            return "Bill Evans"
        case .chetbaker:
            return "Chet Baker"
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
        case .billevans:
            return "Classic jazz piano compositions"
        case .chetbaker:
            return "Smooth jazz trumpet and vocals"
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
        case .billevans:
            return "pianokeys"
        case .chetbaker:
            return "music.mic"
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
        
        // Map categories to known music files
        let categoryMusicMap: [MusicCategory: [String]] = [
            .nujabes: ["nujabes-flowers", "Dj_Cutman_Samurai_Champloo_lofi_hip_hop"],
            .kudasai: ["kudasai-lofi-background", "Ikigai_kudasaibeats_technicolor"],
            .zelda: ["zelda"],
            .billevans: ["William_Repicci_Bill_Evans_Peace_Piece", "jane8948_Bill_Evans_Waltz_For_Debby"],
            .chetbaker: ["Andrea_Aymerich_Panero_Chet_Baker_Rain"]
        ]
        
        // Get the predefined tracks for this category
        if let tracks = categoryMusicMap[category] {
            // Verify each track exists in the bundle
            for track in tracks {
                if Bundle.main.url(forResource: track, withExtension: "mp3") != nil {
                    musicFiles.append(track)
                } else {
                    print("Warning: Could not find \(track).mp3 in bundle for category \(category.displayName)")
                }
            }
        }
        
        // Also check for files directly in bundle with category prefix as fallback
        let categoryPrefix = category.rawValue
        if let urls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) {
            let categoryFiles = urls
                .compactMap { $0.lastPathComponent }
                .filter { $0.hasPrefix(categoryPrefix) }
                .map { String($0.dropLast(4)) }
                .filter { !musicFiles.contains($0) } // Avoid duplicates
            
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