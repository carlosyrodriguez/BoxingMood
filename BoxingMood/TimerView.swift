// TimerView.swift
// BoxingMood
//
// Created by Los on 9/5/25.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // Editable timer settings (driven by profiles / edit sheet)
    @State private var rounds: Int = 12
    @State private var roundDurationSeconds: Int = 180 // 3:00
    @State private var restDurationSeconds: Int = 60 // 1:00
    @State private var prepareDurationSeconds: Int = 25 // 0:25
    @State private var roundEndWarningSeconds: Int = 10 // 0:10

    // Runtime state
    @State private var timeRemaining = 180
    @State private var timerActive = false
    @State private var currentRound = 1
    @State private var isResting = false
    
    // State to control the pulsating animation for the button's background
    @State private var pulsateButtonBackground = false

    // UI state for editing / profiles
    @State private var showEditSheet = false
    @State private var showSecondsEditor = false
    @State private var editorTarget: String? = nil // "round", "rest", "prepare", "warning"
    @State private var editorMinutes: Int = 0
    @State private var editorSeconds: Int = 0

    struct TimerProfile: Identifiable {
        let id = UUID()
        var name: String
        var rounds: Int
        var roundSeconds: Int
        var restSeconds: Int
        var prepareSeconds: Int
        var warningSeconds: Int
    }

    private var profiles: [TimerProfile] {
        [
            TimerProfile(name: "Boxing", rounds: 12, roundSeconds: 180, restSeconds: 60, prepareSeconds: 25, warningSeconds: 10),
            TimerProfile(name: "MMA", rounds: 5, roundSeconds: 300, restSeconds: 60, prepareSeconds: 30, warningSeconds: 10),
            TimerProfile(name: "Muay Thai", rounds: 5, roundSeconds: 180, restSeconds: 120, prepareSeconds: 30, warningSeconds: 10),
            TimerProfile(name: "Kickboxing", rounds: 10, roundSeconds: 180, restSeconds: 60, prepareSeconds: 25, warningSeconds: 10),
        ]
    }

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Spacer()
                Menu {
                    // Profile picker inside menu
                    ForEach(profiles) { profile in
                        Button(profile.name) {
                            applyProfile(profile)
                        }
                    }
                    Divider()
                    Button("Edit Timers") { showEditSheet = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(themeManager.currentTheme.primary)
                }
                .padding(.trailing, 6)
            }

            // MARK: - Round / Rest Title
            Text(isResting ? "REST" : "ROUND \(currentRound)")
                .font(.system(size: 36, weight: .black, design: .default))
                .foregroundColor(isResting ? themeManager.currentTheme.text.opacity(0.8) : themeManager.currentTheme.secondary)

            // MARK: - Time Display
            Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                .font(.system(size: 80, weight: .black, design: .default))
                .foregroundColor(themeManager.currentTheme.primary)

            // MARK: - Control Buttons
            HStack(spacing: 20) {
                // Start / Pause Button
                Button(action: {
                    timerActive.toggle()
                }) {
                    Text(timerActive ? "PAUSE" : "START")
                        .modifier(TimerButton(
                            backgroundColor: themeManager.currentTheme.primary,
                            animationOpacity: timerActive ? (pulsateButtonBackground ? 0.3 : 1.0) : nil,
                            foregroundColor: themeManager.currentTheme.secondary
                        ))
                }
                .onChange(of: timerActive) { isActive, _ in
                    // This logic ensures the animation state is tied directly to the timer.
                    if isActive {
                        // Start animation loop when timer becomes active.
                        withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                            pulsateButtonBackground = true
                        }
                    } else {
                        // Stop animation loop and reset state when timer is no longer active.
                        withAnimation {
                            pulsateButtonBackground = false
                        }
                    }
                }

                // Reset Button
                Button(action: resetTimer) {
                    Text("RESET")
                        .modifier(TimerButton(backgroundColor: themeManager.currentTheme.cardBackground, foregroundColor: themeManager.currentTheme.secondary))
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationView {
                Form {
                    Section(header: Text("Profile")) {
                        Picker("Profile", selection: Binding(get: { "Custom" }, set: { _ in })) {
                            ForEach(profiles) { profile in
                                HStack {
                                    Text(profile.name)
                                    Spacer()
                                    Text("\(profile.rounds) x \(formatSeconds(profile.roundSeconds))")
                                        .foregroundColor(.gray)
                                }
                                .tag(profile.name)
                            }
                        }
                        .pickerStyle(.inline)
                    }

                    Section(header: Text("Timers")) {
                        Stepper(value: $rounds, in: 1...99) {
                            HStack { Text("Rounds:") ; Spacer() ; Text("\(rounds)") }
                        }

                        HStack {
                            Text("Round Time:")
                            Spacer()
                            Text(formatSeconds(roundDurationSeconds))
                            Button(action: { openSecondsEditor(for: "round") }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { editSeconds(&roundDurationSeconds) }

                        HStack {
                            Text("Rest Time:")
                            Spacer()
                            Text(formatSeconds(restDurationSeconds))
                            Button(action: { openSecondsEditor(for: "rest") }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { editSeconds(&restDurationSeconds) }

                        HStack {
                            Text("Prepare:")
                            Spacer()
                            Text(formatSeconds(prepareDurationSeconds))
                            Button(action: { openSecondsEditor(for: "prepare") }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { editSeconds(&prepareDurationSeconds) }

                        HStack {
                            Text("Round End Warning:")
                            Spacer()
                            Text(formatSeconds(roundEndWarningSeconds))
                            Button(action: { openSecondsEditor(for: "warning") }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { editSeconds(&roundEndWarningSeconds) }
                    }
                }
                .navigationTitle("Timer Settings")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showEditSheet = false }
                    }
                }
            }
            .accentColor(themeManager.currentTheme.primary)
        }
        .sheet(isPresented: $showSecondsEditor) {
            NavigationView {
                VStack(spacing: 20) {
                    Text(editorTarget ?? "")
                        .font(.title2)
                        .padding(.top)

                    HStack {
                        Stepper("Minutes: \(editorMinutes)", value: $editorMinutes, in: 0...59)
                    }

                    HStack {
                        Stepper("Seconds: \(editorSeconds)", value: $editorSeconds, in: 0...59)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle("Edit Time")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showSecondsEditor = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { commitEditor() }
                    }
                }
            }
            .accentColor(themeManager.currentTheme.primary)
        }
        .onReceive(timer) { _ in
            guard timerActive else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                if isResting {
                    isResting = false
                    currentRound += 1
                    timeRemaining = roundDurationSeconds
                } else {
                    if currentRound < rounds {
                        isResting = true
                        timeRemaining = restDurationSeconds
                    } else {
                        resetTimer()
                    }
                }
            }
        }
    }
    
    /// Resets the timer to its initial state.
    func resetTimer() {
        timerActive = false
        isResting = false
        currentRound = 1
        timeRemaining = roundDurationSeconds
    }

    // MARK: - Helpers
    private func applyProfile(_ profile: TimerProfile) {
        rounds = profile.rounds
        roundDurationSeconds = profile.roundSeconds
        restDurationSeconds = profile.restSeconds
        prepareDurationSeconds = profile.prepareSeconds
        roundEndWarningSeconds = profile.warningSeconds

        // reset runtime to use new values
        currentRound = 1
        isResting = false
        timeRemaining = roundDurationSeconds
    }

    private func formatSeconds(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }

    // A simple editor that increments/decrements seconds via an alert-style prompt.
    // For simplicity we'll just toggle presets using a sheet; here we'll present
    // a quick action sheet replaced by a simple picker-like loop in real app.
    private func editSeconds(_ value: inout Int) {
        // For a fast implementation in this editor environment, cycle through common presets
        let presets = [10, 15, 20, 25, 30, 45, 60, 90, 120, 180, 300]
        if let currentIndex = presets.firstIndex(of: value) {
            let next = presets[(currentIndex + 1) % presets.count]
            value = next
        } else {
            value = presets.first ?? value
        }
    }

    // Open the proper minutes/seconds editor for a target variable
    private func openSecondsEditor(for target: String) {
        editorTarget = target
        switch target {
        case "round":
            editorMinutes = roundDurationSeconds / 60
            editorSeconds = roundDurationSeconds % 60
        case "rest":
            editorMinutes = restDurationSeconds / 60
            editorSeconds = restDurationSeconds % 60
        case "prepare":
            editorMinutes = prepareDurationSeconds / 60
            editorSeconds = prepareDurationSeconds % 60
        case "warning":
            editorMinutes = roundEndWarningSeconds / 60
            editorSeconds = roundEndWarningSeconds % 60
        default:
            editorMinutes = 0
            editorSeconds = 0
        }
        showSecondsEditor = true
    }

    private func commitEditor() {
        let total = editorMinutes * 60 + editorSeconds
        switch editorTarget {
        case "round": roundDurationSeconds = total
        case "rest": restDurationSeconds = total
        case "prepare": prepareDurationSeconds = total
        case "warning": roundEndWarningSeconds = total
        default: break
        }
        // If editing the round time, update runtime if not active
        if !timerActive {
            timeRemaining = roundDurationSeconds
        }
        showSecondsEditor = false
        editorTarget = nil
    }
}

// MARK: - Reusable Button Style Modifier
struct TimerButton: ViewModifier {
    let backgroundColor: Color
    var animationOpacity: Double?
    var foregroundColor: Color = .yellow

    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .black, design: .default))
            .padding(.vertical, 12)
            .frame(width: 120)
            .background(backgroundColor.opacity(animationOpacity ?? 1.0))
            .foregroundColor(foregroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(foregroundColor, lineWidth: 2)
            )
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
