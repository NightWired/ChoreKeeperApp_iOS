# ChoreKeeper iOS App

ChoreKeeper is an iOS application designed to help users manage and track household chores and tasks.

## Features

- Track and manage household chores
- Assign tasks to family members
- Set due dates and reminders
- Monitor completion status
- View chore history

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/NightWired/ChoreKeeperApp_iOS.git
```

2. Open the project in Xcode:
```bash
cd ChoreKeeperApp_iOS
open ChoreKeeperApp.xcworkspace
```

3. Build and run the application in Xcode.

## Project Structure

- `ChoreKeeper/` - Main application source code
- `ChoreKeeperTests/` - Unit tests
- `ChoreKeeperUITests/` - UI tests
- `SwiftModules/` - Custom Swift modules

## Development

### Module Development

ChoreKeeper is developed using a modular architecture. Each module is located in the `SwiftModules/` directory and can be built independently using Swift Package Manager.

To build a module:

```bash
cd SwiftModules/[ModuleName]
swift build
```

To run tests for a module:

```bash
cd SwiftModules/[ModuleName]
swift test
```

### Core Data Model

The Core Data model is defined in `ChoreKeeper/ChoreKeeper.xcdatamodeld/ChoreKeeper.xcdatamodel/contents`. When module development requires changes to the Core Data model, this file should be updated directly.

## License

This project is licensed under the terms found in the LICENSE file.

## Updates

### May 18, 2025

- Refactored navigation and UI handling for better consistency:
  - Improved sheet and view navigation throughout the app
  - Fixed logout functionality to properly return to login screen
  - Enhanced language selection to work correctly with settings sheet
  - Optimized theme management with notification-based updates
  - Removed unnecessary debug code and test prints
  - Fixed home button navigation to properly return to dashboard
  - Added proper back button to ChoreView for improved navigation
  - Centralized logout handling for better security and user experience

### May 16, 2025

- Implemented ChoreHandler module for chore management:
  - Created comprehensive chore model with support for recurring chores
  - Implemented chore service for CRUD operations
  - Added chore icon management with extensive icon library
  - Created UI components for chore management (ChoreView, ChoreList, ChoreCalendar)
  - Added test parent and child users for development purposes
  - Implemented placeholder functionality for future Points and Rewards & Penalties modules
  - Updated localization files with new keys for chore management
  - Successfully integrated and tested in the app UI

### May 15, 2025

- Implemented DataModels module with repository pattern for Core Data:
  - Created CoreDataStack for managing Core Data contexts and operations
  - Implemented Repository pattern for standardized data access
  - Added QueryBuilder for fluent interface to build complex queries
  - Created repositories for User and PeriodSettings entities
  - Added support for the new Rewards and Penalties application modes
  - Integrated with CoreServices for logging and utilities
  - Integrated with ErrorHandler for standardized error handling
  - Successfully integrated and tested in simulator

### May 15, 2025

- Implemented CoreServices module with essential utilities and services:
  - Added centralized logging system with multiple severity levels
  - Created configuration management with environment support
  - Implemented dependency injection framework
  - Added date, string, and security utilities
  - Integrated with LocalizationHandler and ErrorHandler modules
  - Successfully tested in simulator with all components working correctly
  - Added environment values for CoreServices throughout the app

### May 14, 2025

- Implemented centralized UI components for improved consistency:
  - Created centralized language selector with visual indicators for selected language
  - Developed centralized settings view with account type-specific options (parent/child)
  - Added reusable settings row component for consistent settings UI
  - Improved navigation management with proper back button handling
  - Fixed navigation stack issues for logout flow
  - Added visual indicators for currently selected language options

### May 14, 2025

- Implemented ErrorHandler module with standardized error handling
- Added comprehensive error code system with 10 categories
- Created error middleware system for extensible error processing
- Integrated localized error messages in 17 languages
- Added error severity levels (low, medium, high, critical)
- Implemented error context for detailed debugging information
- Added test functionality in UI for error handling demonstration

### May 14, 2025

- Added splash screen with logo and app name
  - Implemented smooth transition from app launch to main content
  - Created professional fade-in animation with 7-second minimum display time
  - Added "Powered by" text below app name
  - Ensured splash screen respects light/dark mode settings
- Implemented light/dark mode support
  - Added color assets for consistent theming across the app
  - Light mode background: #F5F5F7 (pale grey)
  - Dark mode background: #1F1F1F (dark grey)
  - Added complementary text and accent colors for both modes
  - Created theme manager with system/light/dark mode options

### May 14, 2025

- Enhanced LocalizationHandler module with bundle-based file loading
- Implemented bundle registration system for modular localization
- Added comprehensive debugging support for localization
- Improved error handling and fallbacks in localization
- Successfully integrated and tested LocalizationHandler in the UI
- Updated documentation to reflect the improved localization system

### May 13, 2025

- Set up project structure with modular architecture
- Created development guidelines for Swift modules
- Configured Core Data model with entities for:
  - User management (User, Family)
  - Chore tracking (Chore)
  - Point system (Point, PointTransaction)
  - Rewards and penalties (Reward, Penalty)
  - Avatar customization (Avatar)
- Updated .gitignore for Swift module development
- Created module creation plan and integration specifications
