//
//  AppTransitions.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-18.
//

import SwiftUI

/// Centralized transition settings for the app
enum AppTransitions {
    /// Default duration for view transitions
    static let duration: Double = 0.3

    /// Default animation curve for view transitions
    static let animation: Animation = .easeInOut(duration: duration)

    /// Zoom transition for view navigation (only applied to post-login views)
    static var zoom: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 1.0).combined(with: .opacity),
            removal: .scale(scale: 0.7).combined(with: .opacity)
        )
    }

    /// Fade transition for login/logout
    static var fade: AnyTransition {
        .opacity
    }
}

/// Extension to apply the appropriate transition to a view
extension View {
    /// Applies the zoom transition to post-login views
    func withZoomTransition() -> some View {
        self.transition(AppTransitions.zoom)
            .animation(AppTransitions.animation, value: UUID())
    }
}