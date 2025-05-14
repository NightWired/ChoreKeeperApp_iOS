//
//  SplashScreen.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI

// App logo image view
struct AppLogoImageView: View {
    let opacity: Double

    var body: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 250) // 250px wide as requested
            .opacity(opacity)
    }
}

// Developer logo image view
struct DeveloperLogoImageView: View {
    let opacity: Double

    var body: some View {
        Image("DeveloperLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 200) // 200px wide as requested
            .opacity(opacity)
    }
}

struct SplashScreen: View {
    // Animation state variables
    @State private var backgroundOpacity = 0.0
    @State private var appLogoOpacity = 0.0
    @State private var developerContentOpacity = 0.0
    @State private var isBlackVisible = false

    // Animation phase tracking
    @State private var currentPhase = 0

    // Environment object for theme
    @EnvironmentObject var themeManager: ThemeManager

    // Callback for when splash screen should dismiss
    var onSplashComplete: () -> Void

    // Timer to track minimum display time (15 seconds total)
    private let minimumDisplayTime: Double = 15.0

    // Fixed colors for splash screen
    private let finalBackgroundColor = Color(white: 0.95) // Pale grey as originally requested
    private let textColor = Color.black // Black text as originally requested

    var body: some View {
        ZStack {
            // Initial background that matches the theme
            Color("BackgroundColor")
                .ignoresSafeArea()

            // Black overlay that appears at the start of transition
            Color.black
                .opacity(isBlackVisible ? 1.0 : 0.0)
                .ignoresSafeArea()

            // Final background color (pale grey) that fades in
            finalBackgroundColor
                .opacity(backgroundOpacity)
                .ignoresSafeArea()

            // First phase: App Logo
            AppLogoImageView(opacity: appLogoOpacity)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Second phase: "Powered by" text and Developer Logo
            VStack(spacing: 10) {
                // "Powered by" text
                Text("Powered by")
                    .font(.custom("Avenir-Medium", size: 18))
                    .foregroundColor(textColor)

                // Developer Logo below the text
                DeveloperLogoImageView(opacity: 1.0)
            }
            .opacity(developerContentOpacity)
        }
        .onAppear {
            // Start animations when view appears
            startAnimations()

            // Set minimum display time
            DispatchQueue.main.asyncAfter(deadline: .now() + minimumDisplayTime) {
                self.onSplashComplete()
            }
        }
    }

    private func startAnimations() {
        // Step 1: Show black background immediately
        withAnimation(.easeIn(duration: 0.1)) {
            isBlackVisible = true
        }

        // Step 2: After a short delay, start transitioning to pale grey
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 3.0)) {
                backgroundOpacity = 1.0
            }
        }

        // Phase 1: Fade in App Logo (3s fade-in)
        withAnimation(.easeIn(duration: 3.0).delay(0.6)) {
            appLogoOpacity = 1.0
        }

        // Hold App Logo for 3s, then fade out (3s fade-out)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.6) {
            withAnimation(.easeOut(duration: 3.0)) {
                appLogoOpacity = 0.0
            }
        }

        // Phase 2: Fade in "Powered by" text and Developer Logo (3s fade-in)
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.6) {
            withAnimation(.easeIn(duration: 3.0)) {
                developerContentOpacity = 1.0
            }
        }

        // Hold for at least 3s before transitioning to main app
        // (This is handled by the minimumDisplayTime of 15s)
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(onSplashComplete: {})
            .environmentObject(ThemeManager())
            .previewDisplayName("Splash Screen")
    }
}
