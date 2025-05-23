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
                        Button(action: {
                            // Validate and handle login
                            if validateInput() {
                                print("ChildLogin: Login validated - Starting login process")
                                // In a real app, we would authenticate with a server
                                // For now, just log in

                                // The user role is already set in LoginSelector
                                // Just verify it's correct
                                let currentRole = UserDefaults.standard.string(forKey: "user_role")
                                if currentRole != "child" {
                                    print("ChildLogin: Warning - user role was not child, setting it now")
                                    print("ChildLogin: Role changed from \(currentRole ?? "nil") to child, posting notification")

                                    UserDefaults.standard.set("child", forKey: "user_role")
                                    UserDefaults.standard.synchronize()

                                    // Post notification that user role changed
                                    NotificationCenter.default.post(name: Notification.Name("UserRoleChanged"), object: nil)
                                } else {
                                    print("ChildLogin: User role is already child")
                                }

                                // First dismiss the login view to prevent navigation issues
                                print("ChildLogin: Dismissing login view")
                                presentationMode.wrappedValue.dismiss()

                                // Set logged in state after a short delay to ensure the view is dismissed
                                print("ChildLogin: Will set isLoggedIn to true after dismissal")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    print("ChildLogin: Setting isLoggedIn to true")
                                    appState.isLoggedIn = true
                                    print("ChildLogin: Login complete, isLoggedIn=\(appState.isLoggedIn)")
                                }
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

                        // No longer need a NavigationLink since we're using app state
                    }
                    .padding(.horizontal, 30)

                    // Developer bypass button (only in development)
                    #if DEBUG
                    Button(action: {
                        print("ChildLogin: Developer bypass - Starting login process")

                        // The user role is already set in LoginSelector
                        // Just verify it's correct
                        let currentRole = UserDefaults.standard.string(forKey: "user_role")
                        if currentRole != "child" {
                            print("ChildLogin: Developer bypass - Warning: user role was not child, setting it now")
                            print("ChildLogin: Developer bypass - Role changed from \(currentRole ?? "nil") to child, posting notification")

                            UserDefaults.standard.set("child", forKey: "user_role")
                            UserDefaults.standard.synchronize()

                            // Post notification that user role changed
                            NotificationCenter.default.post(name: Notification.Name("UserRoleChanged"), object: nil)
                        } else {
                            print("ChildLogin: Developer bypass - User role is already child")
                        }

                        // First dismiss the login view to prevent navigation issues
                        print("ChildLogin: Developer bypass - Dismissing login view")
                        presentationMode.wrappedValue.dismiss()

                        // Set logged in state after a short delay to ensure the view is dismissed
                        print("ChildLogin: Developer bypass - Will set isLoggedIn to true after dismissal")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            print("ChildLogin: Developer bypass - Setting isLoggedIn to true")
                            appState.isLoggedIn = true
                            print("ChildLogin: Developer bypass - Login complete, isLoggedIn=\(appState.isLoggedIn)")
                        }
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
