//
//  SplashScreen.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI

// Logo image view that uses proper asset management
struct LogoImageView: View {
    let opacity: Double

    var body: some View {
        // Use system image as a placeholder
        // In a real implementation, you would add the logo to Assets.xcassets
        // and use Image("DarklightLogo") instead
        Image("DeveloperLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 200) // Reduced from 250px to 200px as requested
            .foregroundColor(.white)
            .opacity(opacity)
    }
}

struct SplashScreen: View {
    // Animation state variables
    @State private var backgroundOpacity = 0.0
    @State private var contentOpacity = 0.0
    @State private var isActive = false
    @State private var isBlackVisible = false

    // Environment object for theme
    @EnvironmentObject var themeManager: ThemeManager

    // Callback for when splash screen should dismiss
    var onSplashComplete: () -> Void

    // Timer to track minimum display time (4 seconds after transition completes)
    private let minimumDisplayTime: Double = 7.0 // 3s for transition + 4s display time

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

            // Content stack with app name, "Powered by" text, and logo
            VStack(spacing: 20) {
                // App name in a fun but professional font
                Text("ChoreKeeper")
                    .font(.custom("Avenir-Heavy", size: 36))
                    .foregroundColor(textColor) // Always black as requested
                    .frame(maxWidth: 250)

                // "Powered by" text at half the size
                Text("Powered by")
                    .font(.custom("Avenir-Medium", size: 18))
                    .foregroundColor(textColor) // Always black as requested

                // Logo below the text
                LogoImageView(opacity: 1.0) // Always full opacity since parent VStack controls opacity
            }
            .opacity(contentOpacity) // Initially invisible
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

        // Step 3: Fade in content (text and logo) slightly delayed
        withAnimation(.easeIn(duration: 3.0).delay(0.6)) {
            contentOpacity = 1.0
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(onSplashComplete: {})
            .environmentObject(ThemeManager())
    }
}
