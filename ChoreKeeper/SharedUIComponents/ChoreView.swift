//
//  ChoreView.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-16.
//

import SwiftUI
import LocalizationHandler
import ChoreHandler

struct ChoreView: View {
    // MARK: - Properties

    enum Mode {
        case create
        case edit
        case view
    }

    var initialMode: Mode
    @State private var currentMode: Mode
    var chore: ChoreModel?
    var isParent: Bool
    var onSave: (ChoreModel) -> Void
    var onDelete: () -> Void
    var onComplete: () -> Void
    var onVerify: () -> Void
    var onReject: () -> Void
    var onCancel: () -> Void

    @State private var title: String
    @State private var description: String
    @State private var points: Int16
    @State private var dueDate: Date
    @State private var isRecurring: Bool
    @State private var recurringPattern: String?
    @State private var selectedIconId: String
    @State private var assignedToUserId: UUID?

    @State private var showDeleteAlert = false
    @State private var showRejectAlert = false
    @State private var rejectReason = ""

    // MARK: - Initialization

    init(
        mode: Mode,
        chore: ChoreModel? = nil,
        isParent: Bool,
        onSave: @escaping (ChoreModel) -> Void,
        onDelete: @escaping () -> Void,
        onComplete: @escaping () -> Void,
        onVerify: @escaping () -> Void,
        onReject: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialMode = mode
        self._currentMode = State(initialValue: mode)
        self.chore = chore
        self.isParent = isParent
        self.onSave = onSave
        self.onDelete = onDelete
        self.onComplete = onComplete
        self.onVerify = onVerify
        self.onReject = onReject
        self.onCancel = onCancel

        // Initialize state properties with default values or chore values
        _title = State(initialValue: chore?.title ?? "")
        _description = State(initialValue: chore?.description ?? "" )
        _points = State(initialValue: chore?.points ?? 5)
        _dueDate = State(initialValue: chore?.dueDate ?? Date().addingTimeInterval(3600))
        _isRecurring = State(initialValue: chore?.isRecurring ?? false)
        _recurringPattern = State(initialValue: chore?.recurringPattern ?? (chore?.isRecurring ?? false ? "daily" : nil))
        _selectedIconId = State(initialValue: chore?.iconId ?? "dishes")
        _assignedToUserId = State(initialValue: chore?.assignedToUserId)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color("BackgroundColor").ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with back button
                AppHeaderView(
                    showHomeButton: true,
                    isChildUser: !isParent,
                    onHomeButtonTap: onCancel,
                    onSettingsButtonTap: {
                        // Show full settings view
                    }
                )

                // Back button
                HStack {
                    Button(action: onCancel) {
                        Text(LocalizationHandler.localize("common.back"))
                            .foregroundColor(Color("AccentColor"))
                            .padding(.vertical, 8)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header with icon and title
                        headerView

                        // Form fields
                        if currentMode == .create || (currentMode == .edit && isParent) {
                            editableFormFields
                        } else {
                            readOnlyFormFields
                        }

                        // Action buttons
                        actionButtons
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text(LocalizationHandler.localize("chores.deleteConfirmation.title")),
                message: Text(LocalizationHandler.localize("chores.deleteConfirmation.message")),
                primaryButton: .destructive(Text(LocalizationHandler.localize("common.delete"))) {
                    onDelete()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack(spacing: 20) {
            // Chore icon
            if currentMode == .create || (currentMode == .edit && isParent) {
                iconPickerButton
            } else {
                choreIconView
            }

            // Title and status
            VStack(alignment: .leading, spacing: 4) {
                if currentMode == .view {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextColor"))

                    HStack {
                        Text(LocalizationHandler.localize(getStatusLocalizationKey(chore?.status ?? .pending)))
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor.opacity(0.2))
                            .foregroundColor(statusColor)
                            .cornerRadius(8)

                        Spacer()

                        Text("\(points) \(LocalizationHandler.localize("chores.points"))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
        }
        .padding()
        .background(Color("BackgroundColor"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var editableFormFields: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizationHandler.localize("chores.form.title"))
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))

                TextField(LocalizationHandler.localize("chores.title_placeholder"), text: $title)
                    .padding()
                    .background(Color("BackgroundColor"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }

            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizationHandler.localize("chores.form.description"))
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))

                TextEditor(text: $description)
                    .frame(minHeight: 100)
                    .padding(4)
                    .background(Color("BackgroundColor"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }

            // Points
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizationHandler.localize("chores.points"))
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))

                HStack {
                    Button(action: { if points > 1 { points -= 1 } }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(Color("AccentColor"))
                    }

                    Text("\(points)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 50)
                        .multilineTextAlignment(.center)

                    Button(action: { points += 1 }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                .padding()
                .background(Color("BackgroundColor"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }

            // Due date
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizationHandler.localize("chores.dueDate"))
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))

                DatePicker("", selection: $dueDate)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color("BackgroundColor"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }

            // Recurring toggle
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $isRecurring) {
                    Text(LocalizationHandler.localize("chores.recurring"))
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                }

                if isRecurring {
                    Picker(LocalizationHandler.localize("chores.frequency"), selection: $recurringPattern) {
                        Text(LocalizationHandler.localize("chores.frequencySettings.daily"))
                            .tag("daily" as String?)
                        Text(LocalizationHandler.localize("chores.frequencySettings.weekly"))
                            .tag("weekly" as String?)
                        Text(LocalizationHandler.localize("chores.frequencySettings.monthly"))
                            .tag("monthly" as String?)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 8)
                }
            }
            .padding()
            .background(Color("BackgroundColor"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

            // Assign to child (only for parent mode)
            if isParent {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizationHandler.localize("chores.assignTo"))
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))

                    // This would be replaced with actual child selection
                    Text(LocalizationHandler.localize("chores.form.selectChild"))
                        .foregroundColor(Color("SecondaryTextColor"))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("BackgroundColor"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onTapGesture {
                            // In a real app, this would show a child selection UI
                            // For now, we'll just use a placeholder UUID
                            assignedToUserId = assignedToUserId == nil ? UUID() : nil
                        }
                }
            }
        }
    }

    private var readOnlyFormFields: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Description
            if !description.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizationHandler.localize("chores.choreDescription"))
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))

                    Text(description)
                        .foregroundColor(Color("TextColor"))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("BackgroundColor"))
                        .cornerRadius(8)
                }
            }

            // Due date
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizationHandler.localize("chores.dueDate"))
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))

                Text(formattedDueDate)
                    .foregroundColor(Color("TextColor"))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("BackgroundColor"))
                    .cornerRadius(8)
            }

            // Recurring info
            if isRecurring {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizationHandler.localize("chores.form.frequency"))
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))

                    Text(LocalizationHandler.localize(getFrequencyLocalizationKey(recurringPattern)))
                        .foregroundColor(Color("TextColor"))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("BackgroundColor"))
                        .cornerRadius(8)
                }
            }

            // Assigned to (if applicable)
            if let _ = assignedToUserId {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizationHandler.localize("chores.assignedTo"))
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))

                    // This would show the actual child name
                    Text("Child Name")
                        .foregroundColor(Color("TextColor"))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("BackgroundColor"))
                        .cornerRadius(8)
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {
            if currentMode == .view {
                // Action buttons for view mode
                if let chore = chore {
                    Group {
                        switch chore.status {
                        case .pending:
                            // Pending chore actions
                            if isParent {
                                // Parent can edit
                                Button(action: {
                                    withAnimation {
                                        self.currentMode = .edit
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text(LocalizationHandler.localize("chores.edit"))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            } else {
                                // Child can mark as completed
                                Button(action: onComplete) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text(LocalizationHandler.localize("chores.markComplete"))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }

                        case .pendingVerification:
                            // Pending verification actions
                            if isParent {
                                // Parent can verify or reject
                                HStack(spacing: 16) {
                                    Button(action: { showRejectAlert = true }) {
                                        HStack {
                                            Image(systemName: "xmark.circle.fill")
                                            Text(LocalizationHandler.localize("chores.reject"))
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(SecondaryButtonStyle())

                                    Button(action: onVerify) {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text(LocalizationHandler.localize("chores.verify"))
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(PrimaryButtonStyle())
                                }
                            }

                        case .completed, .verified:
                            // Completed chore - no actions needed
                            EmptyView()

                        case .rejected, .missed:
                            // For rejected or missed chores, parent can edit
                            if isParent {
                                Button(action: {
                                    withAnimation {
                                        self.currentMode = .edit
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text(LocalizationHandler.localize("chores.edit"))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                        }
                    }
                }
            } else if currentMode == .create {
                // Create mode buttons
                VStack(spacing: 16) {
                    // Save button
                    Button(action: saveChore) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(LocalizationHandler.localize("common.save"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(title.isEmpty)

                    // Cancel button
                    Button(action: onCancel) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text(LocalizationHandler.localize("common.cancel"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            } else if currentMode == .edit {
                // Edit mode buttons
                VStack(spacing: 16) {
                    // Save button
                    Button(action: saveChore) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(LocalizationHandler.localize("common.save"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(title.isEmpty)

                    // Cancel button
                    Button(action: {
                        withAnimation {
                            self.currentMode = .view
                        }
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text(LocalizationHandler.localize("common.cancel"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    // Delete button (only for parent)
                    if isParent {
                        Button(action: { showDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text(LocalizationHandler.localize("chores.delete"))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(DangerButtonStyle())
                    }
                }
            }
        }
        .padding(.top, 20)
    }

    @State private var showIconPicker = false

    private var iconPickerButton: some View {
        VStack {
            Button(action: {
                showIconPicker = true
            }) {
                Image(systemName: ChoreHandler.iconWithId(selectedIconId).systemName)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color("AccentColor"))
                    .clipShape(Circle())
            }
            .sheet(isPresented: $showIconPicker) {
                // Use the IconPickerView from the SharedUIComponents directory
                IconPickerView(selectedIconId: $selectedIconId, onDismiss: { showIconPicker = false })
            }

            Text(LocalizationHandler.localize("chores.selectIcon"))
                .font(.caption)
                .foregroundColor(Color("SecondaryTextColor"))
        }
        .frame(width: 90)
        .padding(.trailing, 10)
    }

    private var choreIconView: some View {
        VStack {
            Image(systemName: ChoreHandler.iconWithId(selectedIconId).systemName)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(statusColor)
                .clipShape(Circle())

            Text(LocalizationHandler.localize("chores.icons.\(selectedIconId)"))
                .font(.caption)
                .foregroundColor(Color("SecondaryTextColor"))
        }
        .frame(width: 90)
        .padding(.trailing, 10)
    }

    private var trailingButton: some View {
        // No longer needed as functionality is in actionButtons
        EmptyView()
    }

    // MARK: - Helper Methods

    private func saveChore() {
        let updatedChore = ChoreModel(
            id: chore?.id ?? Int64.random(in: 1...1000), // In a real app, this would be handled by the backend
            title: title,
            description: description,
            points: points,
            dueDate: dueDate,
            isRecurring: isRecurring,
            recurringPattern: isRecurring ? recurringPattern : nil,
            status: chore?.status ?? .pending,
            assignedToUserId: assignedToUserId,
            iconId: selectedIconId
        )

        onSave(updatedChore)
    }



    private func getFrequencyLocalizationKey(_ pattern: String?) -> String {
        if pattern == "daily" {
            return "chores.frequencySettings.daily"
        } else if pattern == "weekly" {
            return "chores.frequencySettings.weekly"
        } else if pattern == "monthly" {
            return "chores.frequencySettings.monthly"
        } else {
            return "chores.frequencySettings.once"
        }
    }

    private func getStatusLocalizationKey(_ status: ChoreStatus) -> String {
        switch status {
        case .pendingVerification:
            return "chores.status.pendingVerification"
        default:
            return "chores.status.\(status.rawValue)"
        }
    }

    // MARK: - Computed Properties



    private var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }

    private var statusColor: Color {
        guard let status = chore?.status else { return .blue }

        switch status {
        case .pending:
            return .blue
        case .completed, .verified:
            return .green
        case .pendingVerification:
            return .orange
        case .rejected:
            return .red
        case .missed:
            return .gray
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color("AccentColor").opacity(configuration.isPressed ? 0.8 : 1))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.gray.opacity(configuration.isPressed ? 0.1 : 0.2))
            .foregroundColor(Color("TextColor"))
            .cornerRadius(10)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.red.opacity(configuration.isPressed ? 0.8 : 1))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

// MARK: - Extensions

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Previews

struct ChoreView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Create mode (parent)
            NavigationView {
                ChoreView(
                    mode: .create,
                    isParent: true,
                    onSave: { _ in },
                    onDelete: {},
                    onComplete: {},
                    onVerify: {},
                    onReject: {},
                    onCancel: {}
                )

            }
            .previewDisplayName("Create Mode (Parent)")

            // View mode (parent)
            NavigationView {
                ChoreView(
                    mode: .view,
                    chore: ChoreModel(
                        id: 1,
                        title: "Clean Room",
                        description: "Vacuum and dust the bedroom",
                        points: 10,
                        dueDate: Date().addingTimeInterval(86400),
                        isRecurring: true,
                        recurringPattern: "weekly",
                        status: .pendingVerification,
                        iconId: "room"
                    ),
                    isParent: true,
                    onSave: { _ in },
                    onDelete: {},
                    onComplete: {},
                    onVerify: {},
                    onReject: {},
                    onCancel: {}
                )

            }
            .previewDisplayName("View Mode (Parent)")

            // View mode (child)
            NavigationView {
                ChoreView(
                    mode: .view,
                    chore: ChoreModel(
                        id: 2,
                        title: "Take Out Trash",
                        description: "Empty all trash cans",
                        points: 5,
                        dueDate: Date().addingTimeInterval(3600),
                        isRecurring: false,
                        status: .pending,
                        iconId: "trash"
                    ),
                    isParent: false,
                    onSave: { _ in },
                    onDelete: {},
                    onComplete: {},
                    onVerify: {},
                    onReject: {},
                    onCancel: {}
                )

            }
            .previewDisplayName("View Mode (Child)")
        }
    }
}
