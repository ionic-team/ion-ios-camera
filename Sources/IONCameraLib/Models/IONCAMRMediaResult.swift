public struct IONCAMRMediaResult {
    public let type: IONCAMRMediaType
    public let uri: String
    public let thumbnail: String
    public let metadata: IONCAMRMetadata?
    public let saved: Bool?

    init(type: IONCAMRMediaType, uri: String, thumbnail: String, metadata: IONCAMRMetadata? = nil, saved: Bool? = nil) {
        self.type = type
        self.uri = uri
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.saved = saved
    }
}

extension IONCAMRMediaResult {
    init(pictureWith uri: String, _ thumbnail: String, and metadata: IONCAMRMetadata? = nil, saved: Bool? = nil) {
        self.init(type: .picture, uri: uri, thumbnail: thumbnail, metadata: metadata, saved: saved)
    }

    init(pictureWith data: String, saved: Bool? = nil) {
        self.init(type: .picture, uri: "", thumbnail: data, saved: saved)
    }

    init(videoWith uri: String, _ thumbnail: String, and metadata: IONCAMRMetadata? = nil, saved: Bool? = nil) {
        self.init(type: .video, uri: uri, thumbnail: thumbnail, metadata: metadata, saved: saved)
    }
}

extension IONCAMRMediaResult: Encodable {
    enum CodingKeys: String, CodingKey {
        case type, uri, thumbnail, metadata, saved
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.enumerator.rawValue, forKey: .type)
        try container.encode(uri, forKey: .uri)
        try container.encode(thumbnail, forKey: .thumbnail)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(saved, forKey: .saved)
    }
}
