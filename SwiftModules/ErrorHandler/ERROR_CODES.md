# Error Codes Reference

This document provides a comprehensive list of all error codes used in the ChoreKeeper application.

## Error Code Format

Error codes are formatted as `E####` where #### is a 4-digit number. The first digit indicates the category of the error:

- `E0###`: General Errors
- `E1###`: Network Errors
- `E2###`: Authentication Errors
- `E3###`: Data Errors
- `E4###`: User Input Errors
- `E5###`: Permission Errors
- `E6###`: Chore Management Errors
- `E7###`: Reward Management Errors
- `E8###`: Point Management Errors
- `E9###`: System Errors

## General Errors (1-999)

| Code | Enum Case | Description |
|------|-----------|-------------|
| E0001 | unknown | An unknown error occurred |
| E0002 | operationCancelled | The operation was cancelled |
| E0003 | invalidInput | Invalid input was provided |
| E0004 | invalidState | The application is in an invalid state for this operation |
| E0005 | permissionDenied | Permission was denied for this operation |
| E0006 | operationFailed | The operation failed |
| E0007 | notImplemented | This feature is not implemented yet |
| E0008 | internalError | An internal error occurred |
| E0009 | timeoutError | The operation timed out |

## Network Errors (1000-1999)

| Code | Enum Case | Description |
|------|-----------|-------------|
| E1000 | networkError | A general network error occurred |
| E1001 | noInternetConnection | No internet connection is available |
| E1002 | timeout | The network request timed out |
| E1003 | requestFailed | The network request failed |
| E1004 | serverError | The server returned an error |
| E1005 | serverUnavailable | The server is currently unavailable |
| E1006 | invalidResponse | The server returned an invalid response |
| E1007 | invalidURL | The URL is invalid |
| E1008 | connectionLost | The network connection was lost during the request |
| E1009 | sslError | An SSL error occurred |

## Authentication Errors (2000-2999)

| Code | Enum Case | Description |
|------|-----------|-------------|
| E2000 | authenticationError | A general authentication error occurred |
| E2001 | invalidCredentials | The provided credentials are invalid |
| E2002 | accountNotFound | The account was not found |
| E2003 | accountLocked | The account is locked |
| E2004 | sessionExpired | The session has expired |
| E2005 | tokenExpired | The authentication token has expired |
| E2006 | tokenInvalid | The authentication token is invalid |
| E2007 | notAuthenticated | The user is not authenticated |
| E2008 | tooManyAttempts | Too many authentication attempts |
| E2009 | emailNotVerified | The email address has not been verified |

## Data Errors (3000-3999)

| Code | Enum Case | Description |
|------|-----------|-------------|
| E3000 | dataError | A general data error occurred |
| E3001 | dataNotFound | The requested data was not found |
| E3002 | dataCorrupted | The data is corrupted |
| E3003 | dataSaveFailed | Failed to save data |
| E3004 | dataLoadFailed | Failed to load data |
| E3005 | dataDeleteFailed | Failed to delete data |
| E3006 | dataUpdateFailed | Failed to update data |
| E3007 | dataValidationFailed | Data validation failed |
| E3008 | duplicateData | The data already exists |
| E3009 | dataConflict | A data conflict occurred |

## User Input Errors (4000-4999)

| Code | Enum Case | Description |
|------|-----------|-------------|
| E4000 | inputError | A general input error occurred |
| E4001 | requiredFieldMissing | A required field is missing |
| E4002 | invalidFormat | The input format is invalid |
| E4003 | invalidEmail | The email address is invalid |
| E4004 | invalidPassword | The password is invalid |
| E4005 | passwordMismatch | The passwords do not match |
| E4006 | invalidUsername | The username is invalid |
| E4007 | invalidDate | The date is invalid |
| E4008 | invalidTime | The time is invalid |
| E4009 | invalidPhoneNumber | The phone number is invalid |

## Permission Errors (5000-5999)

| Code | Enum Case | Description |
|------|-----------|-------------|
| E5000 | permissionError | A general permission error occurred |
| E5001 | notAuthorized | The user is not authorized for this action |
| E5002 | parentPermissionRequired | Parent permission is required for this action |
| E5003 | adminPermissionRequired | Admin permission is required for this action |
| E5004 | devicePermissionDenied | Permission to access device features was denied |
| E5005 | cameraPermissionDenied | Permission to access the camera was denied |
| E5006 | photoLibraryPermissionDenied | Permission to access the photo library was denied |
| E5007 | notificationPermissionDenied | Permission to send notifications was denied |
| E5008 | locationPermissionDenied | Permission to access location was denied |
| E5009 | biometricPermissionDenied | Permission to use biometric authentication was denied |

## Chore Management Errors (6000-6999)

| Code | Enum Case | Description |
|------|-----------|-------------|
| E6000 | choreError | A general chore error occurred |
| E6001 | choreNotFound | The chore was not found |
| E6002 | choreAlreadyCompleted | The chore is already marked as completed |
| E6003 | choreAlreadyVerified | The chore is already verified |
| E6004 | choreNotAssigned | The chore is not assigned to any user |
| E6005 | choreNotDue | The chore is not due yet |
| E6006 | choreOverdue | The chore is overdue |
| E6007 | choreCreationFailed | Failed to create the chore |
| E6008 | choreUpdateFailed | Failed to update the chore |
| E6009 | choreDeleteFailed | Failed to delete the chore |

## Reward Management Errors (7000-7999)

| Code | Enum Case | Description |
|------|-----------|-------------|
| E7000 | rewardError | A general reward error occurred |
| E7001 | rewardNotFound | The reward was not found |
| E7002 | rewardAlreadyClaimed | The reward has already been claimed |
| E7003 | rewardAlreadyRedeemed | The reward has already been redeemed |
| E7004 | rewardExpired | The reward has expired |
| E7005 | insufficientPoints | Not enough points to claim the reward |
| E7006 | rewardCreationFailed | Failed to create the reward |
| E7007 | rewardUpdateFailed | Failed to update the reward |
| E7008 | rewardDeleteFailed | Failed to delete the reward |
| E7009 | rewardNotAvailable | The reward is not available |

## Point Management Errors (8000-8999)

| Code | Enum Case | Description |
|------|-----------|-------------|
| E8000 | pointError | A general point error occurred |
| E8001 | pointTransactionFailed | The point transaction failed |
| E8002 | negativePointsNotAllowed | Negative points are not allowed |
| E8003 | pointBalanceNotFound | The point balance was not found |
| E8004 | pointAdjustmentFailed | Failed to adjust points |
| E8005 | pointHistoryNotFound | The point history was not found |
| E8006 | pointCalculationError | An error occurred during point calculation |
| E8007 | pointSyncFailed | Failed to synchronize points |
| E8008 | pointLimitExceeded | The point limit has been exceeded |
| E8009 | pointTransferFailed | Failed to transfer points |

## System Errors (9000-9999)

| Code | Enum Case | Description |
|------|-----------|-------------|
| E9000 | systemError | A general system error occurred |
| E9001 | fileSystemError | A file system error occurred |
| E9002 | databaseError | A database error occurred |
| E9003 | memoryError | A memory error occurred |
| E9004 | deviceError | A device error occurred |
| E9005 | appVersionNotSupported | This app version is no longer supported |
| E9006 | maintenanceMode | The system is in maintenance mode |
| E9007 | resourceNotAvailable | A required resource is not available |
| E9008 | configurationError | A configuration error occurred |
| E9009 | unexpectedError | An unexpected error occurred |
