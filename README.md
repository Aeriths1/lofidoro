# LofiGirl Pomodoro Timer iOS App

A beautifully designed iOS app that combines the Pomodoro Technique with the aesthetic charm of LofiGirl. Focus on your work with pixel-art animations, calming lofi music, and intuitive timer controls.

## 🎯 Features

### Core Functionality
- **Pomodoro Timer**: 25-minute work sessions with 5-minute short breaks and 15-minute long breaks
- **Animated LofiGirl Character**: Pixel-art style character that responds to timer states
- **Progress Tracking**: Visual progress indicators and session counters
- **Audio System**: Background lofi music with volume controls and completion sounds
- **Haptic Feedback**: Responsive touch feedback for all interactions

### Timer Features
- Start/Pause/Reset controls
- Automatic session transitions (work → break → work)
- Long breaks after every 4 completed pomodoros
- Circular progress indicator surrounding the character
- Real-time countdown display

### Character Animations
- **Studying Mode**: Focused work animation with subtle movements
- **Break Mode**: Relaxed animations and rest indicators
- **Breathing Effects**: Subtle breathing animations for liveliness
- **State-Responsive**: Character responds to timer state changes

### Audio & Settings
- Built-in lofi background music
- Volume slider controls
- Audio toggle on/off
- Timer completion sound notifications
- Background audio playback support

### User Preferences
- Customizable timer durations (work/short break/long break)
- Adjustable volume settings
- Statistics tracking (total pomodoros, study time)
- Auto-start options for breaks and sessions
- Notification preferences

## 🛠 Technical Implementation

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **ObservableObject**: Reactive state management
- **Combine**: Async data flow handling

### Key Components

#### Models
- `PomodoroTimer`: Core timer logic and state management
- `AudioManager`: Audio playback and sound effects
- `UserSettings`: Persistent user preferences

#### ViewModels
- `TimerViewModel`: Bridges UI and business logic

#### Views
- `ContentView`: Main timer interface
- `LofiGirlAnimationView`: Animated character component
- `SettingsView`: User preferences and statistics

### Audio System
- `AVFoundation` for audio playback
- Background audio session configuration
- System sound integration for completion alerts
- Volume control integration

### Animation System
- SwiftUI animations for character movements
- State-based animation switching
- Breathing and idle animations
- Smooth transitions between states

## 🎨 Design

### Visual Style
- **Color Scheme**: Dark gradient background with warm orange/purple accents
- **Typography**: Monospace font for timer display, system fonts for UI
- **Layout**: Centered design with clear visual hierarchy
- **Animations**: Smooth, subtle animations that don't distract from focus

### User Experience
- Intuitive gesture controls
- Clear visual feedback for all actions
- Minimal UI that promotes focus
- Consistent design language throughout

## 📱 System Requirements

- iOS 17.0+
- iPhone and iPad support
- Portrait and landscape orientations
- Background audio playback capability

## 🔧 Installation & Setup

1. Open `LofiTimer.xcodeproj` in Xcode 15+
2. Select your target device or simulator
3. Build and run the project (⌘+R)

### Project Structure
```
LofiTimer/
├── LofiTimerApp.swift          # App entry point
├── Models/
│   ├── PomodoroTimer.swift     # Timer logic
│   ├── AudioManager.swift      # Audio system
│   └── UserSettings.swift      # User preferences
├── ViewModels/
│   └── TimerViewModel.swift    # UI logic controller
├── Views/
│   ├── ContentView.swift       # Main interface
│   ├── LofiGirlAnimationView.swift  # Character animations
│   └── SettingsView.swift      # Settings interface
└── Assets.xcassets/            # App icons and resources
```

## 🎵 Audio Notes

The app is designed to work with lofi background music. For the full experience:
- Add `lofi_background.mp3` to the project bundle
- Add `timer_complete.mp3` for completion sounds
- The app will gracefully fallback to system sounds if audio files are missing

## 🚀 Future Enhancements

- Additional character animations and states
- More background music tracks
- Custom timer duration presets
- Daily/weekly statistics
- Apple Watch companion app
- Social sharing features
- Themes and customization options

## 📄 License

This project is created for educational and personal use. The LofiGirl character aesthetic is inspired by the popular YouTube lofi hip-hop streams.

---

Built with ❤️ using SwiftUI