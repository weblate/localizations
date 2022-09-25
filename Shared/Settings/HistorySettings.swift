import Defaults
import SwiftUI

struct HistorySettings: View {
    static let watchedThresholds = [50, 60, 70, 80, 90, 95, 100]

    @State private var presentingClearHistoryConfirmation = false

    @EnvironmentObject<PlayerModel> private var player

    @Default(.saveRecents) private var saveRecents
    @Default(.saveLastPlayed) private var saveLastPlayed
    @Default(.saveHistory) private var saveHistory
    @Default(.showWatchingProgress) private var showWatchingProgress
    @Default(.watchedThreshold) private var watchedThreshold
    @Default(.watchedVideoStyle) private var watchedVideoStyle
    @Default(.watchedVideoBadgeColor) private var watchedVideoBadgeColor
    @Default(.watchedVideoPlayNowBehavior) private var watchedVideoPlayNowBehavior
    @Default(.resetWatchedStatusOnPlaying) private var resetWatchedStatusOnPlaying

    var body: some View {
        Group {
            #if os(macOS)
                sections
            #else
                List {
                    sections
                }
            #endif
        }
        #if os(tvOS)
        .frame(maxWidth: 1000)
        #elseif os(iOS)
        .listStyle(.insetGrouped)
        #endif
        .navigationTitle("History")
    }

    private var sections: some View {
        Group {
            #if os(tvOS)
                Section(header: SettingsHeader(text: NSLocalizedString("History", tableName: "Localizable", bundle: .main, comment: ""))) {
                    Toggle("Save history of searches, channels and playlists", isOn: $saveRecents)
                    Toggle("Save history of played videos", isOn: $saveHistory)
                    Toggle("Show progress of watching on thumbnails", isOn: $showWatchingProgress)
                        .disabled(!saveHistory)

                    watchedVideoPlayNowBehaviorPicker

                    watchedThresholdPicker
                    resetWatchedStatusOnPlayingToggle
                    watchedVideoStylePicker
                    watchedVideoBadgeColorPicker
                }
            #else
                Section(header: SettingsHeader(text: NSLocalizedString("History", tableName: "Localizable", bundle: .main, comment: ""))) {
                    Toggle("Save history of searches, channels and playlists", isOn: $saveRecents)
                    Toggle("Save history of played videos", isOn: $saveHistory)
                    Toggle("Show progress of watching on thumbnails", isOn: $showWatchingProgress)
                        .disabled(!saveHistory)
                    Toggle("Keep last played video in the queue after restart", isOn: $saveLastPlayed)
                }

                Section(header: SettingsHeader(text: NSLocalizedString("Watched", tableName: "Localizable", bundle: .main, comment: ""))) {
                    watchedVideoPlayNowBehaviorPicker
                    #if os(macOS)
                    .padding(.top, 1)
                    #endif
                    watchedThresholdPicker
                    resetWatchedStatusOnPlayingToggle
                }

                Section(header: SettingsHeader(text: NSLocalizedString("Interface", tableName: "Localizable", bundle: .main, comment: ""))) {
                    watchedVideoStylePicker
                    #if os(macOS)
                    .padding(.top, 1)
                    #endif
                    watchedVideoBadgeColorPicker
                }

                #if os(macOS)
                    Spacer()
                #endif
            #endif

            clearHistoryButton
        }
    }

    private var watchedThresholdPicker: some View {
        Section(header: SettingsHeader(text: NSLocalizedString("Mark video as watched after playing", tableName: "Localizable", bundle: .main, comment: ""), secondary: true)) {
            Picker("Mark video as watched after playing", selection: $watchedThreshold) {
                ForEach(Self.watchedThresholds, id: \.self) { threshold in
                    Text("\(threshold)%").tag(threshold)
                }
            }
            .disabled(!saveHistory)
            .modifier(SettingsPickerModifier())
        }
    }

    private var watchedVideoStylePicker: some View {
        Section(header: SettingsHeader(text: NSLocalizedString("Mark watched videos with", tableName: "Localizable", bundle: .main, comment: ""), secondary: true)) {
            Picker("Mark watched videos with", selection: $watchedVideoStyle) {
                Text("Nothing").tag(WatchedVideoStyle.nothing)
                Text("Badge").tag(WatchedVideoStyle.badge)
                Text("Decreased opacity").tag(WatchedVideoStyle.decreasedOpacity)
                Text("Badge & Decreased opacity").tag(WatchedVideoStyle.both)
            }
            .disabled(!saveHistory)
            .modifier(SettingsPickerModifier())
        }
    }

    private var watchedVideoBadgeColorPicker: some View {
        Section(header: SettingsHeader(text: NSLocalizedString("Badge color", tableName: "Localizable", bundle: .main, comment: ""), secondary: true)) {
            Picker("Badge color", selection: $watchedVideoBadgeColor) {
                Text("Based on system color scheme").tag(WatchedVideoBadgeColor.colorSchemeBased)
                Text("Blue").tag(WatchedVideoBadgeColor.blue)
                Text("Red").tag(WatchedVideoBadgeColor.red)
            }
            .disabled(!saveHistory)
            .disabled(watchedVideoStyle == .decreasedOpacity)
            .disabled(watchedVideoStyle == .nothing)
            .modifier(SettingsPickerModifier())
        }
    }

    private var watchedVideoPlayNowBehaviorPicker: some View {
        Section(header: SettingsHeader(text: NSLocalizedString("When partially watched video is played", tableName: "Localizable", bundle: .main, comment: ""), secondary: true)) {
            Picker("When partially watched video is played", selection: $watchedVideoPlayNowBehavior) {
                Text("Continue").tag(WatchedVideoPlayNowBehavior.continue)
                Text("Restart").tag(WatchedVideoPlayNowBehavior.restart)
            }
            .disabled(!saveHistory)
            .modifier(SettingsPickerModifier())
        }
    }

    private var resetWatchedStatusOnPlayingToggle: some View {
        Toggle("Reset watched status when playing again", isOn: $resetWatchedStatusOnPlaying)
            .disabled(!saveHistory)
    }

    private var clearHistoryButton: some View {
        Button("Clear History") {
            presentingClearHistoryConfirmation = true
        }
        .alert(isPresented: $presentingClearHistoryConfirmation) {
            Alert(
                title: Text(
                    "Are you sure you want to clear history of watched videos?"
                ),
                message: Text(
                    "This cannot be reverted. You might need to switch between views or restart the app to see changes."
                ),
                primaryButton: .destructive(Text("Clear All")) {
                    player.removeAllWatches()
                    presentingClearHistoryConfirmation = false
                },
                secondaryButton: .cancel()
            )
        }
        .foregroundColor(.red)
    }
}

struct HistorySettings_Previews: PreviewProvider {
    static var previews: some View {
        HistorySettings()
            .injectFixtureEnvironmentObjects()
    }
}
