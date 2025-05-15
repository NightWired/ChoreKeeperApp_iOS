//
//  ChildLogin.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI
import LocalizationHandler
import ErrorHandler

// Import RefreshTrigger
extension RefreshTrigger {}

struct ChildLogin: View {
    @State private var username = ""
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

                    // Child-friendly character
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color("SecondaryAccentColor"))
                        .padding()
                        .background(Color("SecondaryAccentColor").opacity(0.2))
                        .clipShape(Circle())

                    // Login Form
                    VStack(spacing: 20) {
                        Text(LocalizationHandler.localize("auth.login"))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextColor"))

                        // Username field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizationHandler.localize("auth.username"))
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))

                            TextField("", text: $username)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
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

                        // Login button
                        NavigationLink(destination: ChildDashboard(), isActive: $navigateToDashboard) {
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
                                    .background(Color("SecondaryAccentColor"))
                                    .cornerRadius(8)
                            }
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
                        .background(Color("SecondaryAccentColor").opacity(0.2))
                        .foregroundColor(Color("SecondaryAccentColor"))
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
        if username.isEmpty {
            alertMessage = "Please enter your username"
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
}

struct ChildLogin_Previews: PreviewProvider {
    static var previews: some View {
        ChildLogin()
            .environmentObject(AppState())
    }
}
