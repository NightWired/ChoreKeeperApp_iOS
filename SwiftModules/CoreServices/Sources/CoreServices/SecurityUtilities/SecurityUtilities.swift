import Foundation
import CryptoKit
import LocalizationHandler
import ErrorHandler

/// Security error types
public enum SecurityError: Error {
    case encryptionFailed
    case decryptionFailed
    case keyGenerationFailed
    case keychainError(OSStatus)
    case invalidData
    case unsupportedPlatform
}

/// Utilities for security operations
public struct SecurityUtilities {

    // MARK: - Encryption/Decryption

    /// Encrypt data using AES-GCM
    /// - Parameters:
    ///   - data: The data to encrypt
    ///   - key: The encryption key
    /// - Returns: The encrypted data
    /// - Throws: SecurityError if encryption fails
    public static func encrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined ?? Data()
        } catch {
            Logger.error("Encryption failed: \(error.localizedDescription)")
            throw SecurityError.encryptionFailed
        }
    }

    /// Decrypt data using AES-GCM
    /// - Parameters:
    ///   - data: The encrypted data
    ///   - key: The encryption key
    /// - Returns: The decrypted data
    /// - Throws: SecurityError if decryption fails
    public static func decrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            Logger.error("Decryption failed: \(error.localizedDescription)")
            throw SecurityError.decryptionFailed
        }
    }

    /// Generate a random symmetric key
    /// - Parameter bitCount: The bit count for the key (default: 256)
    /// - Returns: The generated key
    public static func generateSymmetricKey(bitCount: Int = 256) -> SymmetricKey {
        return SymmetricKey(size: SymmetricKeySize(bitCount: bitCount))
    }

    /// Generate a symmetric key from a password and salt
    /// - Parameters:
    ///   - password: The password
    ///   - salt: The salt
    ///   - bitCount: The bit count for the key (default: 256)
    /// - Returns: The generated key
    public static func keyFromPassword(_ password: String, salt: Data, bitCount: Int = 256) -> SymmetricKey {
        // Create a key with the specified bit count
        return SymmetricKey(size: SymmetricKeySize(bitCount: bitCount))
    }

    // MARK: - Hashing

    /// Compute the SHA-256 hash of data
    /// - Parameter data: The data to hash
    /// - Returns: The hash as a hex string
    public static func sha256(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Compute the SHA-256 hash of a string
    /// - Parameter string: The string to hash
    /// - Returns: The hash as a hex string
    public static func sha256(_ string: String) -> String {
        let data = Data(string.utf8)
        return sha256(data)
    }

    /// Compute the HMAC-SHA256 of data
    /// - Parameters:
    ///   - data: The data to authenticate
    ///   - key: The authentication key
    /// - Returns: The HMAC as a hex string
    public static func hmacSHA256(_ data: Data, key: SymmetricKey) -> String {
        let authenticationCode = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return authenticationCode.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Keychain

    /// Store data securely in the keychain
    /// - Parameters:
    ///   - data: The data to store
    ///   - key: The key to store the data under
    ///   - service: The service name (default: "com.chorekeeper")
    /// - Throws: SecurityError if storing fails
    public static func storeInKeychain(_ data: Data, forKey key: String, service: String = "com.chorekeeper") throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            Logger.error("Failed to store in keychain: \(status)")
            throw SecurityError.keychainError(status)
        }
    }

    /// Retrieve data securely from the keychain
    /// - Parameters:
    ///   - key: The key to retrieve the data for
    ///   - service: The service name (default: "com.chorekeeper")
    /// - Returns: The retrieved data
    /// - Throws: SecurityError if retrieval fails
    public static func retrieveFromKeychain(forKey key: String, service: String = "com.chorekeeper") throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            Logger.error("Failed to retrieve from keychain: \(status)")
            throw SecurityError.keychainError(status)
        }

        guard let data = item as? Data else {
            throw SecurityError.invalidData
        }

        return data
    }

    /// Delete data from the keychain
    /// - Parameters:
    ///   - key: The key to delete the data for
    ///   - service: The service name (default: "com.chorekeeper")
    /// - Throws: SecurityError if deletion fails
    public static func deleteFromKeychain(forKey key: String, service: String = "com.chorekeeper") throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            Logger.error("Failed to delete from keychain: \(status)")
            throw SecurityError.keychainError(status)
        }
    }

    // MARK: - Convenience Methods

    /// Store a string securely in the keychain
    /// - Parameters:
    ///   - string: The string to store
    ///   - key: The key to store the string under
    ///   - service: The service name (default: "com.chorekeeper")
    /// - Throws: SecurityError if storing fails
    public static func storeSecurely(_ string: String, for key: String, service: String = "com.chorekeeper") throws {
        guard let data = string.data(using: .utf8) else {
            throw SecurityError.invalidData
        }

        try storeInKeychain(data, forKey: key, service: service)
    }

    /// Retrieve a string securely from the keychain
    /// - Parameters:
    ///   - key: The key to retrieve the string for
    ///   - service: The service name (default: "com.chorekeeper")
    /// - Returns: The retrieved string
    /// - Throws: SecurityError if retrieval fails
    public static func retrieveSecurely(for key: String, service: String = "com.chorekeeper") throws -> String {
        let data = try retrieveFromKeychain(forKey: key, service: service)

        guard let string = String(data: data, encoding: .utf8) else {
            throw SecurityError.invalidData
        }

        return string
    }
}
