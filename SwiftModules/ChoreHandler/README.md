# ChoreHandler

A Swift module for managing chores in the ChoreKeeper iOS application.

## Overview

The ChoreHandler module provides comprehensive functionality for creating, managing, and tracking chores. It supports one-time and recurring chores, chore assignment to users, chore completion and verification, and point allocation for completed chores.

## Features

- **Chore Creation and Management**: Create, update, and delete chores
- **Recurring Chore Support**: Daily, weekly, and monthly recurring patterns
- **Automatic Chore Generation**: Auto-populate recurring chores for future dates
- **Chore Assignment**: Assign chores to specific users
- **Chore Completion**: Track chore completion status
- **Verification System**: Optional parent verification for completed chores
- **Point Management**: Allocate points for completed chores
- **Role-Based Permissions**: Different capabilities for parent and child users

## Architecture

The ChoreHandler module follows these architectural principles:

1. **Service-Based Design**: Core functionality is provided through services
2. **Protocol-Based Interfaces**: All services implement protocols for better testability
3. **Dependency Injection**: Services are designed to be injected rather than directly instantiated
4. **Error Standardization**: All errors are mapped to standardized AppError types

## Core Components

- **ChoreService**: Main service for chore management
- **ChoreGenerator**: Handles recurring chore generation
- **ChoreValidator**: Validates chore completion
- **ChoreScheduler**: Manages chore scheduling and due dates

## Dependencies

- **CoreServices**: Used for logging, configuration, and utility functions
- **ErrorHandler**: Used for standardized error handling
- **LocalizationHandler**: Used for localized messages
- **DataModels**: Used for data access and Core Data integration

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.7+
- Xcode 14.0+

## Integration

To integrate the ChoreHandler module into your project, add it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(name: "ChoreHandler", path: "../ChoreHandler")
]
```

## Usage

```swift
import ChoreHandler

// Initialize the chore service
let choreService = ChoreService.shared

// Create a new chore
let newChore = try choreService.createChore(
    title: "Clean Room",
    description: "Vacuum and dust the bedroom",
    points: 10,
    dueDate: Date().addingTimeInterval(86400), // Due tomorrow
    isRecurring: false,
    assignedToUserId: childUserId,
    createdByUserId: parentUserId,
    familyId: familyId
)

// Create a recurring chore
let recurringChore = try choreService.createRecurringChore(
    title: "Take Out Trash",
    description: "Empty all trash cans and take to curb",
    points: 5,
    frequency: .weekly,
    daysOfWeek: [.monday, .thursday],
    dueTime: "20:00", // 8:00 PM
    assignedToUserId: childUserId,
    createdByUserId: parentUserId,
    familyId: familyId
)

// Mark a chore as completed
try choreService.completeChore(choreId: choreId, completedByUserId: childUserId)

// Verify a completed chore
try choreService.verifyChore(choreId: choreId, verifiedByUserId: parentUserId)
```

## Localization Keys

The following localization keys need to be added to all language files:

```json
{
  "chores": {
    "frequency": {
      "oneTime": "One Time",
      "daily": "Daily",
      "weekly": "Weekly",
      "monthly": "Monthly"
    },
    "status": {
      "pending": "Pending",
      "completed": "Completed",
      "pendingVerification": "Pending Verification",
      "verified": "Verified",
      "rejected": "Rejected",
      "missed": "Missed"
    },
    "iconCategories": {
      "household": "Household",
      "personal": "Personal",
      "outdoor": "Outdoor",
      "school": "School",
      "pets": "Pets",
      "misc": "Miscellaneous"
    },
    "icons": {
      "dishes": "Dishes",
      "vacuum": "Vacuum",
      "laundry": "Laundry",
      "trash": "Trash",
      "bed": "Make Bed",
      "dusting": "Dusting",
      "bathroom": "Clean Bathroom",
      "teeth": "Brush Teeth",
      "shower": "Take Shower",
      "clothes": "Put Away Clothes",
      "room": "Clean Room",
      "lawn": "Mow Lawn",
      "garden": "Garden",
      "snow": "Shovel Snow",
      "car": "Wash Car",
      "homework": "Homework",
      "reading": "Reading",
      "backpack": "Pack Backpack",
      "dog": "Walk Dog",
      "petFood": "Feed Pets",
      "litterBox": "Clean Litter Box",
      "custom": "Custom",
      "phone": "Phone Call",
      "mail": "Check Mail",
      "groceries": "Groceries"
    }
  },
  "general": {
    "daysOfWeek": {
      "sunday": "Sunday",
      "monday": "Monday",
      "tuesday": "Tuesday",
      "wednesday": "Wednesday",
      "thursday": "Thursday",
      "friday": "Friday",
      "saturday": "Saturday"
    }
  },
  "errors": {
    "choreManagement": {
      "createFailed": "Failed to create chore: {0}",
      "updateFailed": "Failed to update chore: {0}",
      "deleteFailed": "Failed to delete chore: {0}",
      "choreNotFound": "Chore not found with ID: {0}",
      "invalidChoreData": "Invalid chore data: {0}",
      "invalidRecurringPattern": "Invalid recurring pattern: {0}",
      "invalidDueDate": "Invalid due date: {0}",
      "invalidPoints": "Invalid points: {0}",
      "invalidTitle": "Invalid title: {0}",
      "invalidUser": "Invalid user: {0}",
      "invalidFamily": "Invalid family: {0}",
      "invalidStatus": "Invalid status: {0}",
      "permissionDenied": "Permission denied: {0}",
      "alreadyCompleted": "Chore already completed with ID: {0}",
      "alreadyVerified": "Chore already verified with ID: {0}",
      "alreadyRejected": "Chore already rejected with ID: {0}",
      "alreadyMissed": "Chore already missed with ID: {0}",
      "recurringGenerationFailed": "Failed to generate recurring chores: {0}"
    },
    "pointManagement": {
      "pointAllocationFailed": "Failed to allocate points: {0}",
      "pointDeductionFailed": "Failed to deduct points: {0}"
    }
  }
}
```

## License

This project is proprietary and confidential. Unauthorized copying, transfer, or reproduction of the contents of this module is strictly prohibited.

## Contact

For questions or issues with the ChoreHandler module, please contact the development team.
