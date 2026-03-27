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
        self.isPersistent = try container.decodeIfPresent(Bool.self, forKey: .isPersistent) ?? true
        let saveToGallery = try container.decodeIfPresent(Bool.self, forKey: .saveToGallery) ?? false
        let returnMetadata = try container.decodeIfPresent(Bool.self, forKey: .includeMetadata) ?? false
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
    enum ThumbnailDefaultConfigurations {
        static let quality = 1.0
        static let resolution = 480
    }
}
