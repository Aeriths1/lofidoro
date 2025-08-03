import SwiftUI

struct MusicSelectorView: View {
    @ObservedObject var audioManager: AudioManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: MusicCategory
    @State private var showVolumeControls = false
    
    private let musicManager = MusicManager.shared
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
        self._selectedCategory = State(initialValue: audioManager.currentMusicCategory)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Playing Info
                    if !audioManager.currentTrackName.isEmpty {
                        currentPlayingCard
                    }
                    
                    // Music Categories
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Music Categories")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ForEach(MusicCategory.allCases, id: \.self) { category in
                            CategoryCard(
                                category: category,
                                isSelected: selectedCategory == category,
                                trackCount: musicManager.getTrackCount(for: category),
                                action: {
                                    withAnimation(.spring()) {
                                        selectedCategory = category
                                        audioManager.currentMusicCategory = category
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Playback Controls
                    playbackControlsCard
                        .padding(.horizontal)
                    
                    // Volume Controls
                    volumeControlsCard
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Music Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var currentPlayingCard: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Image(systemName: "music.note.list")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.7, blue: 0.5),
                            Color(red: 0.8, green: 0.5, blue: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .mask(
                    Image(systemName: "music.note.list")
                        .font(.title2)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Now Playing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(audioManager.currentTrackName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(audioManager.currentMusicCategory.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Play/Pause Button
                Button(action: {
                    if audioManager.isPlayingBackgroundMusic {
                        audioManager.pauseBackgroundMusic()
                    } else {
                        audioManager.playBackgroundMusic()
                    }
                }) {
                    Image(systemName: audioManager.isPlayingBackgroundMusic ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
        .padding(.horizontal)
    }
    
    private var playbackControlsCard: some View {
        VStack(spacing: 16) {
            Text("Playback Options")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Skip Button
                Button(action: {
                    audioManager.skipToNextTrack()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "forward.end.fill")
                            .font(.title2)
                        Text("Skip")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.tertiarySystemBackground))
                    )
                }
                
                // Shuffle Toggle
                Button(action: {
                    musicManager.isShuffleEnabled.toggle()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: musicManager.isShuffleEnabled ? "shuffle.circle.fill" : "shuffle")
                            .font(.title2)
                            .foregroundColor(musicManager.isShuffleEnabled ? .blue : .primary)
                        Text("Shuffle")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(musicManager.isShuffleEnabled ? 
                                 Color.blue.opacity(0.1) : 
                                 Color(UIColor.tertiarySystemBackground))
                    )
                }
                
                // Repeat Toggle
                Button(action: {
                    musicManager.isRepeatEnabled.toggle()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: musicManager.isRepeatEnabled ? "repeat.circle.fill" : "repeat")
                            .font(.title2)
                            .foregroundColor(musicManager.isRepeatEnabled ? .blue : .primary)
                        Text("Repeat")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(musicManager.isRepeatEnabled ? 
                                 Color.blue.opacity(0.1) : 
                                 Color(UIColor.tertiarySystemBackground))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private var volumeControlsCard: some View {
        VStack(spacing: 20) {
            Text("Volume Controls")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Music Volume
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.secondary)
                    Text("Music Volume")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(audioManager.volume * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
                
                Slider(value: $audioManager.volume, in: 0...1)
                    .tint(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.7, blue: 0.5),
                                Color(red: 0.8, green: 0.5, blue: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // Effects Volume
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "bell")
                        .foregroundColor(.secondary)
                    Text("Effects Volume")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(audioManager.effectsVolume * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
                
                Slider(value: $audioManager.effectsVolume, in: 0...1)
                    .tint(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.6, green: 0.8, blue: 1.0),
                                Color(red: 0.4, green: 0.6, blue: 0.9)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Test Effect Button
                HStack {
                    Spacer()
                    Button(action: {
                        audioManager.playTimerCompletionSound()
                    }) {
                        Text("Test Effect")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct CategoryCard: View {
    let category: MusicCategory
    let isSelected: Bool
    let trackCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? 
                              LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.7, blue: 0.5),
                                    Color(red: 0.8, green: 0.5, blue: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              ) :
                              LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.2),
                                    Color.gray.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: category.iconName)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(category.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if trackCount > 0 {
                        Text("\(trackCount) tracks")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No tracks (add MP3 files)")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    ZStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.7, blue: 0.5),
                                Color(red: 0.8, green: 0.5, blue: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .mask(
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? 
                                   LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.7, blue: 0.5).opacity(0.5),
                                        Color(red: 0.8, green: 0.5, blue: 1.0).opacity(0.5)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                   ) :
                                   LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.clear]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                   ),
                                   lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MusicSelectorView(audioManager: AudioManager())
}