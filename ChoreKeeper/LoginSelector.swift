//
//  LoginSelector.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI
import LocalizationHandler

// Import RefreshTrigger from LanguageSelector.swift
extension RefreshTrigger {}

struct LoginSelector: View {
    @ObservedObject private var refreshTrigger = RefreshTrigger.shared
    @EnvironmentObject private var appState: AppState
    @State private var showChildLogin = false
    @State private var showParentLogin = false

    var body: some View {
        ZStack {
            // Background
            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // App Logo
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(.top, 40)

                // "I am a..." text
                Text(LocalizationHandler.localize("onboarding.userType.title"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextColor"))
                    .padding(.top, 20)

                // Buttons container
                VStack(spacing: 20) {
                    // Child button
                    Button(action: {
                        let newRole = "child";
                        // Set the user role to child
                        UserDefaults.standard.set(newRole, forKey: "user_role")
                        UserDefaults.standard.synchronize()
                        print("LoginSelector: Set user role to child")
                        
                        print("LoginSelector: Role changed to child, posting notification")
                        NotificationCenter.default.post(name: Notification.Name("UserRoleChanged"), object: nil, userInfo: ["role": newRole])

                        showChildLogin = true
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                            Text(LocalizationHandler.localize("onboarding.userType.child"))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("SecondaryAccentColor").opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }

                    // Parent button
                    Button(action: {
                        let newRole = "parent";
                        // Set the user role to parent
                        UserDefaults.standard.set(newRole, forKey: "user_role")
                        UserDefaults.standard.synchronize()
                        print("LoginSelector: Set user role to parent")
                        
                        print("LoginSelector: Role changed to parent, posting notification")
                        NotificationCenter.default.post(name: Notification.Name("UserRoleChanged"), object: nil, userInfo: ["role": newRole])

                        showParentLogin = true
                    }) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 24))
                            Text(LocalizationHandler.localize("onboarding.userType.parent"))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentColor").opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }

            // Language selection button in top right corner
            VStack {
                HStack {
                    Spacer()
                    LanguageSelector(displayMode: .iconButton)
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                }
                Spacer()
            }

            // Navigation links (hidden)
            NavigationLink(destination: ChildLogin(), isActive: $showChildLogin) {
                EmptyView()
            }

            NavigationLink(destination: ParentLogin(), isActive: $showParentLogin) {
                EmptyView()
            }
        }
        .onAppear {
            print("LoginSelector appeared - isLoggedIn: \(appState.isLoggedIn)")

            // Do NOT reset isLoggedIn here as it can interfere with the login process
            // The app will handle the login state transition automatically
        }
    }
}

struct LoginSelector_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginSelector()
                .environmentObject(AppState())
        }
    }
}
