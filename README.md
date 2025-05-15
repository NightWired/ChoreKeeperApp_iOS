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

### May 14, 2025

- Implemented centralized UI components for improved consistency:
  - Created centralized language selector with visual indicators for selected language
  - Developed centralized settings view with account type-specific options (parent/child)
  - Added reusable settings row component for consistent settings UI
  - Improved navigation management with proper back button handling
  - Fixed navigation stack issues for logout flow
  - Added visual indicators for currently selected language options

### May 14, 2023

- Implemented ErrorHandler module with standardized error handling
- Added comprehensive error code system with 10 categories
- Created error middleware system for extensible error processing
- Integrated localized error messages in 17 languages
- Added error severity levels (low, medium, high, critical)
- Implemented error context for detailed debugging information
- Added test functionality in UI for error handling demonstration

### May 14, 2023

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

### May 14, 2023

- Enhanced LocalizationHandler module with bundle-based file loading
- Implemented bundle registration system for modular localization
- Added comprehensive debugging support for localization
- Improved error handling and fallbacks in localization
- Successfully integrated and tested LocalizationHandler in the UI
- Updated documentation to reflect the improved localization system

### May 13, 2023

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
