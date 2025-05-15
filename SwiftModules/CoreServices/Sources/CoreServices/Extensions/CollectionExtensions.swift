import Foundation

/// Extensions for Array
public extension Array {

    /// Access an element at the specified index, returning nil if the index is out of bounds
    /// - Parameter index: The index
    /// - Returns: The element at the index, or nil if out of bounds
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    /// Check if the array is not empty
    var isNotEmpty: Bool {
        return !isEmpty
    }

    /// Get a random element from the array
    /// - Returns: A random element, or nil if the array is empty
    func randomElement() -> Element? {
        guard !isEmpty else {
            return nil
        }

        let randomIndex = Int.random(in: 0..<count)
        return self[randomIndex]
    }

    /// Get a random subset of elements from the array
    /// - Parameter count: The number of elements to get
    /// - Returns: An array of random elements
    func randomElements(count: Int) -> [Element] {
        guard count > 0, !self.isEmpty else {
            return []
        }

        let shuffled = self.shuffled()
        let actualCount = Swift.min(count, self.count)
        return Array(shuffled.prefix(actualCount))
    }

    /// Split the array into chunks of the specified size
    /// - Parameter size: The chunk size
    /// - Returns: An array of chunks
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0, !self.isEmpty else {
            return []
        }

        return stride(from: 0, to: self.count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, self.count)])
        }
    }

    /// Remove duplicates from the array
    /// - Parameter keyPath: The key path to use for comparison
    /// - Returns: An array with duplicates removed
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

/// Extensions for Dictionary
public extension Dictionary {

    /// Get a value for a key, or a default value if the key is not present
    /// - Parameters:
    ///   - key: The key
    ///   - defaultValue: The default value
    /// - Returns: The value for the key, or the default value
    func value(for key: Key, default defaultValue: Value) -> Value {
        return self[key] ?? defaultValue
    }

    /// Map the values of the dictionary
    /// - Parameter transform: The transform function
    /// - Returns: A new dictionary with transformed values
    func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> [Key: T] {
        var result = [Key: T]()
        for (key, value) in self {
            result[key] = try transform(value)
        }
        return result
    }

    /// Filter the dictionary
    /// - Parameter isIncluded: The filter function
    /// - Returns: A new dictionary with filtered key-value pairs
    func filter(_ isIncluded: (Key, Value) throws -> Bool) rethrows -> [Key: Value] {
        var result = [Key: Value]()
        for (key, value) in self {
            if try isIncluded(key, value) {
                result[key] = value
            }
        }
        return result
    }
}

/// Extensions for Set
public extension Set {

    /// Toggle the presence of an element in the set
    /// - Parameter element: The element to toggle
    /// - Returns: True if the element was added, false if it was removed
    @discardableResult
    mutating func toggle(_ element: Element) -> Bool {
        if contains(element) {
            remove(element)
            return false
        } else {
            insert(element)
            return true
        }
    }

    /// Create a new set by applying a transform to each element
    /// - Parameter transform: The transform function
    /// - Returns: A new set with transformed elements
    func map<T: Hashable>(_ transform: (Element) throws -> T) rethrows -> Set<T> {
        var result = Set<T>()
        for element in self {
            result.insert(try transform(element))
        }
        return result
    }

    /// Create a new set by applying a transform to each element and flattening the results
    /// - Parameter transform: The transform function
    /// - Returns: A new set with transformed elements
    func flatMap<T: Hashable>(_ transform: (Element) throws -> [T]) rethrows -> Set<T> {
        var result = Set<T>()
        for element in self {
            for transformed in try transform(element) {
                result.insert(transformed)
            }
        }
        return result
    }
}
