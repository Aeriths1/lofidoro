import SwiftUI

struct ContentView: View {
    @StateObject private var timerViewModel = TimerViewModel()
    @StateObject private var userSettings = UserSettings()
    @State private var showVolumeControl = false
    @State private var showGifGallery = false
    @State private var showMusicSelector = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full screen GIF background with customizable display settings
                LofiGirlAnimationView(
                    isStudying: timerViewModel.isRunning,
                    availableWidth: geometry.size.width,
                    availableHeight: geometry.size.height,
                    gifName: userSettings.selectedGif,
                    displayMode: userSettings.gifDisplayMode,
                    scale: userSettings.gifScale,
                    offsetX: userSettings.gifOffsetX,
                    offsetY: userSettings.gifOffsetY
                )
                .ignoresSafeArea()
                
                // Gradient overlay for better visibility
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Main UI
                VStack {
                    // Top timer display - like iPhone clock
                    topTimerDisplay
                        .padding(.top, 60) // Account for status bar
                    
                    Spacer()
                    
                    // Control buttons in the middle-bottom area
                    VStack(spacing: 40) {
                        controlButtonsMinimal
                        
                        // Bottom info bar
                        bottomInfoBar
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear {
            timerViewModel.audioManager.setVolume(userSettings.volume)
        }
        .onChange(of: userSettings.volume) { newVolume in
            timerViewModel.audioManager.setVolume(newVolume)
        }
        .sheet(isPresented: $showGifGallery) {
            GifGalleryView(userSettings: userSettings)
        }
        .sheet(isPresented: $showMusicSelector) {
            MusicSelectorView(audioManager: timerViewModel.audioManager)
        }
    }
    
    private var topTimerDisplay: some View {
        VStack(spacing: 12) {
            // Large time display
            Text(timerViewModel.timeDisplayText)
                .font(.system(size: 86, weight: .ultraLight, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            
            // Session type
            Text(timerViewModel.sessionTypeText)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .textCase(.lowercase)
                .tracking(2)
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.7, blue: 0.5),
                                    Color(red: 0.8, green: 0.5, blue: 1.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * timerViewModel.progress, height: 4)
                        .animation(.linear(duration: 1.0), value: timerViewModel.progress)
                }
            }
            .frame(height: 4)
            .frame(maxWidth: 320)
            .padding(.top, 8)
            
            // Pomodoro dots
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(timerViewModel.pomodoroProgress[index] ? 
                              Color.white : Color.white.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .scaleEffect(timerViewModel.pomodoroProgress[index] ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: timerViewModel.pomodoroProgress[index])
                }
            }
            .padding(.top, 12)
        }
        .padding(.horizontal, 30)
    }
    
    private var controlButtonsMinimal: some View {
        HStack(spacing: 40) {
            // Reset button
            Button(action: {
                withAnimation(.spring()) {
                    timerViewModel.resetTimer()
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.3)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    )
            }
            
            // Play/Pause button - Main action
            Button(action: {
                withAnimation(.spring()) {
                    timerViewModel.toggleTimer()
                }
            }) {
                Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                    .offset(x: timerViewModel.isRunning ? 0 : 2) // Slight offset for play icon
                    .frame(width: 84, height: 84)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.6, blue: 0.5).opacity(0.5),
                                        Color(red: 0.8, green: 0.4, blue: 0.9).opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.3)
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.5),
                                                Color.white.opacity(0.1)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .scaleEffect(timerViewModel.isRunning ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: timerViewModel.isRunning)
            
            // Music toggle
            Button(action: {
                withAnimation(.spring()) {
                    timerViewModel.toggleBackgroundMusic()
                }
            }) {
                Image(systemName: timerViewModel.audioManager.isPlayingBackgroundMusic ? "music.note" : "speaker.slash")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.3)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    )
            }
        }
    }
    
    private var bottomInfoBar: some View {
        ZStack {
            // Status indicator - Always centered
            HStack(spacing: 8) {
                Circle()
                    .fill(timerViewModel.isRunning ? 
                          Color(red: 0.4, green: 1.0, blue: 0.6) : 
                          Color.white.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .scaleEffect(timerViewModel.isRunning ? 1.0 : 0.8)
                    .animation(
                        timerViewModel.isRunning ?
                        Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) :
                        Animation.easeInOut(duration: 0.3),
                        value: timerViewModel.isRunning
                    )
                    .shadow(color: timerViewModel.isRunning ? 
                           Color(red: 0.4, green: 1.0, blue: 0.6).opacity(0.6) : 
                           Color.clear, radius: 6)
                
                Text(timerViewModel.isRunning ? "studying" : "chilling")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .opacity(0.2)
                    )
            )
            
            // Side controls
            HStack(spacing: 20) {
                // Volume control
                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            showVolumeControl.toggle()
                        }
                    }) {
                        Image(systemName: "speaker.wave.2")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.2)
                                    )
                            )
                    }
                    
                    if showVolumeControl {
                        // Inline volume slider
                        HStack(spacing: 12) {
                            Image(systemName: "speaker.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Slider(value: Binding(
                                get: { timerViewModel.audioManager.volume },
                                set: { timerViewModel.audioManager.setVolume($0) }
                            ), in: 0...1)
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
                            .frame(width: 100)
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.3))
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.2)
                                )
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                
                Spacer()
                
                // Right side controls
                HStack(spacing: 12) {
                    // Music Selector
                    Button(action: {
                        showMusicSelector = true
                    }) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.2)
                                    )
                            )
                    }
                    
                    // GIF Gallery
                    Button(action: {
                        showGifGallery = true
                    }) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.2)
                                    )
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ContentView()
}