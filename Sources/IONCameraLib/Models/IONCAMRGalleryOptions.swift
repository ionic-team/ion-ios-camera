public class IONCAMRGalleryOptions: IONCAMREditMediaTypeOptionsDelegate {
    var mediaType: IONCAMRMediaType
    /// Indicates if an edit step should be added to Choose from Gallery.
    var allowEdit: Bool
    /// Indicates if it's multiple result
    let allowMultipleSelection: Bool
    /// Indicates if we're in Choose Pic Gallery (true) or Choose from Gallery (false)
    let thumbnailAsData: Bool
    /// Indicates if the media's metadata should be returned
    var returnMetadata: Bool

    init(mediaType: IONCAMRMediaType, allowEdit: Bool, allowMultipleSelection: Bool, andThumbnailAsData: Bool, returnMetadata: Bool) {
        self.mediaType = mediaType
        self.allowEdit = allowEdit
        self.allowMultipleSelection = allowMultipleSelection
        self.thumbnailAsData = andThumbnailAsData
        self.returnMetadata = returnMetadata
    }
}
