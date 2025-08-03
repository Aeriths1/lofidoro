import SwiftUI

struct SettingsView: View {
    @ObservedObject var userSettings: UserSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                timingSection
                audioSection
                automationSection
                statisticsSection
                aboutSection
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var timingSection: some View {
        Section(header: Text("计时器时长")) {
            DurationPicker(
                label: "工作时段",
                duration: $userSettings.workDuration,
                range: 5...60
            )
            
            DurationPicker(
                label: "短休息",
                duration: $userSettings.shortBreakDuration,
                range: 1...30
            )
            
            DurationPicker(
                label: "长休息",
                duration: $userSettings.longBreakDuration,
                range: 10...60
            )
            
            Stepper(
                value: $userSettings.pomodorosUntilLongBreak,
                in: 2...8,
                label: {
                    HStack {
                        Text("长休息前的番茄钟数")
                        Spacer()
                        Text("\(userSettings.pomodorosUntilLongBreak)")
                            .foregroundColor(.secondary)
                    }
                }
            )
        }
    }
    
    private var audioSection: some View {
        Section(header: Text("音频")) {
            VStack {
                HStack {
                    Text("音量")
                    Spacer()
                    Text("\(Int(userSettings.volume * 100))%")
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: $userSettings.volume,
                    in: 0...1,
                    step: 0.1
                )
                .accentColor(.orange)
            }
        }
    }
    
    private var automationSection: some View {
        Section(header: Text("自动化")) {
            Toggle("自动开始休息", isOn: $userSettings.autoStartBreaks)
            Toggle("自动开始番茄钟", isOn: $userSettings.autoStartPomodoros)
            Toggle("启用通知", isOn: $userSettings.enableNotifications)
        }
    }
    
    private var statisticsSection: some View {
        Section(header: Text("统计数据")) {
            HStack {
                Text("总番茄钟数")
                Spacer()
                Text("\(userSettings.totalCompletedPomodoros)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("总学习时间")
                Spacer()
                Text(userSettings.formattedTotalStudyTime)
                    .foregroundColor(.secondary)
            }
            
            Button("重置统计数据") {
                userSettings.resetStatistics()
            }
            .foregroundColor(.red)
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("关于")) {
            HStack {
                Text("版本")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            Link("评价应用", destination: URL(string: "https://apps.apple.com")!)
            Link("联系开发者", destination: URL(string: "mailto:developer@lofitimer.com")!)
        }
    }
}

struct DurationPicker: View {
    let label: String
    @Binding var duration: TimeInterval
    let range: ClosedRange<Int>
    
    private var minutes: Int {
        Int(duration / 60)
    }
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Picker(label, selection: Binding(
                get: { minutes },
                set: { duration = TimeInterval($0 * 60) }
            )) {
                ForEach(range, id: \.self) { minute in
                    Text("\(minute) 分钟").tag(minute)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

#Preview {
    SettingsView(userSettings: UserSettings())
}