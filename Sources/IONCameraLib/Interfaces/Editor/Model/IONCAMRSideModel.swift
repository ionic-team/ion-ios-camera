/// Structure that manages the horizontal and vertical sides of the crop/drag gesture.
struct IONCAMRSideModel {
    /// The value that represents the lowest value for a side (`left` for horizontal and `top` for vertical).
    static var lowerValue = 0
    /// The value that represents the highest value for a side ( `right` for horizontal and `bottom` for vertical).
    static var upperValue: Int {
        lowerValue + HorizontalSide.allCases.count - 1
    }

    /// Enumerator representing all the values for an horizontal side.
    enum HorizontalSide: Int, CaseIterable {
        case left = 0
        case mid
        case right
    }

    /// Enumerator representing all the values for a vertical side.
    enum VerticalSide: Int, CaseIterable {
        case top = 0
        case mid
        case bottom
    }

    /// The value representing the vertical side of the structure.
    let vertical: VerticalSide
    /// The value represeinting the horizontal side of the structure.
    let horizontal: HorizontalSide
}
