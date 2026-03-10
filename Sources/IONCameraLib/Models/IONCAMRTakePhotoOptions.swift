private enum IONCAMRTakePhotoOptionsError: Error {
    case invalid(field: String)
}

/// Object that contains all user configurable object to be applied to the plugin.
public class IONCAMRTakePhotoOptions: IONCAMRMediaOptions {
    /// Picture quality, in percentage.
    let quality: Int
    /// Height and width of the resulting photo.
    let size: IONCAMRSize?
    /// Indicates if it should fix the orientation when a photo is taken on a configuration different from the standard one (Back Camera and Up).
    let correctOrientation: Bool
    /// Indicates  the format to "store" the image.
    let encodingType: IONCAMREncodingType
    
    public init(
        quality: Int,
        size: IONCAMRSize? = nil,
        correctOrientation: Bool,
        encodingType: IONCAMREncodingType,
        saveToGallery: Bool,
        direction: IONCAMRDirection,
        allowEdit: Bool,
        returnMetadata: Bool
    ) throws {
        func throwError(field: String) -> IONCAMRTakePhotoOptionsError {
            IONCAMRTakePhotoOptionsError.invalid(field: field)
        }

        if quality < 0 || quality > 100 { throw throwError(field: "quality") }
        if let width = size?.width, let height = size?.height {
            guard width > 0, height > 0 else { throw throwError(field: "size") }
        }

        self.quality = quality
        self.size = size
        self.correctOrientation = correctOrientation
        self.encodingType = encodingType
        super.init(
            mediaType: .picture, saveToGallery: saveToGallery, returnMetadata: returnMetadata, direction: direction, allowEdit: allowEdit
        )
    }
}

extension IONCAMRTakePhotoOptions {
    struct ThumbnailDefaultConfigurations {
        static let quality = 1
        static let resolution = 1080
    }

    static var defaultSquare: IONCAMRSize? { try? .initSquare(with: ThumbnailDefaultConfigurations.resolution) }
}
