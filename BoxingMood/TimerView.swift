// TimerView.swift
// BoxingMood
//
// Created by Los on 9/5/25.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var timeRemaining = 180 // 3 minutes for a round
    @State private var timerActive = false
    @State private var currentRound = 1
    let totalRounds = 12
    let workDuration = 180 // 3 minutes
    let restDuration = 60  // 1 minute
    @State private var isResting = false
    
    // State to control the pulsating animation for the button's background
    @State private var pulsateButtonBackground = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 15) {
            // MARK: - Round / Rest Title
            Text(isResting ? "REST" : "ROUND \(currentRound)")
                .font(.custom("Impact", size: 36))
                .foregroundColor(isResting ? themeManager.currentTheme.text.opacity(0.8) : themeManager.currentTheme.secondary)

            // MARK: - Time Display
            Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                .font(.custom("Impact", size: 80))
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
                .onChange(of: timerActive) { isActive in
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
        .onReceive(timer) { _ in
            guard timerActive else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                if isResting {
                    isResting = false
                    currentRound += 1
                    timeRemaining = workDuration
                } else {
                    if currentRound < totalRounds {
                        isResting = true
                        timeRemaining = restDuration
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
        timeRemaining = workDuration
    }
}

// MARK: - Reusable Button Style Modifier
struct TimerButton: ViewModifier {
    let backgroundColor: Color
    var animationOpacity: Double?
    var foregroundColor: Color = .yellow

    func body(content: Content) -> some View {
        content
            .font(.custom("Impact", size: 18))
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
