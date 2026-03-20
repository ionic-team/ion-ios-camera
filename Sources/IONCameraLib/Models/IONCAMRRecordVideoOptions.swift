public class IONCAMRRecordVideoOptions: IONCAMRMediaOptions, Decodable {
    public let isPersistent: Bool

    public init(saveToGallery: Bool, returnMetadata: Bool, isPersistent: Bool) {
        self.isPersistent = isPersistent
        super.init(
            mediaType: .video, saveToGallery: saveToGallery, returnMetadata: returnMetadata, direction: .back, allowEdit: false
        )
    }

    private enum CodingKeys: String, CodingKey {
        case isPersistent, saveToGallery, includeMetadata
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isPersistent = try container.decode(Bool.self, forKey: .isPersistent)
        let saveToGallery = try container.decode(Bool.self, forKey: .saveToGallery)
        let returnMetadata = try container.decode(Bool.self, forKey: .includeMetadata)
        super.init(
            mediaType: .video,
            saveToGallery: saveToGallery,
            returnMetadata: returnMetadata,
            direction: .back,
            allowEdit: false
        )
    }
}

extension IONCAMRRecordVideoOptions {
    struct ThumbnailDefaultConfigurations {
        static let quality = 1.0
        static let resolution = 480
    }
}
