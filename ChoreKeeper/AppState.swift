import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var isShowingSplash = true
    @Published var isAppReady = false
    @Published var isLoggedIn = false

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.isAppReady = true
        }
    }

    func dismissSplash() {
        if isAppReady {
            withAnimation(.easeOut(duration: 0.8)) {
                isShowingSplash = false
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.8)) {
                    self.isShowingSplash = false
                }
            }
        }
    }

    func logout() {
        print("AppState: Starting logout process...")

        let keysToRemove = [
            "user_role",
            "user_id",
            "user_name",
            "user_avatar",
            "last_login",
            "last_login_attempt"
        ]

        for key in keysToRemove {
            print("AppState: Removing UserDefaults key: \(key)")
            UserDefaults.standard.removeObject(forKey: key)
        }

        UserDefaults.standard.synchronize()

        // Note: We don't set isLoggedIn here anymore
        // It's now set directly in the notification handler to ensure proper UI updates
        print("AppState: User data cleared")
    }
}
