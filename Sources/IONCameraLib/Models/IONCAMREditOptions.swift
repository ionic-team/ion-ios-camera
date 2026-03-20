public class IONCAMRPhotoEditOptions: IONCAMRSaveToGalleryOptionsDelegate, Decodable {
    var uri: String
    /// Indicates if the resulting image should be stored on the device's photo gallery.
    var saveToGallery: Bool
    /// Indicates if we should returns the media's metadata
    var returnMetadata: Bool
    /// Sets default camera for capturing a picture.
    
    public init(uri: String, saveToGallery: Bool, returnMetadata: Bool) {
        self.uri = uri
        self.saveToGallery = saveToGallery
        self.returnMetadata = returnMetadata
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let uri = try container.decode(String.self, forKey: .uri)
        let saveToGallery = try container.decode(Bool.self, forKey: .saveToGallery)
        let returnMetadata = try container.decode(Bool.self, forKey: .returnMetadata)
        self.init(uri: uri, saveToGallery: saveToGallery, returnMetadata: returnMetadata)
    }
    
    private enum CodingKeys: String, CodingKey {
        case uri, saveToGallery, returnMetadata
    }
}
