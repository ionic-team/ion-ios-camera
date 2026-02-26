struct IONCAMRMediaResult {
    let type: IONCAMRMediaType
    let uri: String
    let thumbnail: String
    let metadata: IONCAMRMetadata?
    
    init(type: IONCAMRMediaType, uri: String, thumbnail: String, metadata: IONCAMRMetadata? = nil) {
        self.type = type
        self.uri = uri
        self.thumbnail = thumbnail
        self.metadata = metadata
    }
}

extension IONCAMRMediaResult {
    init(pictureWith uri: String, _ thumbnail: String, and metadata: IONCAMRMetadata? = nil) {
        self.init(type: .picture, uri: uri, thumbnail: thumbnail, metadata: metadata)
    }
    
    init(pictureWith data: String) {
        self.init(type: .picture, uri: "", thumbnail: data)
    }
    
    init(videoWith uri: String, _ thumbnail: String, and metadata: IONCAMRMetadata? = nil) {
        self.init(type: .video, uri: uri, thumbnail: thumbnail, metadata: metadata)
    }
}

extension IONCAMRMediaResult: Encodable {
    enum CodingKeys: String, CodingKey {
        case type, uri, thumbnail, metadata
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type.enumerator.rawValue, forKey: .type)
        try container.encode(self.uri, forKey: .uri)
        try container.encode(self.thumbnail, forKey: .thumbnail)
        try container.encodeIfPresent(self.metadata, forKey: .metadata)
    }
}
