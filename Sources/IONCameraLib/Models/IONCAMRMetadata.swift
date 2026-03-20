import Foundation

public struct IONCAMRMetadata {
    public var size: UInt64
    public var duration: Int?
    public var format: String
    public var resolution: String
    public var creationDate: Date
    
    init(size: UInt64, duration: Int? = nil, format: String, resolution: String, creationDate: Date) {
        self.size = size
        self.duration = duration
        self.format = format
        self.resolution = resolution
        self.creationDate = creationDate
    }
}

extension IONCAMRMetadata: Encodable {
    enum CodingKeys: String, CodingKey {
        case size, duration, format, resolution, creationDate
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.size, forKey: .size)
        try container.encodeIfPresent(self.duration, forKey: .duration)
        try container.encode(self.format, forKey: .format)
        try container.encode(self.resolution, forKey: .resolution)
        try container.encode(self.creationDate, forKey: .creationDate)
    }
}
