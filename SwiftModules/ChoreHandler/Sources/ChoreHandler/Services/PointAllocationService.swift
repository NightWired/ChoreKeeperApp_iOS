import Foundation
import CoreData
import CoreServices
import ErrorHandler
import LocalizationHandler
import PointsHandler
import DataModels

/// Implementation of the PointAllocationServiceProtocol using the PointsHandler module
public class PointAllocationService: PointAllocationServiceProtocol {
    // MARK: - Properties

    /// The point service from PointsHandler module
    private let pointService: PointService

    /// User repository for user lookups
    private let userRepository: UserRepository

    /// Chore repository for chore lookups
    private let choreRepository: ChoreRepository

    // MARK: - Initialization

    /// Creates a new point allocation service
    public init() {
        self.pointService = PointService.shared
        self.userRepository = UserRepository.shared
        self.choreRepository = ChoreRepository.shared
    }
    
    // MARK: - PointAllocationServiceProtocol Implementation
    
    /// Allocates points for a completed chore
    /// - Parameters:
    ///   - points: The number of points to allocate
    ///   - userId: The ID of the user to allocate points to
    ///   - choreId: The ID of the chore that was completed
    ///   - completionDate: The date the chore was completed
    /// - Returns: Whether the points were successfully allocated
    /// - Throws: An error if the points could not be allocated
    public func allocatePoints(
        points: Int16,
        userId: UUID,
        choreId: Int64,
        completionDate: Date
    ) throws -> Bool {
        do {
            // Get the user entity
            guard let user = try userRepository.fetchByUUID(userId) else {
                Logger.error("User not found for point allocation: \(userId)")
                return false
            }

            // Get the chore entity
            guard let chore = try choreRepository.fetch(byId: choreId) else {
                Logger.error("Chore not found for point allocation: \(choreId)")
                return false
            }

            // Allocate points using PointsHandler
            try pointService.allocatePoints(
                amount: points,
                to: user,
                for: .choreCompletion,
                chore: chore,
                reason: nil // Will use default localized reason
            )

            Logger.info("Successfully allocated \(points) points to user \(userId) for completed chore \(choreId)")
            return true

        } catch {
            Logger.error("Failed to allocate points: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Deducts points for a missed chore
    /// - Parameters:
    ///   - points: The number of points to deduct
    ///   - userId: The ID of the user to deduct points from
    ///   - choreId: The ID of the chore that was missed
    ///   - missedDate: The date the chore was missed
    /// - Returns: Whether the points were successfully deducted
    /// - Throws: An error if the points could not be deducted
    public func deductPoints(
        points: Int16,
        userId: UUID,
        choreId: Int64,
        missedDate: Date
    ) throws -> Bool {
        do {
            // Get the user entity
            guard let user = try userRepository.fetchByUUID(userId) else {
                Logger.error("User not found for point deduction: \(userId)")
                return false
            }

            // Get the chore entity
            guard let chore = try choreRepository.fetch(byId: choreId) else {
                Logger.error("Chore not found for point deduction: \(choreId)")
                return false
            }

            // Deduct points using PointsHandler
            try pointService.deductPoints(
                amount: points,
                from: user,
                for: .choreMissed,
                chore: chore,
                reason: nil // Will use default localized reason
            )

            Logger.info("Successfully deducted \(points) points from user \(userId) for missed chore \(choreId)")
            return true

        } catch {
            Logger.error("Failed to deduct points: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Gets the total points for a user
    /// - Parameter userId: The ID of the user
    /// - Returns: The total points for the user
    /// - Throws: An error if the points could not be retrieved
    public func getTotalPoints(userId: UUID) throws -> Int {
        do {
            // Get the user entity
            guard let user = try userRepository.fetchByUUID(userId) else {
                Logger.error("User not found for point total query: \(userId)")
                return 0
            }

            // Get point totals using PointsHandler
            let totals = try pointService.getPointTotals(for: user)
            return Int(totals.current)

        } catch {
            Logger.error("Failed to get total points: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Gets the daily points for a user
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - date: The date to get points for
    /// - Returns: The daily points for the user
    /// - Throws: An error if the points could not be retrieved
    public func getDailyPoints(userId: UUID, date: Date) throws -> Int {
        do {
            // Get the user entity
            guard let user = try userRepository.fetchByUUID(userId) else {
                Logger.error("User not found for daily points query: \(userId)")
                return 0
            }

            // Get point totals using PointsHandler
            let totals = try pointService.getPointTotals(for: user)
            return Int(totals.daily)

        } catch {
            Logger.error("Failed to get daily points: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Gets the weekly points for a user
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - weekStartDate: The start date of the week
    /// - Returns: The weekly points for the user
    /// - Throws: An error if the points could not be retrieved
    public func getWeeklyPoints(userId: UUID, weekStartDate: Date) throws -> Int {
        do {
            // Get the user entity
            guard let user = try userRepository.fetchByUUID(userId) else {
                Logger.error("User not found for weekly points query: \(userId)")
                return 0
            }

            // Get point totals using PointsHandler
            let totals = try pointService.getPointTotals(for: user)
            return Int(totals.weekly)

        } catch {
            Logger.error("Failed to get weekly points: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Gets the monthly points for a user
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - month: The month (1-12)
    ///   - year: The year
    /// - Returns: The monthly points for the user
    /// - Throws: An error if the points could not be retrieved
    public func getMonthlyPoints(userId: UUID, month: Int, year: Int) throws -> Int {
        do {
            // Get the user entity
            guard let user = try userRepository.fetchByUUID(userId) else {
                Logger.error("User not found for monthly points query: \(userId)")
                return 0
            }

            // Get point totals using PointsHandler
            let totals = try pointService.getPointTotals(for: user)
            return Int(totals.monthly)

        } catch {
            Logger.error("Failed to get monthly points: \(error.localizedDescription)")
            throw error
        }
    }
}
