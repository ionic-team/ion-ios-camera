public class IONCAMRVideoOptions: IONCAMRMediaOptions {
    public init(saveToPhotoAlbum: Bool, returnMetadata: Bool) {
        super.init(
            mediaType: .video, saveToPhotoAlbum: saveToPhotoAlbum, returnMetadata: returnMetadata, direction: .back, allowEdit: false
        )
    }
}

extension IONCAMRVideoOptions {
    struct ThumbnailDefaultConfigurations {
        static let quality = 1.0
        static let resolution = 480
    }
}
