//
//  AppDestination.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-18.
//

import Foundation
import SwiftUI

/// Enum defining all possible navigation destinations in the app
enum AppDestination: Hashable {
    // Chore-related destinations
    case choreList
    case choreCalendar
    case choreDetail(id: Int64)
    case addChore

    // Child-related destinations
    case childProfile(id: Int64)

    // Parent-specific destinations
    case rewards
    case statistics
    case family

    // Other destinations can be added as needed
}
