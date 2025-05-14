# Swift iOS Development Guidelines for ChoreKeeper

## Core Development Principles

### Project Structure
- **Modular Architecture**: The project is structured as a collection of Swift modules, each with its own functionality.
- **Module Independence**: Each module should be developed to function independently while maintaining compatibility with other modules.
- **Xcode Integration**: Xcode components will be managed directly in Xcode. Do not modify xcodeproj or xcworkspace files.
- **Target Architectures**: Support both arm64 (production) and x86_64 (simulator) architectures.

### Dependency Management
- **SPM Only**: CocoaPods is never to be used. Always use Swift Package Manager (SPM) for all dependencies.
- **Dependency Justification**: Each dependency added must have a clear justification and should be evaluated for maintenance status, community support, and compatibility with iOS 15+.
- **Minimize Dependencies**: Prefer native iOS solutions when available rather than adding external dependencies.
- **Architecture Compatibility**: Ensure all dependencies are compatible with both x86_64 simulator environments and arm64 iPhone/iPad devices.

### Compatibility and Standards
- **iOS Compatibility**: All development should be done with an eye for maximum compatibility with Swift and iOS.
- **Minimum iOS Version**: Target iOS 15.0 and above for all features.
- **Swift Version**: Use Swift 5.5+ and leverage modern Swift features where appropriate.
- **SwiftUI First**: Prefer SwiftUI for UI development, falling back to UIKit only when necessary for specific functionality.

### File Management and Paths
- **Full Paths Required**: Full paths are to be used at all times to avoid incorrect creation, modification, or deletion of files due to vague relative path usage.
- **Path Verification**: Always verify paths before performing file operations.
- **Project Structure**: Maintain a clean, organized project structure with logical grouping of files.
- **Resource Management**: Place resources in appropriate directories (e.g., images in Assets.xcassets, localization files in proper .lproj directories).
- **Module Organization**: Each module will have its own directory within the `/Users/baribyquance-hearn/Documents/augment-projects/ChoreKeeperProject/ChoreKeeper/SwiftModules` path.

### Quality Assurance
- **Swift Build Testing**: Use `swift build` for testing module compilation.
- **Unit Testing**: Comprehensive unit tests are required for all modules.
- **Test Coverage**: Aim for high test coverage, especially for business logic and critical paths.
- **No Xcode Build Testing**: Xcode-specific build testing will be performed manually by the developer.

### User Experience and Interface Design
- **User-Centric Design**: UI elements should always be developed with User eXperience in mind.
- **Consistent Layouts**: Layouts should be consistent and intuitive across the application.
- **Accessibility**: Ensure all UI elements are accessible and support Dynamic Type.
- **Dark Mode Support**: All UI components must support both light and dark mode.
- **Responsive Design**: UI should adapt gracefully to different device sizes and orientations.

### Development Workflow
- **Modular Development**: Develop modules separately based on logical functionality groupings.
- **Continuous Progress**: The AI should, to the best of its ability, continue working with minimal interrogative interruptions, until either the prompted request is completed or it becomes necessary to seek clarification.
- **Incremental Development**: Implement features incrementally, ensuring each increment is functional and tested.
- **Gradual Architecture Implementation**: Take a gradual, incremental approach to implementing complex architecture (MVVM, dependency injection) with testing after each significant change.
- **Documentation**: Document code thoroughly, especially public APIs and complex logic.
- **Error Handling**: Implement comprehensive error handling with user-friendly error messages.
- **Code Reuse**: Reuse code from the old project where possible, especially for DiceBear implementation and Teacher animation/Tutorial systems.
- **Integration Documentation**: Create clear documentation on how to integrate modules into the parent Xcode project in the `XcodeIntegrationSpecifications.md` file.

### Module Structure and Interoperability
- **Logical Functionality Grouping**: Modules should be created based on logical functionality groupings (e.g., Localization, Error Handling, Chores, Points, Rewards & Penalties).
- **Shared Resources**: Resources that should be shared among modules should be mocked for development testing.
- **Integration Specifications**: Clear instructions for implementing shared resources in the parent Xcode project should be documented in `/Users/baribyquance-hearn/Documents/augment-projects/ChoreKeeperProject/docs/XcodeIntegrationSpecifications.md`.
- **Reference Prior Modules**: New modules should reference previously created modules to ensure consistent mocking of shared resources.
- **Forward Compatibility**: Design modules with a forward view of the project plan for proper interoperability.
- **Core Data Integration**: Configure modules to utilize Core Data where appropriate.

## Swift Coding Standards

### Code Style
- **Swift Style Guide**: Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- **Consistent Naming**: Use clear, descriptive names for variables, functions, and types.
- **Access Control**: Use appropriate access control modifiers (private, fileprivate, internal, public).
- **Comments**: Include meaningful comments for complex logic, but prefer self-documenting code.

### Architecture
- **MVVM Pattern**: Use the Model-View-ViewModel (MVVM) architecture pattern.
- **Separation of Concerns**: Maintain clear separation between UI, business logic, and data layers.
- **Dependency Injection**: Use dependency injection to improve testability and flexibility.
- **Protocol-Oriented Programming**: Leverage Swift's protocol-oriented programming paradigm.
- **Centralized Core Functionality**: Core functionality should be centralized in appropriate service or manager classes to ensure consistency and maintainability.
- **Code Reuse Priority**: Avoid code duplication. Reuse and modification of existing code should take precedence over creating new code or files. Always check for existing implementations before creating new ones.

### Swift Best Practices
- **Value Types**: Prefer value types (structs, enums) over reference types (classes) when appropriate.
- **Optionals**: Handle optionals safely, avoiding force unwrapping except in tests or when failure is impossible.
- **Centralized Error Handling**: Use a centralized error handling system that works with localization to provide user-friendly error messages.
- **Error Types**: Use Swift's error handling mechanisms (do-try-catch) appropriately with custom error types.
- **Error Propagation**: Properly propagate errors up the call stack to be handled at the appropriate level.
- **User-Facing Errors**: All user-facing error messages must be localized and provide clear guidance on how to resolve the issue.
- **Memory Management**: Be mindful of memory management, especially with closures and delegates.
- **Concurrency**: Use modern Swift concurrency features (async/await) for asynchronous operations.

## iOS-Specific Guidelines

### UI Implementation
- **SwiftUI Components**: Create reusable SwiftUI components for consistent UI elements.
- **Responsive Layouts**: Use GeometryReader and flexible layouts to ensure UI works on all device sizes.
- **Animation**: Use animations judiciously to enhance the user experience without being distracting.
- **Gestures**: Implement intuitive gesture controls where appropriate.

### Data Management
- **Core Data**: Use Core Data for complex data models and persistence.
- **Core Data Model Updates**: When module development requires changes to the Core Data model, directly update the `ChoreKeeper/ChoreKeeper/ChoreKeeper.xcdatamodeld/ChoreKeeper.xcdatamodel/contents` file. Document all changes in the module's README.md and in the XcodeIntegrationSpecifications.md file.
- **Core Data Model Versioning**: If changes to the Core Data model are significant, create a new model version in Xcode and document the migration path.
- **UserDefaults**: Use UserDefaults for simple preferences only.
- **Network Requests**: Implement proper error handling and loading states for network operations.
- **Caching**: Implement appropriate caching strategies for network resources and computed values.
- **Data Flow**: Maintain unidirectional data flow where possible.

### Performance
- **Rendering Performance**: Optimize UI rendering, especially for complex views and lists.
- **Memory Usage**: Monitor and optimize memory usage, avoiding memory leaks.
- **Battery Efficiency**: Be mindful of battery impact, especially for background operations.
- **Startup Time**: Optimize module initialization time.

### Security
- **Secure Storage**: Use Keychain for sensitive data storage.
- **Network Security**: Implement proper SSL/TLS handling and certificate pinning where needed.
- **Input Validation**: Validate all user input and external data.
- **Privacy**: Respect user privacy and comply with App Store guidelines.

## Testing Guidelines

### Unit Testing
- **Test Coverage**: Aim for comprehensive test coverage of business logic.
- **Test Independence**: Ensure tests are independent and don't rely on each other.
- **Mocking**: Use protocol-based design to facilitate mocking in tests.
- **Test Naming**: Use descriptive test names that explain what is being tested.
- **Mock Shared Resources**: Mock shared resources that would be provided by the parent Xcode project.

### Performance Testing
- **Benchmark Tests**: Create benchmark tests for performance-critical operations.
- **Memory Leak Detection**: Implement tests to detect memory leaks.

## Localization

- **Full Localization**: Support all 17 languages from the existing localization files.
- **Comprehensive Localization**: Any user-facing element must be localized. No hardcoded strings in the UI.
- **All Languages Updates**: Any updates to the localization strings must be done for all supported languages simultaneously.
- **Nested Key Structure**: Language localization files should be maintained using a nested key structure with sections relevant to the implementation locations within the project.
- **String Extraction**: Use NSLocalizedString with appropriate context comments.
- **Format Specifiers**: Use proper format specifiers for different languages.
- **Right-to-Left Support**: Ensure UI properly supports right-to-left languages.
- **Localization Testing**: Test the application with different languages to ensure proper display and functionality.

## Documentation

- **Code Documentation**: Use proper documentation comments for functions, classes, and properties.
- **Architecture Documentation**: Maintain documentation of the overall architecture and key subsystems.
- **Change Documentation**: Document significant changes and the reasoning behind them.
- **Integration Documentation**: Provide clear documentation on how to integrate modules into the parent Xcode project.
- **Module Dependencies**: Document dependencies between modules and shared resources.

---

These guidelines should be followed for all development work on the ChoreKeeper iOS application. Any deviations should be explicitly justified and documented.
