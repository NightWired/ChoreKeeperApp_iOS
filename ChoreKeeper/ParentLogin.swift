//
//  ParentLogin.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI
import LocalizationHandler
import ErrorHandler

// Import RefreshTrigger
extension RefreshTrigger {}

struct SocialLoginButton: View {
    enum SocialLoginType {
        case apple, google, facebook

        var imageName: String {
            switch self {
            case .apple: return "apple.logo"
            case .google: return "g.circle"
            case .facebook: return "f.circle"
            }
        }

        var localizationKey: String {
            switch self {
            case .apple: return "auth.login_with_apple"
            case .google: return "auth.login_with_google"
            case .facebook: return "auth.login_with_facebook"
            }
        }

        var providerName: String {
            switch self {
            case .apple: return "Apple"
            case .google: return "Google"
            case .facebook: return "Facebook"
            }
        }

        var backgroundColor: Color {
            switch self {
            case .apple: return .black
            case .google: return Color(red: 0.95, green: 0.95, blue: 0.95)
            case .facebook: return Color(red: 0.23, green: 0.35, blue: 0.6)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .google: return .black
            default: return .white
            }
        }
    }

    let type: SocialLoginType
    let action: () -> Void
    @ObservedObject private var refreshTrigger = RefreshTrigger.shared

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.imageName)
                    .font(.system(size: 18))
                Text(type.providerName)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(type.backgroundColor)
            .foregroundColor(type.foregroundColor)
            .cornerRadius(8)
        }
        .id("\(type.localizationKey)_\(refreshTrigger.refreshID)")
    }
}

struct ParentLogin: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var navigateToDashboard = false
    @ObservedObject private var refreshTrigger = RefreshTrigger.shared
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            // Background
            Color("BackgroundColor")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // App Logo
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .padding(.top, 20)

                    // Login Form
                    VStack(spacing: 20) {
                        Text(LocalizationHandler.localize("auth.login"))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextColor"))

                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizationHandler.localize("auth.email"))
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))

                            TextField("", text: $email)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizationHandler.localize("auth.password"))
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))

                            SecureField("", text: $password)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }

                        // Forgot password link
                        HStack {
                            Spacer()
                            Button(action: {
                                // Handle forgot password
                            }) {
                                Text(LocalizationHandler.localize("auth.forgot_password"))
                                    .font(.subheadline)
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }

                        // Login button
                        NavigationLink(destination: ParentDashboard(), isActive: $navigateToDashboard) {
                            Button(action: {
                                // Validate and handle login
                                if validateInput() {
                                    // In a real app, we would authenticate with a server
                                    // For now, just navigate to dashboard
                                    appState.isLoggedIn = true
                                    navigateToDashboard = true
                                }
                            }) {
                                Text(LocalizationHandler.localize("auth.login"))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("AccentColor"))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 30)

                    // Social login section
                    VStack(spacing: 15) {
                        Text(LocalizationHandler.localize("auth.or_continue_with"))
                            .font(.subheadline)
                            .foregroundColor(Color("SecondaryTextColor"))

                        // Social login buttons
                        SocialLoginButton(type: .apple) {
                            // Handle Apple login
                            showLoginNotImplemented()
                        }

                        SocialLoginButton(type: .google) {
                            // Handle Google login
                            showLoginNotImplemented()
                        }

                        SocialLoginButton(type: .facebook) {
                            // Handle Facebook login
                            showLoginNotImplemented()
                        }
                    }
                    .padding(.horizontal, 30)

                    // Developer bypass button (only in development)
                    #if DEBUG
                    Button(action: {
                        appState.isLoggedIn = true
                        navigateToDashboard = true
                    }) {
                        Text("Developer Bypass")
                            .font(.caption)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                    #endif

                    Spacer()

                    // Back button at the bottom
                    Button(action: {
                        // Use presentation mode to go back
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16))
                            Text(LocalizationHandler.localize("common.back"))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("AccentColor").opacity(0.2))
                        .foregroundColor(Color("AccentColor"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 30)
            }

            // Language selection button in top right corner
            VStack {
                HStack {
                    Spacer()

                    // Language selection
                    LanguageSelector(displayMode: .iconButton)
                        .padding(.trailing, 16)
                }
                .padding(.top, 16)

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(LocalizationHandler.localize("common.info")),
                message: Text(alertMessage),
                dismissButton: .default(Text(LocalizationHandler.localize("common.ok")))
            )
        }
    }

    private func validateInput() -> Bool {
        // Simple validation
        if email.isEmpty {
            alertMessage = "Please enter your email"
            showingAlert = true
            return false
        }

        if password.isEmpty {
            alertMessage = "Please enter your password"
            showingAlert = true
            return false
        }

        return true
    }

    private func showLoginNotImplemented() {
        alertMessage = "Social login is not implemented in this version"
        showingAlert = true
    }
}

struct ParentLogin_Previews: PreviewProvider {
    static var previews: some View {
        ParentLogin()
            .environmentObject(AppState())
    }
}
