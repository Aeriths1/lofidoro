import SwiftUI

struct SettingsView: View {
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var audioManager: AudioManager
    @Environment(\.dismiss) private var dismiss
    @State private var showGifGallery = false
    @State private var showMusicSelector = false
    @State private var showAdvancedSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    coreSettingsGroup
                    audioSettingsGroup
                    visualSettingsGroup
                    
                    if showAdvancedSettings {
                        advancedSettingsGroup
                    }
                    
                    toggleAdvancedButton
                    statisticsGroup
                    aboutGroup
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showGifGallery) {
            GifGalleryView(userSettings: userSettings)
        }
        .sheet(isPresented: $showMusicSelector) {
            MusicSelectorView(audioManager: audioManager)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "gear")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(.orange.opacity(0.8))
                .rotationEffect(.degrees(showAdvancedSettings ? 45 : 0))
                .animation(.easeInOut(duration: 0.3), value: showAdvancedSettings)
            
            Text("设置")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Core Settings Group
    private var coreSettingsGroup: some View {
        SettingsCard(title: "专注时间", icon: "clock", color: .orange) {
            VStack(spacing: 20) {
                TimerSettingRow(
                    title: "工作时段",
                    icon: "laptop",
                    duration: $userSettings.workDuration,
                    range: 5...60
                )
                
                TimerSettingRow(
                    title: "短休息",
                    icon: "cup.and.saucer",
                    duration: $userSettings.shortBreakDuration,
                    range: 1...30
                )
                
                TimerSettingRow(
                    title: "长休息",
                    icon: "bed.double",
                    duration: $userSettings.longBreakDuration,
                    range: 10...60
                )
                
                PomodoroCountRow(count: $userSettings.pomodorosUntilLongBreak)
            }
        }
    }
    
    // MARK: - Audio Settings Group
    private var audioSettingsGroup: some View {
        SettingsCard(title: "音乐氛围", icon: "music.note", color: .blue) {
            VStack(spacing: 20) {
                VolumeControlRow(volume: $userSettings.volume) { newVolume in
                    audioManager.setVolume(newVolume)
                }
                
                MusicCategoryRow(audioManager: audioManager)
                
                PlaybackControlsRow(audioManager: audioManager)
                
                if !audioManager.currentTrackName.isEmpty {
                    CurrentTrackRow(trackName: audioManager.currentTrackName)
                }
                
                MusicActionsRow {
                    showMusicSelector = true
                } skipAction: {
                    audioManager.skipToNextTrack()
                }
            }
        }
    }
    
    // MARK: - Visual Settings Group
    private var visualSettingsGroup: some View {
        SettingsCard(title: "视觉体验", icon: "paintbrush", color: .green) {
            VStack(spacing: 20) {
                GifSelectionRow(selectedGif: $userSettings.selectedGif)
                
                GifScaleRow(scale: $userSettings.gifScale)
                
                GifSpeedRow(speed: $userSettings.gifPlaybackSpeed)
                
                ActionButton(
                    title: "预览和管理",
                    icon: "photo.on.rectangle",
                    color: .green
                ) {
                    showGifGallery = true
                }
            }
        }
    }
    
    // MARK: - Advanced Settings Group
    private var advancedSettingsGroup: some View {
        VStack(spacing: 16) {
            SettingsCard(title: "个性化", icon: "person.crop.circle", color: .purple) {
                VStack(spacing: 16) {
                    CustomTextRow(
                        title: "工作状态",
                        placeholder: "例如: studying",
                        text: $userSettings.studyingStatusText
                    )
                    
                    CustomTextRow(
                        title: "休息状态",
                        placeholder: "例如: chilling",
                        text: $userSettings.chillingStatusText
                    )
                    
                    ZenModeRow(
                        isEnabled: $userSettings.enableZenMode,
                        delay: $userSettings.zenModeDelay
                    )
                }
            }
            
            SettingsCard(title: "智能助手", icon: "brain.head.profile", color: .indigo) {
                VStack(spacing: 16) {
                    ToggleRow(
                        title: "自动开始休息",
                        icon: "play.circle",
                        isOn: $userSettings.autoStartBreaks
                    )
                    
                    ToggleRow(
                        title: "自动开始工作",
                        icon: "arrow.clockwise",
                        isOn: $userSettings.autoStartPomodoros
                    )
                    
                    ToggleRow(
                        title: "推送通知",
                        icon: "bell",
                        isOn: $userSettings.enableNotifications
                    )
                }
            }
        }
    }
    
    // MARK: - Toggle Advanced Button
    private var toggleAdvancedButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                showAdvancedSettings.toggle()
            }
        } label: {
            HStack {
                Image(systemName: showAdvancedSettings ? "chevron.up.circle" : "chevron.down.circle")
                    .font(.title3)
                Text(showAdvancedSettings ? "收起高级设置" : "展开高级设置")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Statistics Group
    private var statisticsGroup: some View {
        SettingsCard(title: "学习统计", icon: "chart.bar", color: .pink) {
            VStack(spacing: 16) {
                StatisticRow(
                    title: "完成番茄钟",
                    value: "\(userSettings.totalCompletedPomodoros)",
                    icon: "checkmark.circle"
                )
                
                StatisticRow(
                    title: "总学习时间",
                    value: userSettings.formattedTotalStudyTime,
                    icon: "clock"
                )
                
                ActionButton(
                    title: "重置统计",
                    icon: "trash",
                    color: .red,
                    style: .secondary
                ) {
                    userSettings.resetStatistics()
                }
            }
        }
    }
    
    // MARK: - About Group
    private var aboutGroup: some View {
        SettingsCard(title: "关于应用", icon: "info.circle", color: .gray) {
            VStack(spacing: 16) {
                InfoRow(title: "版本", value: "1.0.0")
                
                ActionButton(
                    title: "评价应用",
                    icon: "star",
                    color: .yellow
                ) {
                    if URL(string: "https://apps.apple.com") != nil {
                        // UIApplication.shared.open(url)
                    }
                }
                
                ActionButton(
                    title: "联系开发者",
                    icon: "envelope",
                    color: .blue
                ) {
                    if URL(string: "mailto:developer@lofitimer.com") != nil {
                        // UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting View Components

struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> Content
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            content()
        }
        .padding(20)
        .background(
            Color(.secondarySystemGroupedBackground)
                .brightness(isHovered ? 0.02 : 0)
        )
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(isHovered ? 0.08 : 0.05),
            radius: isHovered ? 12 : 8,
            x: 0,
            y: isHovered ? 4 : 2
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct TimerSettingRow: View {
    let title: String
    let icon: String
    @Binding var duration: TimeInterval
    let range: ClosedRange<Int>
    
    private var minutes: Int {
        Int(duration / 60)
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Picker(title, selection: Binding(
                get: { minutes },
                set: { duration = TimeInterval($0 * 60) }
            )) {
                ForEach(range, id: \.self) { minute in
                    Text("\(minute) 分钟").tag(minute)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(.orange)
        }
    }
}

struct PomodoroCountRow: View {
    @Binding var count: Int
    
    var body: some View {
        HStack {
            Image(systemName: "repeat")
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text("长休息前的番茄钟数")
                .font(.body)
            
            Spacer()
            
            Stepper(
                value: $count,
                in: 2...8,
                label: {
                    Text("\(count)")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            )
        }
    }
}

struct VolumeControlRow: View {
    @Binding var volume: Float
    let onVolumeChange: (Float) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "speaker.wave.1")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Text("音量")
                    .font(.body)
                
                Spacer()
                
                Text("\(Int(volume * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Slider(
                value: $volume,
                in: 0...1,
                step: 0.1
            ) {
                Image(systemName: "speaker")
            } minimumValueLabel: {
                Image(systemName: "speaker")
                    .foregroundColor(.secondary)
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.3")
                    .foregroundColor(.secondary)
            }
            .accentColor(.blue)
            .onChange(of: volume) { _, newVolume in
                onVolumeChange(newVolume)
            }
        }
    }
}

struct MusicCategoryRow: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        HStack {
            Image(systemName: "music.note.list")
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text("音乐风格")
                .font(.body)
            
            Spacer()
            
            Picker("音乐类别", selection: $audioManager.currentMusicCategory) {
                Text("Jazz").tag(MusicCategory.nujabes)
                Text("Lo-Fi").tag(MusicCategory.kudasai)
                Text("Zelda").tag(MusicCategory.zelda)
                Text("白噪音").tag(MusicCategory.whitenoise)
                Text("Bill Evans").tag(MusicCategory.billevans)
                Text("Chet Baker").tag(MusicCategory.chetbaker)
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(.blue)
        }
    }
}

struct PlaybackControlsRow: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        HStack {
            Image(systemName: "music.note")
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text("背景音乐")
                .font(.body)
            
            Spacer()
            
            HStack(spacing: 12) {
                Toggle("随机起始", isOn: $audioManager.randomStartEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .scaleEffect(0.8)
                
                Toggle("后台播放", isOn: $audioManager.enableBackgroundAudio)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .scaleEffect(0.8)
                
                Button {
                    if audioManager.isPlayingBackgroundMusic {
                        audioManager.pauseBackgroundMusic()
                    } else {
                        audioManager.playBackgroundMusic()
                    }
                } label: {
                    Image(systemName: audioManager.isPlayingBackgroundMusic ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct CurrentTrackRow: View {
    let trackName: String
    
    var body: some View {
        HStack {
            Image(systemName: "waveform")
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text("正在播放")
                .font(.body)
            
            Spacer()
            
            Text(trackName)
                .font(.caption)
                .foregroundColor(.blue)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
}

struct MusicActionsRow: View {
    let manageAction: () -> Void
    let skipAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ActionButton(
                title: "管理音乐",
                icon: "music.note.list",
                color: .blue,
                style: .secondary
            ) {
                manageAction()
            }
            
            ActionButton(
                title: "下一首",
                icon: "forward.fill",
                color: .blue,
                style: .secondary
            ) {
                skipAction()
            }
        }
    }
}

struct GifSelectionRow: View {
    @Binding var selectedGif: String
    
    var body: some View {
        HStack {
            Image(systemName: "photo")
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text("动画主题")
                .font(.body)
            
            Spacer()
            
            Picker("GIF", selection: $selectedGif) {
                Text("LoFi Girl").tag("lofi-girl")
                Text("雪景").tag("snow")
                Text("兔子").tag("rabbit")
                Text("跳舞").tag("dancing")
                Text("画画").tag("drawing")
                Text("面条").tag("noodling")
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(.green)
        }
    }
}

struct GifScaleRow: View {
    @Binding var scale: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "aspectratio")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Text("动画大小")
                    .font(.body)
                
                Spacer()
                
                Text("\(Int(scale * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Slider(
                value: $scale,
                in: 0.5...2.0,
                step: 0.1
            )
            .accentColor(.green)
        }
    }
}

struct GifSpeedRow: View {
    @Binding var speed: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "speedometer")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Text("播放速度")
                    .font(.body)
                
                Spacer()
                
                Text("\(speed, specifier: "%.1f")x")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Slider(
                value: $speed,
                in: 0.5...2.0,
                step: 0.1
            )
            .accentColor(.green)
        }
    }
}

enum ActionButtonStyle {
    case primary
    case secondary
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    var style: ActionButtonStyle = .primary
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body)
                    .fontWeight(.medium)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundColor(style == .primary ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if style == .primary {
                        color
                            .brightness(isPressed ? -0.1 : 0)
                    } else {
                        color.opacity(isPressed ? 0.15 : 0.1)
                    }
                }
            )
            .cornerRadius(10)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: color.opacity(0.3),
                radius: isPressed ? 2 : 4,
                x: 0,
                y: isPressed ? 1 : 2
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct CustomTextRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "textformat")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Text(title)
                    .font(.body)
            }
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accentColor(.purple)
        }
    }
}

struct ZenModeRow: View {
    @Binding var isEnabled: Bool
    @Binding var delay: TimeInterval
    
    var body: some View {
        VStack(spacing: 12) {
            ToggleRow(
                title: "禅意模式",
                icon: "leaf",
                isOn: $isEnabled
            )
            
            if isEnabled {
                VStack(spacing: 8) {
                    HStack {
                        Text("按钮隐藏延迟")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(delay))秒")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                    }
                    
                    Slider(
                        value: $delay,
                        in: 30...300,
                        step: 30
                    )
                    .accentColor(.purple)
                }
                .padding(.leading, 24)
            }
        }
    }
}

struct ToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .indigo))
        }
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.pink)
        }
        .padding(.vertical, 4)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    SettingsView(userSettings: UserSettings(), audioManager: AudioManager())
}