# PointsHandler

A Swift module providing comprehensive point management functionality for the ChoreKeeper iOS application.

## Overview

The PointsHandler module manages all aspects of the point system in ChoreKeeper, including point allocation, tracking, manual adjustments, and historical data management. It provides a clean API for point operations while maintaining data integrity and supporting various point-earning and spending scenarios.

## Features

- **Point Allocation**: Automatic point allocation for completed chores
- **Point Deduction**: Automatic point deduction for missed chores
- **Manual Adjustments**: Parent-initiated point adjustments with reason tracking
- **Period Tracking**: Track points by daily, weekly, and monthly periods
- **Transaction History**: Comprehensive transaction logging for all point changes
- **Statistics**: Point statistics and reporting capabilities
- **Balance Management**: Current point balance tracking with optional negative balance support
- **Data Persistence**: All point data persists even after chore deletion

## Architecture

The PointsHandler module follows a service-oriented architecture with clear separation of concerns:

1. **PointService**: Main service for point operations and business logic
2. **PointTransactionService**: Service for managing point transaction history
3. **PointStatisticsService**: Service for generating point statistics and reports
4. **Repository Integration**: Uses DataModels repositories for data persistence
5. **Error Handling**: Comprehensive error handling with localized messages

## Core Components

### PointService

The main service class that handles all point operations:

- Point allocation and deduction
- Manual point adjustments
- Balance calculations
- Period total management
- Integration with chore completion/missing

### PointTransactionService

Manages the transaction history system:

- Transaction recording for all point changes
- Transaction filtering and querying
- Historical data management
- Statistics generation

### PointStatisticsService

Provides statistical analysis of point data:

- Period-based statistics (daily, weekly, monthly)
- Earning vs spending analysis
- Performance trends
- Achievement tracking

## Point Transaction Types

The module supports various transaction types:

- **chore_completion**: Points earned from completing chores
- **chore_missed**: Points lost from missing chores
- **manual_adjustment**: Parent-initiated point adjustments
- **reward_redemption**: Points spent on rewards
- **penalty_applied**: Points deducted due to penalties
- **bonus**: Bonus points awarded
- **correction**: Correction adjustments

## Usage

### Basic Point Operations

```swift
import PointsHandler

// Get the point service
let pointService = PointService.shared

// Allocate points for chore completion
try pointService.allocatePoints(
    amount: 10,
    to: user,
    for: .choreCompletion,
    chore: chore,
    reason: "Completed 'Clean Room'"
)

// Deduct points for missed chore
try pointService.deductPoints(
    amount: 5,
    from: user,
    for: .choreMissed,
    chore: chore,
    reason: "Missed 'Take Out Trash'"
)

// Manual point adjustment
try pointService.adjustPoints(
    amount: 20,
    for: user,
    reason: "Good behavior bonus",
    adjustedBy: parentUser
)
```

### Point Balance and Statistics

```swift
// Get current point totals
let totals = try pointService.getPointTotals(for: user)
print("Current: \(totals["current"] ?? 0)")
print("Daily: \(totals["daily"] ?? 0)")
print("Weekly: \(totals["weekly"] ?? 0)")
print("Monthly: \(totals["monthly"] ?? 0)")

// Check if user has sufficient points
let hasEnough = try pointService.hasSufficientPoints(user, amount: 50)

// Get transaction history
let transactions = try pointService.getTransactionHistory(
    for: user,
    limit: 20,
    transactionType: .choreCompletion
)

// Get statistics
let stats = try pointService.getStatistics(
    for: user,
    period: .thisMonth
)
```

### Period Management

```swift
// Reset period totals (typically done automatically)
try pointService.resetDailyTotals(for: user)
try pointService.resetWeeklyTotals(for: user)
try pointService.resetMonthlyTotals(for: user)
```

## Integration with Other Modules

### ChoreHandler Integration

The PointsHandler integrates seamlessly with the ChoreHandler module:

- Automatic point allocation when chores are completed
- Automatic point deduction when chores are missed
- Point value configuration per chore
- Period-specific point tracking

### DataModels Integration

Uses the DataModels module for data persistence:

- PointRepository for point balance management
- PointTransactionRepository for transaction history
- Relationship management with User, Chore, Reward, and Penalty entities

### ErrorHandler Integration

Comprehensive error handling with localized error messages:

- Point allocation/deduction errors
- Insufficient balance errors
- Invalid amount errors
- Transaction recording errors

### LocalizationHandler Integration

All user-facing messages are localized:

- Transaction descriptions
- Error messages
- Statistical reports
- UI component text

## Configuration

The module supports various configuration options:

- **Allow Negative Balances**: Whether users can have negative point balances
- **Period Reset Schedule**: When to reset daily/weekly/monthly totals
- **Transaction Retention**: How long to keep transaction history
- **Statistical Periods**: Which periods to track for statistics

## Testing

The module includes comprehensive test coverage:

- Unit tests for all service methods
- Integration tests with mock repositories
- Error handling tests
- Performance tests for large datasets

## Dependencies

- **CoreServices**: Logging, configuration, and utilities
- **ErrorHandler**: Standardized error handling
- **LocalizationHandler**: Localized strings and messages
- **DataModels**: Data persistence and repository patterns

## Future Enhancements

Planned features for future versions:

- Point multipliers for special events
- Achievement-based bonus points
- Point transfer between family members
- Advanced analytics and reporting
- Point prediction algorithms

---

For detailed API documentation, see the inline documentation in the source files.
