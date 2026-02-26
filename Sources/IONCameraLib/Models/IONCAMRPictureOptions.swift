private enum IONCAMRPictureOptionsError: Error {
    case invalid(field: String)
}

/// Object that contains all user configurable object to be applied to the plugin.
public class IONCAMRPictureOptions: IONCAMRMediaOptions {
    /// Picture quality, in percentage.
    let quality: Int
    /// Height and width of the resulting picture.
    let size: IONCAMRSize?
    /// Indicates if it should fix the orientation when a photo is taken on a configuration different from the standard one (Back Camera and Up).
    let correctOrientation: Bool
    /// Indicates  the format to "store" the image.
    let encodingType: IONCAMREncodingType
    let latestVersion: Bool
    
    public init(
        quality: Int,
        size: IONCAMRSize? = nil,
        correctOrientation: Bool,
        encodingType: IONCAMREncodingType,
        saveToPhotoAlbum: Bool,
        direction: IONCAMRDirection,
        allowEdit: Bool,
        returnMetadata: Bool,
        latestVersion: Bool
    ) throws {
        func throwError(field: String) -> IONCAMRPictureOptionsError {
            IONCAMRPictureOptionsError.invalid(field: field)
        }

        if quality < 0 || quality > 100 { throw throwError(field: "quality") }
        if let width = size?.width, let height = size?.height {
            guard width > 0, height > 0 else { throw throwError(field: "size") }
        }

        self.quality = quality
        self.size = size
        self.correctOrientation = correctOrientation
        self.encodingType = encodingType
        self.latestVersion = latestVersion
        super.init(
            mediaType: .picture, saveToPhotoAlbum: saveToPhotoAlbum, returnMetadata: returnMetadata, direction: direction, allowEdit: allowEdit
        )
    }
}

extension IONCAMRPictureOptions {
    struct ThumbnailDefaultConfigurations {
        static let quality = 1
        static let resolution = 1080
    }

    static var defaultSquare: IONCAMRSize? { try? .initSquare(with: ThumbnailDefaultConfigurations.resolution) }
}

/// Format for the resulting encoded image.
public enum IONCAMREncodingType: Int, CustomStringConvertible {
    case jpeg = 0
    case png
    
    public var description: String {
        switch self {
        case .jpeg: return "jpeg"
        case .png: return "png"
        }
    }
}

private enum IONCAMRSizeError: Error {
    case invalid(field: String)
}

/// Target size for the resulting image.
public struct IONCAMRSize {
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
