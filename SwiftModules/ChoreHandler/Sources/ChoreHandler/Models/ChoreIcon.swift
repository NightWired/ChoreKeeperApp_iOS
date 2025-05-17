import Foundation

/// Represents an icon for a chore
public struct ChoreIcon: Codable, Equatable, Identifiable {
    /// The unique identifier for the icon
    public let id: String
    
    /// The name of the icon
    public let name: String
    
    /// The system name of the icon (SF Symbol)
    public let systemName: String
    
    /// The category of the icon
    public let category: ChoreIconCategory
    
    /// Creates a new chore icon
    /// - Parameters:
    ///   - id: The unique identifier for the icon
    ///   - name: The name of the icon
    ///   - systemName: The system name of the icon (SF Symbol)
    ///   - category: The category of the icon
    public init(id: String, name: String, systemName: String, category: ChoreIconCategory) {
        self.id = id
        self.name = name
        self.systemName = systemName
        self.category = category
    }
    
    /// The localization key for the icon name
    public var localizationKey: String {
        return "chores.icons.\(id)"
    }
}

/// Represents a category of chore icons
public enum ChoreIconCategory: String, Codable, CaseIterable {
    /// Household chores
    case household = "household"
    
    /// Personal chores
    case personal = "personal"
    
    /// Outdoor chores
    case outdoor = "outdoor"
    
    /// School-related chores
    case school = "school"
    
    /// Pet-related chores
    case pets = "pets"
    
    /// Miscellaneous chores
    case misc = "misc"
    
    /// The display name for the category
    public var displayName: String {
        switch self {
        case .household:
            return "Household"
        case .personal:
            return "Personal"
        case .outdoor:
            return "Outdoor"
        case .school:
            return "School"
        case .pets:
            return "Pets"
        case .misc:
            return "Miscellaneous"
        }
    }
    
    /// The localization key for the category
    public var localizationKey: String {
        switch self {
        case .household:
            return "chores.iconCategories.household"
        case .personal:
            return "chores.iconCategories.personal"
        case .outdoor:
            return "chores.iconCategories.outdoor"
        case .school:
            return "chores.iconCategories.school"
        case .pets:
            return "chores.iconCategories.pets"
        case .misc:
            return "chores.iconCategories.misc"
        }
    }
}

/// Provides a collection of predefined chore icons
public struct ChoreIcons {
    /// All available chore icons
    public static let all: [ChoreIcon] = household + personal + outdoor + school + pets + misc
    
    /// Household chore icons
    public static let household: [ChoreIcon] = [
        ChoreIcon(id: "dishes", name: "Dishes", systemName: "sink", category: .household),
        ChoreIcon(id: "vacuum", name: "Vacuum", systemName: "house", category: .household),
        ChoreIcon(id: "laundry", name: "Laundry", systemName: "washer", category: .household),
        ChoreIcon(id: "trash", name: "Trash", systemName: "trash", category: .household),
        ChoreIcon(id: "bed", name: "Make Bed", systemName: "bed.double", category: .household),
        ChoreIcon(id: "dusting", name: "Dusting", systemName: "sparkles", category: .household),
        ChoreIcon(id: "bathroom", name: "Clean Bathroom", systemName: "shower", category: .household)
    ]
    
    /// Personal chore icons
    public static let personal: [ChoreIcon] = [
        ChoreIcon(id: "teeth", name: "Brush Teeth", systemName: "mouth", category: .personal),
        ChoreIcon(id: "shower", name: "Take Shower", systemName: "shower.handheld", category: .personal),
        ChoreIcon(id: "clothes", name: "Put Away Clothes", systemName: "tshirt", category: .personal),
        ChoreIcon(id: "room", name: "Clean Room", systemName: "square.grid.3x3", category: .personal)
    ]
    
    /// Outdoor chore icons
    public static let outdoor: [ChoreIcon] = [
        ChoreIcon(id: "lawn", name: "Mow Lawn", systemName: "leaf", category: .outdoor),
        ChoreIcon(id: "garden", name: "Garden", systemName: "leaf.arrow.circlepath", category: .outdoor),
        ChoreIcon(id: "snow", name: "Shovel Snow", systemName: "snow", category: .outdoor),
        ChoreIcon(id: "car", name: "Wash Car", systemName: "car", category: .outdoor)
    ]
    
    /// School-related chore icons
    public static let school: [ChoreIcon] = [
        ChoreIcon(id: "homework", name: "Homework", systemName: "book", category: .school),
        ChoreIcon(id: "reading", name: "Reading", systemName: "book.closed", category: .school),
        ChoreIcon(id: "backpack", name: "Pack Backpack", systemName: "bag", category: .school)
    ]
    
    /// Pet-related chore icons
    public static let pets: [ChoreIcon] = [
        ChoreIcon(id: "dog", name: "Walk Dog", systemName: "pawprint", category: .pets),
        ChoreIcon(id: "petFood", name: "Feed Pets", systemName: "cup.and.saucer", category: .pets),
        ChoreIcon(id: "litterBox", name: "Clean Litter Box", systemName: "square.fill", category: .pets)
    ]
    
    /// Miscellaneous chore icons
    public static let misc: [ChoreIcon] = [
        ChoreIcon(id: "custom", name: "Custom", systemName: "star", category: .misc),
        ChoreIcon(id: "phone", name: "Phone Call", systemName: "phone", category: .misc),
        ChoreIcon(id: "mail", name: "Check Mail", systemName: "envelope", category: .misc),
        ChoreIcon(id: "groceries", name: "Groceries", systemName: "cart", category: .misc)
    ]
    
    /// Find a chore icon by ID
    /// - Parameter id: The ID of the icon to find
    /// - Returns: The chore icon, or nil if not found
    public static func find(byId id: String) -> ChoreIcon? {
        return all.first { $0.id == id }
    }
    
    /// Find chore icons by category
    /// - Parameter category: The category to filter by
    /// - Returns: An array of chore icons in the specified category
    public static func find(byCategory category: ChoreIconCategory) -> [ChoreIcon] {
        return all.filter { $0.category == category }
    }
}
