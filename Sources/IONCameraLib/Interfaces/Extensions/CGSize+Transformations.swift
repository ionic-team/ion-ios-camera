import CoreGraphics

/// Provides a conversion from the user defined size to the `CoreGraphics` equivalent.
extension CGSize {
    /// Constructor based on the `IONCAMRSize` object.
    /// - Parameter size: Height and width configured on the Options.
    init(size: IONCAMRSize) {
        self.init(width: size.width, height: size.height)
    }

    init(resolution: Int) throws {
        let size = try IONCAMRSize(width: resolution, height: resolution)
        self.init(size: size)
    }
}

extension CGSize {
    var resolution: String {
        if height < width {
            "\(Int(width))x\(Int(height))"
        } else {
            "\(Int(height))x\(Int(width))"
        }
    }
}
