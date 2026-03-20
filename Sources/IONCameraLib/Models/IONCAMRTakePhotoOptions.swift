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
        case quality, width, height, correctOrientation, encodingType, saveToGallery, cameraDirection, allowEdit, includeMetadata
    }

    required public convenience init(from decoder: Decoder) throws {
        func throwError(field: String) -> IONCAMRTakePhotoOptionsError {
            IONCAMRTakePhotoOptionsError.invalid(field: field)
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let quality = try container.decode(Int.self, forKey: .quality)
        if quality < 0 || quality > 100 { throw throwError(field: "quality") }
        
        var size: IONCAMRSize? = nil
        let width = try container.decodeIfPresent(Int.self, forKey: .width)
        let height = try container.decodeIfPresent(Int.self, forKey: .height)
        if let width = width, let height = height {
            size = try IONCAMRSize(width: width, height: height)
        }

        let correctOrientation = try container.decode(Bool.self, forKey: .correctOrientation)
        guard 
            let encodingType = IONCAMREncodingType(rawValue: try container.decode(Int.self, forKey: .encodingType))
        else { 
            throw throwError(field: "encodingType")
        }

        let saveToGallery = try container.decode(Bool.self, forKey: .saveToGallery)
        guard 
            let cameraDirection = IONCAMRDirection(rawValue: try container.decode(String.self, forKey: .cameraDirection))
        else {
            throw throwError(field: "cameraDirection")
        }

        let allowEdit = try container.decode(Bool.self, forKey: .allowEdit)
        let includeMetadata = try container.decode(Bool.self, forKey: .includeMetadata)
        try self.init(
            quality: quality,
            size: size,
            correctOrientation: correctOrientation,
            encodingType: encodingType,
            saveToGallery: saveToGallery,
            cameraDirection: cameraDirection,
            allowEdit: allowEdit,
            returnMetadata: includeMetadata
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
            mediaType: .picture, saveToGallery: saveToGallery, returnMetadata: returnMetadata, direction: cameraDirection, allowEdit: allowEdit
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
