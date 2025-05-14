import Foundation
import SwiftUI

/// Utility for RTL support
public enum RTLSupport {
    /// Gets the text alignment for the current language
    /// - Returns: The text alignment
    public static func textAlignment() -> TextAlignment {
        return LocalizationService().isRightToLeft() ? .trailing : .leading
    }
    
    /// Gets the horizontal alignment for the current language
    /// - Returns: The horizontal alignment
    public static func horizontalAlignment() -> HorizontalAlignment {
        return LocalizationService().isRightToLeft() ? .trailing : .leading
    }
    
    /// Gets the edge insets for the current language
    /// - Parameters:
    ///   - leading: The leading inset
    ///   - trailing: The trailing inset
    /// - Returns: The edge insets
    public static func edgeInsets(leading: CGFloat, trailing: CGFloat) -> EdgeInsets {
        if LocalizationService().isRightToLeft() {
            return EdgeInsets(top: 0, leading: trailing, bottom: 0, trailing: leading)
        } else {
            return EdgeInsets(top: 0, leading: leading, bottom: 0, trailing: trailing)
        }
    }
    
    /// Gets the padding for the current language
    /// - Parameters:
    ///   - leading: The leading padding
    ///   - trailing: The trailing padding
    /// - Returns: The edge insets
    public static func padding(leading: CGFloat, trailing: CGFloat) -> EdgeInsets {
        return edgeInsets(leading: leading, trailing: trailing)
    }
    
    /// Gets the flipped value for the current language
    /// - Parameter value: The value to flip
    /// - Returns: The flipped value if RTL, the original value otherwise
    public static func flipIfNeeded(_ value: CGFloat) -> CGFloat {
        return LocalizationService().isRightToLeft() ? -value : value
    }
    
    /// Gets the flipped point for the current language
    /// - Parameter point: The point to flip
    /// - Returns: The flipped point if RTL, the original point otherwise
    public static func flipIfNeeded(_ point: CGPoint) -> CGPoint {
        return LocalizationService().isRightToLeft() ? CGPoint(x: -point.x, y: point.y) : point
    }
}
