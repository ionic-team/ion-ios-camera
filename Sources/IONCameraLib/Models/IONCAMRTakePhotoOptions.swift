private enum IONCAMRTakePhotoOptionsError: Error {
    case invalid(field: String)
}

/// Object that contains all user configurable object to be applied to the plugin.
public class IONCAMRTakePhotoOptions: IONCAMRMediaOptions, Decodable {
    /// Picture quality, in percentage.
    let quality: Int
    /// Height and width of the resulting photo.
    let size: IONCAMRSize?
    /// Indicates if it should fix the orientation when a photo is taken on a configuration different from the standard one (Back Camera and Up).
    let correctOrientation: Bool
    /// Indicates  the format to "store" the image.
    let encodingType: IONCAMREncodingType

    private enum CodingKeys: String, CodingKey {
        case quality, targetWidth, targetHeight, correctOrientation, encodingType, saveToGallery, cameraDirection, editable, includeMetadata, presentationStyle
    }

    public required convenience init(from decoder: Decoder) throws {
        func throwError(field: String) -> IONCAMRTakePhotoOptionsError {
            IONCAMRTakePhotoOptionsError.invalid(field: field)
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let quality = try container.decodeIfPresent(Int.self, forKey: .quality) ?? 90
        if quality < 0 || quality > 100 { throw throwError(field: "quality") }
        var size: IONCAMRSize?
        let width = try container.decodeIfPresent(Int.self, forKey: .targetWidth)
        let height = try container.decodeIfPresent(Int.self, forKey: .targetHeight)
        if let width, let height {
            size = try IONCAMRSize(width: width, height: height)
        }
        let correctOrientation = try container.decodeIfPresent(Bool.self, forKey: .correctOrientation) ?? false
        let encodingType = try container.decodeIfPresent(IONCAMREncodingType.self, forKey: .encodingType) ?? .jpeg
        let saveToGallery = try container.decodeIfPresent(Bool.self, forKey: .saveToGallery) ?? false
        let cameraDirection = try container.decodeIfPresent(IONCAMRDirection.self, forKey: .cameraDirection) ?? .back

        var allowEdit = false
        if let editable = try container.decodeIfPresent(String.self, forKey: .editable) {
            let editableLower = editable.lowercased()
            allowEdit = (editableLower == "in-app" || editableLower == "external")
        }

        let includeMetadata = try container.decodeIfPresent(Bool.self, forKey: .includeMetadata) ?? false
        let presentationStyle = try container.decodeIfPresent(IONCAMRPresentationStyle.self, forKey: .presentationStyle) ?? .fullscreen

        try self.init(
            quality: quality,
            size: size,
            correctOrientation: correctOrientation,
            encodingType: encodingType,
            saveToGallery: saveToGallery,
            cameraDirection: cameraDirection,
            allowEdit: allowEdit,
            returnMetadata: includeMetadata,
            presentationStyle: presentationStyle
        )
    }

    public init(
        quality: Int,
        size: IONCAMRSize? = nil,
        correctOrientation: Bool,
        encodingType: IONCAMREncodingType,
        saveToGallery: Bool,
        cameraDirection: IONCAMRDirection,
        allowEdit: Bool,
        returnMetadata: Bool,
        presentationStyle: IONCAMRPresentationStyle = .fullscreen
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
            mediaType: .picture,
            saveToGallery: saveToGallery,
            returnMetadata: returnMetadata,
            direction: cameraDirection,
            allowEdit: allowEdit,
            presentationStyle: presentationStyle
        )
    }
}

extension IONCAMRTakePhotoOptions {
    enum ThumbnailDefaultConfigurations {
        static let quality = 1
        static let resolution = 1080
    }

    static var defaultSquare: IONCAMRSize? {
        try? .initSquare(with: ThumbnailDefaultConfigurations.resolution)
    }
}
