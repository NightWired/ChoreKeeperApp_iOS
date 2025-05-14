//
//  ContentView.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-13.
//

import SwiftUI
import CoreData
import LocalizationHandler
import ErrorHandler

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager

    // State variables for error handling
    @State private var showErrorAlert = false
    @State private var currentError: AppError?

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.updatedAt, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>

    var body: some View {
        NavigationView {
            List {
                ForEach(users, id: \.id) { user in
                    NavigationLink {
                        UserDetailView(user: user)
                    } label: {
                        UserRowView(user: user)
                    }
                }
                .onDelete(perform: deleteUsers)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Text(LocalizationHandler.localize("common.edit"))
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                ToolbarItem {
                    Button(action: addUser) {
                        Label(LocalizationHandler.localize("children.add"), systemImage: "person.badge.plus")
                            .foregroundColor(Color("AccentColor"))
                    }
                }

                // TEMPORARY: Theme toggle for testing
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Light Mode") {
                            themeManager.theme = .light
                        }
                        Button("Dark Mode") {
                            themeManager.theme = .dark
                        }
                        Button("System") {
                            themeManager.theme = .system
                        }
                    } label: {
                        Label("Theme", systemImage: "circle.lefthalf.filled")
                            .foregroundColor(Color("AccentColor"))
                    }
                }

                // Test Error Handling button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: testErrorHandling) {
                        Label("Test Error", systemImage: "exclamationmark.triangle")
                            .foregroundColor(Color("SecondaryAccentColor"))
                    }
                }
            }
            .navigationTitle(LocalizationHandler.localize("app.name"))

            Text(LocalizationHandler.localize("dashboard.parent.children"))
                .font(.largeTitle)
                .foregroundColor(Color("SecondaryTextColor"))
        }
        .accentColor(Color("AccentColor"))
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text(LocalizationHandler.localize("error.title")),
                message: Text(currentError?.localizedMessage ?? "Unknown error"),
                dismissButton: .default(Text(LocalizationHandler.localize("common.ok")))
            )
        }
    }

    // Function to test error handling
    private func testErrorHandling() {
        // Create a random error for testing
        let errorTypes: [AppErrorCode] = [
            .invalidInput,
            .networkError,
            .authenticationError,
            .dataNotFound,
            .permissionDenied,
            .operationFailed
        ]

        let randomErrorCode = errorTypes.randomElement() ?? .unknown
        let errorSeverity: ErrorSeverity = [.low, .medium, .high, .critical].randomElement() ?? .medium

        // Create the error
        currentError = AppError(
            code: randomErrorCode,
            severity: errorSeverity,
            message: nil, // Use localized message from ErrorHandler
            context: ["source": "Test Button", "timestamp": Date()]
        )

        // Log the error using ErrorHandler
        if let error = currentError {
            ErrorHandler.handle(error)

            // Show the error alert
            showErrorAlert = true

            print("Generated test error: \(error.formattedCode) - \(error.localizedMessage)")
        }
    }

    private func addUser() {
        withAnimation {
            let newUser = User(context: viewContext)
            newUser.id = UUID()
            newUser.firstName = "New"
            newUser.lastName = "User"
            newUser.username = "user\(Int.random(in: 1000...9999))"
            // Use the localized value for "child"
            newUser.userType = "child" // Keep the internal value as "child"
            newUser.createdAt = Date()
            newUser.updatedAt = Date()
            newUser.primaryAccount = false

            do {
                try viewContext.save()
                // Show a success message using localized string
                print(LocalizationHandler.localize("common.success"))
            } catch {
                // Create an AppError from the caught error
                let appError = AppError.from(
                    error,
                    code: .dataSaveFailed,
                    severity: .high,
                    context: ["entity": "User", "operation": "create"]
                )

                // Handle the error using ErrorHandler
                ErrorHandler.handle(appError)

                // Update UI to show the error
                currentError = appError
                showErrorAlert = true
            }
        }
    }

    private func deleteUsers(offsets: IndexSet) {
        withAnimation {
            offsets.map { users[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                print(LocalizationHandler.localize("common.delete") + " " + LocalizationHandler.localize("common.success"))
            } catch {
                // Create an AppError from the caught error
                let appError = AppError.from(
                    error,
                    code: .dataDeleteFailed,
                    severity: .high,
                    context: ["entity": "User", "operation": "delete"]
                )

                // Handle the error using ErrorHandler
                ErrorHandler.handle(appError)

                // Update UI to show the error
                currentError = appError
                showErrorAlert = true
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct UserRowView: View {
    let user: User

    var body: some View {
        HStack {
            Image(systemName: user.userType == "parent" ? "person.circle.fill" : "person.circle")
                .foregroundColor(user.userType == "parent" ? Color("AccentColor") : Color("SecondaryAccentColor"))
                .font(.title2)

            VStack(alignment: .leading) {
                Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))

                Text(user.username ?? "")
                    .font(.subheadline)
                    .foregroundColor(Color("SecondaryTextColor"))

                // Add user type with localization
                Text(user.userType == "parent" ?
                     LocalizationHandler.localize("onboarding.userType.parent") :
                     LocalizationHandler.localize("onboarding.userType.child"))
                    .font(.caption)
                    .foregroundColor(Color("TertiaryTextColor"))
            }

            Spacer()

            if user.primaryAccount {
                Image(systemName: "star.fill")
                    .foregroundColor(Color("SecondaryAccentColor"))
            }
        }
        .padding(.vertical, 4)
    }
}

struct UserDetailView: View {
    let user: User
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: user.userType == "parent" ? "person.circle.fill" : "person.circle")
                    .font(.system(size: 60))
                    .foregroundColor(user.userType == "parent" ? Color("AccentColor") : Color("SecondaryAccentColor"))

                VStack(alignment: .leading) {
                    Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                        .font(.title)
                        .foregroundColor(Color("TextColor"))

                    Text(user.username ?? "")
                        .font(.title3)
                        .foregroundColor(Color("SecondaryTextColor"))

                    Text(user.userType == "parent" ?
                         LocalizationHandler.localize("onboarding.userType.parent") :
                         LocalizationHandler.localize("onboarding.userType.child"))
                        .font(.headline)
                        .foregroundColor(Color("SecondaryTextColor"))
                        .padding(.top, 2)
                }
            }
            .padding()

            Divider()
                .background(Color("SecondaryTextColor"))

            VStack(alignment: .leading, spacing: 10) {
                DetailRow(label: LocalizationHandler.localize("auth.username"), value: user.username ?? "Unknown")
                DetailRow(label: LocalizationHandler.localize("statistics.startDate"), value: formatDate(user.createdAt))
                DetailRow(label: LocalizationHandler.localize("statistics.endDate"), value: formatDate(user.updatedAt))
                DetailRow(
                    label: LocalizationHandler.localize("settings.account"),
                    value: user.primaryAccount ?
                        LocalizationHandler.localize("common.yes") :
                        LocalizationHandler.localize("common.no")
                )
            }
            .padding()

            Spacer()
        }
        .background(Color("BackgroundColor"))
        .navigationTitle(LocalizationHandler.localize("children.detail"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return LocalizationHandler.localize("common.loading") }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
                .frame(width: 120, alignment: .leading)
                // Use RTL support from LocalizationHandler if needed
                .multilineTextAlignment(LocalizationHandler.isRightToLeft() ? .trailing : .leading)

            Text(value)
                .font(.body)
                .foregroundColor(Color("SecondaryTextColor"))
                // Use RTL support from LocalizationHandler if needed
                .multilineTextAlignment(LocalizationHandler.isRightToLeft() ? .trailing : .leading)

            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ThemeManager())
            .onAppear {
                // Register default middleware for previews
                ErrorHandler.registerMiddleware(LoggingMiddleware())
            }
    }
}
