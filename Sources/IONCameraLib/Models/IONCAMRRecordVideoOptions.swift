public class IONCAMRRecordVideoOptions: IONCAMRMediaOptions {
    public let isPersistent: Bool

    public init(saveToGallery: Bool, returnMetadata: Bool, isPersistent: Bool) {
        self.isPersistent = isPersistent
        super.init(
            mediaType: .video, saveToGallery: saveToGallery, returnMetadata: returnMetadata, direction: .back, allowEdit: false
        )
    }
}

extension IONCAMRRecordVideoOptions {
    struct ThumbnailDefaultConfigurations {
        static let quality = 1.0
        static let resolution = 480
    }
}
