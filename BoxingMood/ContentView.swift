import SwiftUI
import AVFoundation
import MediaPlayer

// Data structure for an inspirational quotes
struct Quote {
    let text: String
    let author: String
}

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var healthManager = HealthKitManager()
    @State private var showingSettings = false

    // A static array of inspirational quotes from boxing legends
    private static let quotes: [Quote] = [
        Quote(text: "The hands can’t hit what the eyes can’t see.", author: "Muhammad Ali"),
        Quote(text: "To be a champ you have to believe in yourself when no one else will.", author: "Sugar Ray Robinson"),
        Quote(text: "Float like a butterfly, sting like a bee.", author: "Muhammad Ali"),
        Quote(text: "The hero and the coward both feel the same thing, but the hero uses his fear.", author: "Cus D'Amato"),
        Quote(text: "Everyone has a plan 'till they get punched in the mouth.", author: "Mike Tyson"),
        Quote(text: "It's about how hard you can get hit and keep moving forward.", author: "Rocky Balboa")
    ]

    // State to hold the randomly selected quote for the app session
    @State private var inspirationalQuote: Quote

    // Initialize the view with a random quote. This runs once when the view is created.
    init() {
        // We use _inspirationalQuote to set the initial value of the State property
        _inspirationalQuote = State(initialValue: Self.quotes.randomElement()!)
    }

    @State private var selectedTab: String = "Fight"

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header with Title, Quote, and Avatar
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            // "Boxing Mood" text with red background
                            Text("Fight Fit")
                                .font(.system(size: 36, weight: .black, design: .default))
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.secondary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(themeManager.currentTheme.primary)
                                .cornerRadius(5)
                                .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                            
                            VStack(alignment: .leading) {
                                Text("\"\(inspirationalQuote.text)\"")
                                    .font(.system(size: 15, weight: .regular, design: .serif))
                                    .italic()
                                Text("- \(inspirationalQuote.author)")
                                    .font(.system(size: 12, weight: .bold, design: .serif))
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .foregroundColor(themeManager.currentTheme.text.opacity(0.9))
                            .padding(.top, 2)

                        }
                        Spacer()

                        Button(action: { showingSettings = true }) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(themeManager.currentTheme.primary)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(themeManager.currentTheme.primary, lineWidth: 2))
                        }
                        .sheet(isPresented: $showingSettings) {
                            SettingsView()
                                .environmentObject(themeManager)
                        }
                    }
                    .padding(.bottom, 10)

                    // MARK: - Timer Card
                    TimerView()
                        .frame(maxWidth: .infinity)
                        .modifier(CardBackground())

                        // MARK: - Media Player
                        MediaPlayerView()
                            .frame(maxWidth: .infinity)
                            .modifier(CardBackground())

                    // MARK: - Health Stats Cards
                    HStack(spacing: 16) {
                        StatCard(icon: "heart.fill", label: "Heart Rate", value: "\(Int(healthManager.heartRate)) BPM", color: themeManager.currentTheme.primary)
                        StatCard(icon: "flame.fill", label: "Calories", value: "\(Int(healthManager.activeCalories)) kCal", color: themeManager.currentTheme.secondary)
                    }

                    // MARK: - Start Workout Card
                    WorkoutCard()

                }
                .padding()

                // spacer so content doesn't hide behind floating tab bar
                Spacer().frame(height: 120)
            }
            .background(themeManager.currentTheme.background.edgesIgnoringSafeArea(.all))
            .preferredColorScheme(.light)

            // Floating Tab Bar
            FloatingTabBar(selected: $selectedTab)
                .padding(.bottom, 20)
                .padding(.horizontal, 16)
        }
    }
}


// MARK: - Reusable Views (CardBackground is updated)

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(.thickMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// ... (The rest of the file: StatCard, WorkoutCard, Preview remains the same)
struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Text(value)
                .font(.system(size: 28, weight: .black, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.yellow)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(CardBackground())
    }
}

struct WorkoutCard: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "figure.boxing")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Start Boxing Workout")
                .font(.system(size: 24, weight: .black, design: .default))
                .fontWeight(.bold)
                .foregroundColor(.yellow)
            Text("Begin a new session to track your performance in the Fitness app.")
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: {
                print("Start Workout Tapped!")
            }) {
                Text("START SESSION")
                    .font(.system(size: 20, weight: .black, design: .default))
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.yellow)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.yellow, lineWidth: 2)
                    )
            }
        }
        .modifier(CardBackground())
    }
}

// MARK: - Floating Tab Bar (5 items with centered Map pill)
struct FloatingTabBar: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var selected: String

    var body: some View {
        ZStack {
            // Background capsule
            HStack {
                Spacer()
            }
            .frame(height: 72)
            .background(.ultraThinMaterial)
            .background(RoundedRectangle(cornerRadius: 28).fill(themeManager.currentTheme.cardBackground).opacity(0.98))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(themeManager.currentTheme.cardBorder, lineWidth: 1))
            .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 6)

            HStack(alignment: .center) {
                sideButton(title: "Explore", system: "magnifyingglass")
                sideButton(title: "Community", system: "person.2")

                Spacer().frame(width: 56) // space for center pill

                sideButton(title: "Saved", system: "bookmark")
                sideButton(title: "Profile", system: "person.crop.circle")
            }
            .padding(.horizontal, 22)

            // Center Map Pill
            HStack {
                Button(action: { selected = "Navigate" }) {
                    HStack(spacing: 10) {
                        Image(systemName: "map")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.currentTheme.secondary)
                        Text("Map")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.currentTheme.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
                    .background(themeManager.currentTheme.primary)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 6)
                }
                .offset(y: -22)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .padding(.horizontal, 10)
    }

    @ViewBuilder
    private func sideButton(title: String, system: String) -> some View {
        Button(action: { selected = title }) {
            VStack(spacing: 4) {
                Image(systemName: system)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(selected == title ? themeManager.currentTheme.secondary : themeManager.currentTheme.text.opacity(0.75))
                Text(title)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(selected == title ? themeManager.currentTheme.secondary : themeManager.currentTheme.text.opacity(0.75))
            }
            .padding(.horizontal, 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - System Now-Playing Media Player
final class SystemMediaController: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var title: String = ""
    @Published var artist: String = ""
    @Published var artwork: UIImage?

    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private var timer: Timer?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStateChanged), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
        musicPlayer.beginGeneratingPlaybackNotifications()
        updateFromNowPlaying()
        startTimer()
    }

    deinit {
        stopTimer()
        musicPlayer.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func nowPlayingItemChanged() { updateFromNowPlaying() }
    @objc private func playbackStateChanged() { isPlaying = (musicPlayer.playbackState == .playing) }

    private func updateFromNowPlaying() {
        if let item = musicPlayer.nowPlayingItem {
            title = item.title ?? ""
            artist = item.artist ?? ""
            duration = item.playbackDuration
            if let art = item.artwork {
                artwork = art.image(at: CGSize(width: 200, height: 200))
            } else {
                artwork = nil
            }
            currentTime = musicPlayer.currentPlaybackTime
        } else {
            title = "Not Playing"
            artist = ""
            duration = 0
            artwork = nil
            currentTime = 0
        }
        isPlaying = (musicPlayer.playbackState == .playing)
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = self.musicPlayer.currentPlaybackTime
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func playPause() {
        if musicPlayer.playbackState == .playing {
            musicPlayer.pause()
            isPlaying = false
        } else {
            musicPlayer.play()
            isPlaying = true
        }
    }

    func seek(to seconds: Double) {
        musicPlayer.currentPlaybackTime = seconds
    }

    func skip(by seconds: Double) {
        var t = musicPlayer.currentPlaybackTime + seconds
        if t < 0 { t = 0 }
        if duration.isFinite && t > duration { t = duration }
        musicPlayer.currentPlaybackTime = t
    }
}

import AVKit

struct AVRoutePickerViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.prioritizesVideoDevices = false
        return view
    }
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

struct MediaPlayerView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var controller = SystemMediaController()

    var body: some View {
        HStack(spacing: 12) {
            if let img = controller.artwork {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(themeManager.currentTheme.primary)
                    .frame(width: 64, height: 64)
                    .overlay(Text("🎧").font(.largeTitle))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(controller.title.isEmpty ? "No Media" : controller.title)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.text)
                Text(controller.artist)
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.text.opacity(0.7))

                Slider(value: Binding(get: { controller.currentTime }, set: { newVal in controller.seek(to: newVal) }), in: 0...max(1, controller.duration))
                    .accentColor(themeManager.currentTheme.primary)

                HStack {
                    Text(timeString(controller.currentTime))
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.text.opacity(0.7))
                    Spacer()
                    Text(timeString(controller.duration))
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.text.opacity(0.7))
                }
            }

            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button(action: { controller.skip(by: -15) }) {
                        Image(systemName: "gobackward.15")
                            .foregroundColor(themeManager.currentTheme.secondary)
                    }

                    Button(action: { controller.playPause() }) {
                        Image(systemName: controller.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(themeManager.currentTheme.secondary)
                            .padding(10)
                            .background(themeManager.currentTheme.primary)
                            .clipShape(Circle())
                    }

                    Button(action: { controller.skip(by: 15) }) {
                        Image(systemName: "goforward.15")
                            .foregroundColor(themeManager.currentTheme.secondary)
                    }
                }

                AVRoutePickerViewRepresentable()
                    .frame(width: 120, height: 24)
            }
        }
        .padding()
    }

    private func timeString(_ t: Double) -> String {
        guard t.isFinite else { return "00:00" }
        let s = Int(t)
        return String(format: "%02d:%02d", s / 60, s % 60)
    }
}


#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
