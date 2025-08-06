import SwiftUI

struct ContentView: View {
    @StateObject private var userSettings = UserSettings()
    @StateObject private var timerViewModel: TimerViewModel
    @State private var showSettings = false
    @State private var isZenModeActive = false
    @State private var zenModeTimer: Timer?
    
    init() {
        let settings = UserSettings()
        let timer = TimerViewModel(userSettings: settings)
        _userSettings = StateObject(wrappedValue: settings)
        _timerViewModel = StateObject(wrappedValue: timer)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
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
                    offsetY: userSettings.gifOffsetY,
                    playbackSpeed: userSettings.gifPlaybackSpeed
                )
                .ignoresSafeArea()
                
                // Gradient overlay for better visibility - less opacity in landscape
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(isLandscape ? 0.3 : 0.6),
                        Color.black.opacity(isLandscape ? 0.1 : 0.2),
                        Color.black.opacity(0.05),
                        Color.black.opacity(isLandscape ? 0.1 : 0.2),
                        Color.black.opacity(isLandscape ? 0.3 : 0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Adaptive layout based on orientation
                if isLandscape {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear {
            timerViewModel.audioManager.setVolume(userSettings.volume)
        }
        .onChange(of: userSettings.volume) { _, newVolume in
            timerViewModel.audioManager.setVolume(newVolume)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(userSettings: userSettings, audioManager: timerViewModel.audioManager)
        }
        .onAppear {
            startZenModeTimer()
        }
        .onChange(of: timerViewModel.isRunning) { _, _ in
            resetZenModeTimer()
        }
        .onTapGesture {
            if isZenModeActive {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isZenModeActive = false
                }
                resetZenModeTimer()
            }
        }
    }
    
    // Portrait layout (original design)
    private var portraitLayout: some View {
        VStack {
            Spacer()
                .frame(height: 80)
            
            timerDisplay
                .opacity(isZenModeActive ? 0 : 1)
                .scaleEffect(isZenModeActive ? 0.8 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: isZenModeActive)
            
            Spacer()
            
            controlButtonsMinimal
                .opacity(isZenModeActive ? 0 : 1)
                .scaleEffect(isZenModeActive ? 0.8 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: isZenModeActive)
                .padding(.bottom, 50)
        }
    }
    
    // Landscape layout (horizontal arrangement)
    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            // Left side - Timer display and progress
            VStack(spacing: 20) {
                Spacer()
                
                // Large time display
                Text(timerViewModel.timeDisplayText)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                
                // Status indicator
                HStack(spacing: 12) {
                    Circle()
                        .fill(timerViewModel.isRunning ? 
                              Color(red: 0.4, green: 1.0, blue: 0.6) : 
                              Color.white.opacity(0.5))
                        .frame(width: 10, height: 10)
                        .scaleEffect(timerViewModel.isRunning ? 1.0 : 0.8)
                        .animation(
                            timerViewModel.isRunning ?
                            Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) :
                            Animation.easeInOut(duration: 0.3),
                            value: timerViewModel.isRunning
                        )
                        .shadow(color: timerViewModel.isRunning ? 
                               Color(red: 0.4, green: 1.0, blue: 0.6).opacity(0.6) : 
                               Color.clear, radius: 8)
                    
                    Text(timerViewModel.isRunning ? userSettings.studyingStatusText : userSettings.chillingStatusText)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(2)
                        .textCase(.lowercase)
                }
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 6)
                        
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
                            .frame(width: geo.size.width * timerViewModel.progress, height: 6)
                            .animation(.linear(duration: 1.0), value: timerViewModel.progress)
                    }
                }
                .frame(height: 6)
                .frame(maxWidth: 280)
                
                // Pomodoro dots
                HStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(timerViewModel.pomodoroProgress[index] ? 
                                  Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(timerViewModel.pomodoroProgress[index] ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: timerViewModel.pomodoroProgress[index])
                    }
                }
                .padding(.top, 16)
                
                Spacer()
            }
            .opacity(isZenModeActive ? 0 : 1)
            .scaleEffect(isZenModeActive ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.5), value: isZenModeActive)
            .frame(maxWidth: .infinity)
            .padding(.leading, 30)
            
            // Right side - Simplified controls
            VStack(spacing: 40) {
                    Spacer()
                    
                    // Play/Pause button - Main action
                    Button(action: {
                        withAnimation(.spring()) {
                            timerViewModel.toggleTimer()
                        }
                    }) {
                    Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .offset(x: timerViewModel.isRunning ? 0 : 2)
                        .frame(width: 72, height: 72)
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
                
                // Secondary controls arranged vertically
                VStack(spacing: 25) {
                    // Reset button
                    Button(action: {
                        withAnimation(.spring()) {
                            timerViewModel.resetTimer()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 48, height: 48)
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
                    
                    // Settings button
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 48, height: 48)
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
                
                Spacer()
                }
                .opacity(isZenModeActive ? 0 : 1)
                .scaleEffect(isZenModeActive ? 0.8 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: isZenModeActive)
                .frame(maxWidth: .infinity)
                .padding(.trailing, 30)
        }
        .padding(.vertical, 20)
    }
    
    private func adjustTimerDuration(_ minutes: Int) {
        timerViewModel.adjustTimerDuration(minutes)
    }
    
    private func startZenModeTimer() {
        guard userSettings.enableZenMode else { return }
        
        zenModeTimer?.invalidate()
        zenModeTimer = Timer.scheduledTimer(withTimeInterval: userSettings.zenModeDelay, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                isZenModeActive = true
            }
        }
    }
    
    private func resetZenModeTimer() {
        zenModeTimer?.invalidate()
        if userSettings.enableZenMode && !isZenModeActive {
            startZenModeTimer()
        }
    }
    
    private var topTimerDisplay: some View {
        VStack(spacing: 12) {
            // Large time display
            Text(timerViewModel.timeDisplayText)
                .font(.system(size: 86, weight: .bold, design: .rounded))
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
    
    private var topStatusIndicator: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(timerViewModel.isRunning ? 
                      Color(red: 0.4, green: 1.0, blue: 0.6) : 
                      Color.white.opacity(0.5))
                .frame(width: 12, height: 12)
                .scaleEffect(timerViewModel.isRunning ? 1.0 : 0.8)
                .animation(
                    timerViewModel.isRunning ?
                    Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) :
                    Animation.easeInOut(duration: 0.3),
                    value: timerViewModel.isRunning
                )
                .shadow(color: timerViewModel.isRunning ? 
                       Color(red: 0.4, green: 1.0, blue: 0.6).opacity(0.6) : 
                       Color.clear, radius: 8)
            
            Text(timerViewModel.isRunning ? userSettings.studyingStatusText : userSettings.chillingStatusText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .tracking(2)
                .textCase(.lowercase)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                )
        )
    }
    
    private var timerDisplay: some View {
        VStack(spacing: 16) {
            // Timer adjustment buttons (only show when timer is stopped)
            if !timerViewModel.isRunning && timerViewModel.timeRemaining == timerViewModel.initialDuration {
                HStack(spacing: 20) {
                    // Decrease 5 minutes
                    Button(action: {
                        adjustTimerDuration(-5)
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("调整时长")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1)
                    
                    // Increase 5 minutes
                    Button(action: {
                        adjustTimerDuration(5)
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.bottom, 12)
            }
            
            // Large time display
            Text(timerViewModel.timeDisplayText)
                .font(.system(size: 86, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            
            // Studying/Chilling status (replaces session type)
            HStack(spacing: 12) {
                Circle()
                    .fill(timerViewModel.isRunning ? 
                          Color(red: 0.4, green: 1.0, blue: 0.6) : 
                          Color.white.opacity(0.5))
                    .frame(width: 12, height: 12)
                    .scaleEffect(timerViewModel.isRunning ? 1.0 : 0.8)
                    .animation(
                        timerViewModel.isRunning ?
                        Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) :
                        Animation.easeInOut(duration: 0.3),
                        value: timerViewModel.isRunning
                    )
                    .shadow(color: timerViewModel.isRunning ? 
                           Color(red: 0.4, green: 1.0, blue: 0.6).opacity(0.6) : 
                           Color.clear, radius: 8)
                
                Text(timerViewModel.isRunning ? userSettings.studyingStatusText : userSettings.chillingStatusText)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(2)
                    .textCase(.lowercase)
            }
            
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
            .padding(.top, 8)
        }
        .padding(.horizontal, 30)
    }
    
    private var controlButtonsMinimal: some View {
        HStack(spacing: 35) {
            // Reset button - 手帐贴纸风格
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    timerViewModel.resetTimer()
                }
            }) {
                ZStack {
                    // 撕纸边缘效果背景
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 58, height: 58)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.3),
                                            Color.pink.opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .rotationEffect(.degrees(-2))
                        )
                        .rotationEffect(.degrees(2))
                    
                    // 图标带手写感
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .rotationEffect(.degrees(-5))
                    
                    // 小装饰 - 星星贴纸
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(Color.yellow.opacity(0.7))
                        .offset(x: 20, y: -20)
                        .rotationEffect(.degrees(15))
                }
            }
            .scaleEffect(1.0)
            .onTapGesture {} // 防止按钮点击区域过大
            
            // Play/Pause button - 手帐主按钮风格
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                    timerViewModel.toggleTimer()
                }
            }) {
                ZStack {
                    // 多层纸张效果
                    ForEach(0..<3) { i in
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.75 - Double(i) * 0.1, blue: 0.8),
                                        Color(red: 0.9, green: 0.6 - Double(i) * 0.1, blue: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .opacity(0.3 - Double(i) * 0.08)
                            )
                            .frame(width: 88 - CGFloat(i * 4), height: 88 - CGFloat(i * 4))
                            .rotationEffect(.degrees(Double(i) * 3 - 3))
                            .offset(x: CGFloat(i) * 2, y: CGFloat(i) * 2)
                    }
                    
                    // 主按钮
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.9).opacity(0.85),
                                    Color(red: 0.95, green: 0.75, blue: 1.0).opacity(0.75)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            // 手绘边框效果
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.8),
                                            Color.pink.opacity(0.4)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 2.5
                                )
                                .overlay(
                                    // 虚线装饰
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                                        .foregroundColor(.white.opacity(0.3))
                                        .padding(4)
                                )
                        )
                        .rotationEffect(.degrees(timerViewModel.isRunning ? -1 : 1))
                    
                    // 播放/暂停图标
                    Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(x: timerViewModel.isRunning ? 0 : 2)
                        .shadow(color: Color.purple.opacity(0.3), radius: 2, x: 1, y: 1)
                    
                    // 装饰元素 - 心形贴纸
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.red.opacity(0.6))
                        .offset(x: -28, y: -28)
                        .rotationEffect(.degrees(-15))
                    
                    // 装饰元素 - 音符
                    Image(systemName: "music.note")
                        .font(.system(size: 12))
                        .foregroundColor(Color.blue.opacity(0.5))
                        .offset(x: 30, y: 25)
                        .rotationEffect(.degrees(20))
                }
                .shadow(color: Color.purple.opacity(0.2), radius: 8, x: 3, y: 5)
            }
            .scaleEffect(timerViewModel.isRunning ? 0.93 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: timerViewModel.isRunning)
            
            // Settings button - 手帐风格设置按钮
            Button(action: {
                showSettings = true
            }) {
                ZStack {
                    // 便利贴效果背景
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.yellow.opacity(0.15),
                                    Color.orange.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 58, height: 58)
                        .overlay(
                            // 折角效果
                            Path { path in
                                path.move(to: CGPoint(x: 46, y: 0))
                                path.addLine(to: CGPoint(x: 58, y: 12))
                                path.addLine(to: CGPoint(x: 46, y: 12))
                                path.closeSubpath()
                            }
                            .fill(Color.white.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.orange.opacity(0.3),
                                            Color.yellow.opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .rotationEffect(.degrees(-3))
                    
                    // 齿轮图标
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .rotationEffect(.degrees(5))
                    
                    // 装饰 - 小花
                    Image(systemName: "sparkle")
                        .font(.system(size: 8))
                        .foregroundColor(Color.purple.opacity(0.6))
                        .offset(x: -18, y: 20)
                        .rotationEffect(.degrees(45))
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
}

#Preview {
    ContentView()
}