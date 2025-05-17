// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChoreHandler",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ChoreHandler",
            targets: ["ChoreHandler"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "CoreServices", path: "../CoreServices"),
        .package(name: "ErrorHandler", path: "../ErrorHandler"),
        .package(name: "LocalizationHandler", path: "../LocalizationHandler"),
        .package(name: "DataModels", path: "../DataModels")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ChoreHandler",
            dependencies: [
                "CoreServices",
                "ErrorHandler",
                "LocalizationHandler",
                "DataModels"
            ]),
        .testTarget(
            name: "ChoreHandlerTests",
            dependencies: ["ChoreHandler"]),
    ]
)
