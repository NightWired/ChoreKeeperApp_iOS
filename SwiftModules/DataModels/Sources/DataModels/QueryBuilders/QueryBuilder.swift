import Foundation
import CoreData

/// Comparison operators for query building
public enum ComparisonOperator: String {
    case equal = "=="
    case notEqual = "!="
    case lessThan = "<"
    case lessThanOrEqual = "<="
    case greaterThan = ">"
    case greaterThanOrEqual = ">="
    case contains = "CONTAINS"
    case beginsWith = "BEGINSWITH"
    case endsWith = "ENDSWITH"
    case like = "LIKE"
    case matches = "MATCHES"
    case `in` = "IN"
}

/// Logical operators for query building
public enum LogicalOperator: String {
    case and = "AND"
    case or = "OR"
    case not = "NOT"
}

/// Sort direction for query building
public enum SortDirection {
    case ascending
    case descending
}

/// Query builder for Core Data queries
public class QueryBuilder<Entity: NSManagedObject> {

    // MARK: - Properties

    /// The predicates to apply
    public private(set) var predicates: [NSPredicate] = []

    /// The sort descriptors to apply
    public private(set) var sortDescriptors: [NSSortDescriptor] = []

    /// The fetch limit
    public private(set) var fetchLimit: Int?

    /// The fetch offset
    public private(set) var fetchOffset: Int?

    /// The relationships to prefetch
    public private(set) var relationshipKeyPathsForPrefetching: [String] = []

    // MARK: - Initialization

    /// Initialize a new query builder
    public init() {}

    // MARK: - Public Methods

    /// Add a filter to the query
    /// - Parameters:
    ///   - key: The key to filter on
    ///   - value: The value to filter for
    ///   - operator: The comparison operator to use
    /// - Returns: The query builder
    public func filter(key: String, value: Any, operator: ComparisonOperator = .equal) -> QueryBuilder<Entity> {
        let predicate: NSPredicate

        switch `operator` {
        case .equal:
            predicate = NSPredicate(format: "%K == %@", key, value as! CVarArg)
        case .notEqual:
            predicate = NSPredicate(format: "%K != %@", key, value as! CVarArg)
        case .lessThan:
            predicate = NSPredicate(format: "%K < %@", key, value as! CVarArg)
        case .lessThanOrEqual:
            predicate = NSPredicate(format: "%K <= %@", key, value as! CVarArg)
        case .greaterThan:
            predicate = NSPredicate(format: "%K > %@", key, value as! CVarArg)
        case .greaterThanOrEqual:
            predicate = NSPredicate(format: "%K >= %@", key, value as! CVarArg)
        case .contains:
            predicate = NSPredicate(format: "%K CONTAINS %@", key, value as! CVarArg)
        case .beginsWith:
            predicate = NSPredicate(format: "%K BEGINSWITH %@", key, value as! CVarArg)
        case .endsWith:
            predicate = NSPredicate(format: "%K ENDSWITH %@", key, value as! CVarArg)
        case .like:
            predicate = NSPredicate(format: "%K LIKE %@", key, value as! CVarArg)
        case .matches:
            predicate = NSPredicate(format: "%K MATCHES %@", key, value as! CVarArg)
        case .in:
            if let values = value as? [Any] {
                predicate = NSPredicate(format: "%K IN %@", key, values as CVarArg)
            } else {
                predicate = NSPredicate(format: "%K IN %@", key, [value] as CVarArg)
            }
        }

        predicates.append(predicate)
        return self
    }

    /// Add a predicate to the query
    /// - Parameter predicate: The predicate to add
    /// - Returns: The query builder
    public func filter(predicate: NSPredicate) -> QueryBuilder<Entity> {
        predicates.append(predicate)
        return self
    }

    /// Add a sort descriptor to the query
    /// - Parameters:
    ///   - key: The key to sort on
    ///   - direction: The sort direction
    /// - Returns: The query builder
    public func sort(key: String, direction: SortDirection = .ascending) -> QueryBuilder<Entity> {
        let sortDescriptor = NSSortDescriptor(key: key, ascending: direction == .ascending)
        sortDescriptors.append(sortDescriptor)
        return self
    }

    /// Set the fetch limit
    /// - Parameter limit: The fetch limit
    /// - Returns: The query builder
    public func limit(_ limit: Int) -> QueryBuilder<Entity> {
        fetchLimit = limit
        return self
    }

    /// Set the fetch offset
    /// - Parameter offset: The fetch offset
    /// - Returns: The query builder
    public func offset(_ offset: Int) -> QueryBuilder<Entity> {
        fetchOffset = offset
        return self
    }

    /// Add a relationship to prefetch
    /// - Parameter keyPath: The key path to prefetch
    /// - Returns: The query builder
    public func prefetch(keyPath: String) -> QueryBuilder<Entity> {
        relationshipKeyPathsForPrefetching.append(keyPath)
        return self
    }

    /// Build a fetch request from the query
    /// - Returns: The fetch request
    public func buildFetchRequest() -> NSFetchRequest<Entity> {
        let request = NSFetchRequest<Entity>(entityName: Entity.entity().name!)

        // Set the predicate if we have any
        if !predicates.isEmpty {
            if predicates.count == 1 {
                request.predicate = predicates.first
            } else {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
        }

        // Set the sort descriptors if we have any
        if !sortDescriptors.isEmpty {
            request.sortDescriptors = sortDescriptors
        }

        // Set the fetch limit if we have one
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }

        // Set the fetch offset if we have one
        if let fetchOffset = fetchOffset {
            request.fetchOffset = fetchOffset
        }

        // Set the relationships to prefetch if we have any
        if !relationshipKeyPathsForPrefetching.isEmpty {
            request.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
        }

        return request
    }
}
