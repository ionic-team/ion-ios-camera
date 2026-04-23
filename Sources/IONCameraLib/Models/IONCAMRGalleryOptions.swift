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
    /// Indicates the maximum number of media items that can be selected when allowMultipleSelection is true. Ignored if allowMultipleSelection is
    /// false. 0 means no limit.
    public let limit: Int
    /// Presentation style to use when showing the gallery interface. Default is `.fullscreen`.
    public let presentationStyle: IONCAMRPresentationStyle

    init(
        mediaType: IONCAMRMediaType,
        allowEdit: Bool,
        allowMultipleSelection: Bool,
        andThumbnailAsData: Bool,
        returnMetadata: Bool,
        limit: Int = 0,
        presentationStyle: IONCAMRPresentationStyle = .fullscreen
    ) {
        self.mediaType = mediaType
        self.allowEdit = allowEdit
        self.allowMultipleSelection = allowMultipleSelection
        self.thumbnailAsData = andThumbnailAsData
        self.returnMetadata = returnMetadata
        self.limit = limit
        self.presentationStyle = presentationStyle
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mediaTypeRaw = try container.decodeIfPresent(Int.self, forKey: .mediaType) ?? 0
        let mediaType = try IONCAMRMediaType(from: mediaTypeRaw)

        var allowEdit = false
        if let editable = try container.decodeIfPresent(String.self, forKey: .editable) {
            let editableLower = editable.lowercased()
            allowEdit = (editableLower == "in-app" || editableLower == "external")
        }

        let allowMultipleSelection = try container.decodeIfPresent(Bool.self, forKey: .allowMultipleSelection) ?? false
        let thumbnailAsData = try container.decodeIfPresent(Bool.self, forKey: .thumbnailAsData) ?? true
        let returnMetadata = try container.decodeIfPresent(Bool.self, forKey: .includeMetadata) ?? false
        let limit = try container.decodeIfPresent(Int.self, forKey: .limit) ?? 0
        let presentationStyle = try container.decodeIfPresent(IONCAMRPresentationStyle.self, forKey: .presentationStyle) ?? .fullscreen
        self.init(
            mediaType: mediaType,
            allowEdit: allowEdit,
            allowMultipleSelection: allowMultipleSelection,
            andThumbnailAsData: thumbnailAsData,
            returnMetadata: returnMetadata,
            limit: limit,
            presentationStyle: presentationStyle
        )
    }

    private enum CodingKeys: String, CodingKey {
        case mediaType, editable, allowMultipleSelection, thumbnailAsData, includeMetadata, limit, presentationStyle
    }
}
