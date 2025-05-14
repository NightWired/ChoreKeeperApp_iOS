//
//  ErrorSeverity.swift
//  ErrorHandler
//
//  Created on 2023-05-16.
//

import Foundation

/// Error severity levels for categorizing errors based on their impact
public enum ErrorSeverity: String, Codable {
    /// Low severity - informational errors that don't significantly impact functionality
    case low
    
    /// Medium severity - errors that impact some functionality but don't prevent core operations
    case medium
    
    /// High severity - errors that significantly impact core functionality
    case high
    
    /// Critical severity - errors that prevent the application from functioning properly
    case critical
    
    /// The display name for the severity level
    public var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .critical:
            return "Critical"
        }
    }
    
    /// Indicates whether the error should be reported to analytics/logging services
    public var shouldReport: Bool {
        switch self {
        case .low:
            return false
        case .medium, .high, .critical:
            return true
        }
    }
    
    /// Indicates whether the error should be displayed to the user
    public var shouldDisplayToUser: Bool {
        switch self {
        case .low:
            return false
        case .medium, .high, .critical:
            return true
        }
    }
}
