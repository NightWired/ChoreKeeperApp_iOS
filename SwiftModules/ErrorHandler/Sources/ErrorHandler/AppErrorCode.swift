//
//  AppErrorCode.swift
//  ErrorHandler
//
//  Created on 2023-05-16.
//

import Foundation

/// Error codes for the application
/// Each code has a unique integer value and is categorized by its range
public enum AppErrorCode: Int, Codable, Equatable, CaseIterable {
    // MARK: - General Errors (1-999)

    /// Unknown error
    case unknown = 1

    /// Operation cancelled
    case operationCancelled = 2

    /// Invalid input
    case invalidInput = 3

    /// Invalid state
    case invalidState = 4

    /// Permission denied
    case permissionDenied = 5

    /// Operation failed
    case operationFailed = 6

    /// Not implemented
    case notImplemented = 7

    /// Internal error
    case internalError = 8

    /// Timeout error
    case timeoutError = 9

    // MARK: - Network Errors (1000-1999)

    /// Network error
    case networkError = 1000

    /// No internet connection
    case noInternetConnection = 1001

    /// Request timeout
    case timeout = 1002

    /// Request failed
    case requestFailed = 1003

    /// Server error
    case serverError = 1004

    /// Server unavailable
    case serverUnavailable = 1005

    /// Invalid response
    case invalidResponse = 1006

    /// Invalid URL
    case invalidURL = 1007

    /// Connection lost
    case connectionLost = 1008

    /// SSL error
    case sslError = 1009

    // MARK: - Authentication Errors (2000-2999)

    /// Authentication error
    case authenticationError = 2000

    /// Invalid credentials
    case invalidCredentials = 2001

    /// Account not found
    case accountNotFound = 2002

    /// Account locked
    case accountLocked = 2003

    /// Session expired
    case sessionExpired = 2004

    /// Token expired
    case tokenExpired = 2005

    /// Token invalid
    case tokenInvalid = 2006

    /// Not authenticated
    case notAuthenticated = 2007

    /// Too many attempts
    case tooManyAttempts = 2008

    /// Email not verified
    case emailNotVerified = 2009

    // MARK: - Data Errors (3000-3999)

    /// Data not found
    case dataNotFound = 3001

    /// Data already exists
    case dataAlreadyExists = 3002

    /// Failed to save data
    case dataSaveFailed = 3003

    /// Failed to load data
    case dataLoadFailed = 3004

    /// Failed to delete data
    case dataDeleteFailed = 3005

    /// Data validation failed
    case dataValidationFailed = 3006

    /// Data corruption
    case dataCorruption = 3007

    /// Database error
    case databaseError = 3008

    // MARK: - Point Management Errors (8000-8999)

    /// Point allocation failed
    case pointAllocationFailed = 8000

    /// Point deduction failed
    case pointDeductionFailed = 8001

    /// Insufficient points
    case insufficientPoints = 8002

    /// Invalid point amount
    case invalidPointAmount = 8003

    /// Point calculation error
    case pointCalculationError = 8004

    /// Point transaction failed
    case pointTransactionFailed = 8005

    /// Negative balance not allowed
    case negativeBalanceNotAllowed = 8006

    /// Point adjustment failed
    case pointAdjustmentFailed = 8007

    /// Point statistics error
    case pointStatisticsError = 8008

    /// Point history error
    case pointHistoryError = 8009

    // MARK: - Properties

    /// The localization key for the error code
    public var localizationKey: String {
        return "errors.\(rawValue)"
    }

    /// The formatted error code (e.g., E0001)
    public var formattedCode: String {
        return String(format: "E%04d", rawValue)
    }

    /// The default severity for this error code
    public var defaultSeverity: ErrorSeverity {
        switch self {
        case .unknown, .operationCancelled, .invalidInput, .invalidState:
            return .medium

        case .permissionDenied, .operationFailed, .notImplemented, .internalError, .timeoutError:
            return .high

        case .networkError, .noInternetConnection, .timeout, .requestFailed, .serverError,
             .serverUnavailable, .invalidResponse, .invalidURL, .connectionLost, .sslError:
            return .medium

        case .authenticationError, .invalidCredentials, .accountNotFound, .accountLocked,
             .sessionExpired, .tokenExpired, .tokenInvalid, .notAuthenticated, .tooManyAttempts,
             .emailNotVerified:
            return .high

        case .dataNotFound, .dataAlreadyExists:
            return .medium

        case .dataSaveFailed, .dataLoadFailed, .dataDeleteFailed, .dataValidationFailed,
             .dataCorruption, .databaseError:
            return .high

        case .pointAllocationFailed, .pointDeductionFailed, .pointTransactionFailed,
             .pointAdjustmentFailed, .pointCalculationError, .pointStatisticsError,
             .pointHistoryError:
            return .high

        case .insufficientPoints, .invalidPointAmount, .negativeBalanceNotAllowed:
            return .medium
        }
    }

    /// The category of the error code
    public var category: ErrorCategory {
        switch rawValue {
        case 1...999:
            return .general
        case 1000...1999:
            return .network
        case 2000...2999:
            return .authentication
        case 3000...3999:
            return .data
        case 4000...4999:
            return .userInput
        case 5000...5999:
            return .permission
        case 6000...6999:
            return .choreManagement
        case 7000...7999:
            return .rewardManagement
        case 8000...8999:
            return .pointManagement
        case 9000...9999:
            return .system
        default:
            return .general
        }
    }
}

/// Categories of error codes
public enum ErrorCategory: String, Codable {
    /// General errors (1-999)
    case general

    /// Network errors (1000-1999)
    case network

    /// Authentication errors (2000-2999)
    case authentication

    /// Data errors (3000-3999)
    case data

    /// User input errors (4000-4999)
    case userInput

    /// Permission errors (5000-5999)
    case permission

    /// Chore management errors (6000-6999)
    case choreManagement

    /// Reward management errors (7000-7999)
    case rewardManagement

    /// Point management errors (8000-8999)
    case pointManagement

    /// System errors (9000-9999)
    case system

    /// The display name for the category
    public var displayName: String {
        switch self {
        case .general:
            return "General"
        case .network:
            return "Network"
        case .authentication:
            return "Authentication"
        case .data:
            return "Data"
        case .userInput:
            return "User Input"
        case .permission:
            return "Permission"
        case .choreManagement:
            return "Chore Management"
        case .rewardManagement:
            return "Reward Management"
        case .pointManagement:
            return "Point Management"
        case .system:
            return "System"
        }
    }
}
