private enum IONCAMRSizeError: Error {
    case invalid(field: String)
}

/// Target size for the resulting image.
public struct IONCAMRSize: Decodable {
    /// Width for the image.
    let width: Int
    /// Height for the image.
    let height: Int

    /// Constructor
    /// - Parameters:
    ///   - width: Width to set.
    ///   - height: Height to set.
    public init(width: Int, height: Int) throws {
        func throwError(field: String) -> IONCAMRSizeError {
            IONCAMRSizeError.invalid(field: field)
        }

        guard width > 0 else { throw throwError(field: "width") }
        guard height > 0 else { throw throwError(field: "height") }

        self.width = width
        self.height = height
    }

    static func initSquare(with size: Int) throws -> IONCAMRSize {
        try self.init(width: size, height: size)
    }
}
