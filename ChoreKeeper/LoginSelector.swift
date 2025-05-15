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
    }
}

struct LoginSelector_Previews: PreviewProvider {
    static var previews: some View {
        LoginSelector()
    }
}
