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
