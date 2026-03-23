public class IONCAMRGalleryOptions: IONCAMREditMediaTypeOptionsDelegate, Decodable {
    public var mediaType: IONCAMRMediaType
    /// Indicates if an edit step should be added to Choose from Gallery.
    public var allowEdit: Bool
    /// Indicates if it's multiple result
    public let allowMultipleSelection: Bool
    /// Indicates if we're in Choose Pic Gallery (true) or Choose from Gallery (false)
    public let thumbnailAsData: Bool
    /// Indicates if the media's metadata should be returned
    public var returnMetadata: Bool
    
    init(mediaType: IONCAMRMediaType, allowEdit: Bool, allowMultipleSelection: Bool, andThumbnailAsData: Bool, returnMetadata: Bool) {
        self.mediaType = mediaType
        self.allowEdit = allowEdit
        self.allowMultipleSelection = allowMultipleSelection
        self.thumbnailAsData = andThumbnailAsData
        self.returnMetadata = returnMetadata
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mediaTypeRaw = try container.decodeIfPresent(Int.self, forKey: .mediaType) ?? 0
        let mediaType = try IONCAMRMediaType(from: mediaTypeRaw)
        let allowEdit = try container.decodeIfPresent(Bool.self, forKey: .allowEdit) ?? false
        let allowMultipleSelection = try container.decodeIfPresent(Bool.self, forKey: .allowMultipleSelection) ?? false
        let thumbnailAsData = try container.decodeIfPresent(Bool.self, forKey: .thumbnailAsData) ?? true
        let returnMetadata = try container.decodeIfPresent(Bool.self, forKey: .includeMetadata) ?? false
        self.init(mediaType: mediaType, allowEdit: allowEdit, allowMultipleSelection: allowMultipleSelection, andThumbnailAsData: thumbnailAsData, returnMetadata: returnMetadata)
    }

    private enum CodingKeys: String, CodingKey {
        case mediaType, allowEdit, allowMultipleSelection, thumbnailAsData, includeMetadata
    }
}
