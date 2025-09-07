import SwiftUI

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
                                .font(.custom("Impact", size: 36))
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.secondary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(themeManager.currentTheme.primary)
                                .cornerRadius(5)
                                .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                            
                            VStack(alignment: .leading) {
                                Text("\"\(inspirationalQuote.text)\"")
                                    .font(.custom("AmericanTypewriter", size: 15))
                                    .italic()
                                Text("- \(inspirationalQuote.author)")
                                    .font(.custom("AmericanTypewriter", size: 12))
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
                    .font(.custom("AmericanTypewriter", size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Text(value)
                .font(.custom("Impact", size: 28))
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
                .font(.custom("Impact", size: 24))
                .fontWeight(.bold)
                .foregroundColor(.yellow)
            Text("Begin a new session to track your performance in the Fitness app.")
                .font(.custom("AmericanTypewriter", size: 15))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: {
                print("Start Workout Tapped!")
            }) {
                Text("START SESSION")
                    .font(.custom("Impact", size: 20))
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

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var selected: String

    var body: some View {
        HStack(spacing: 32) {
            tabButton(title: "Fight", system: "bolt.fill")
            tabButton(title: "Events", system: "calendar")
            tabButton(title: "More", system: "ellipsis")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 18)
        .background(.ultraThinMaterial)
        .background(RoundedRectangle(cornerRadius: 30).fill(themeManager.currentTheme.cardBackground).opacity(0.9))
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(themeManager.currentTheme.cardBorder, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }

    @ViewBuilder
    private func tabButton(title: String, system: String) -> some View {
        Button(action: { selected = title }) {
            VStack(spacing: 4) {
                Image(systemName: system)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(selected == title ? themeManager.currentTheme.secondary : themeManager.currentTheme.text.opacity(0.8))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(selected == title ? themeManager.currentTheme.secondary : themeManager.currentTheme.text.opacity(0.8))
            }
            .padding(.horizontal, 6)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
