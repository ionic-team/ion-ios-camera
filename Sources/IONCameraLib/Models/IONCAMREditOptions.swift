public class IONCAMREditOptions: IONCAMRSaveToGalleryOptionsDelegate {
    /// Indicates if the resulting image should be stored on the device's photo gallery.
    var saveToGallery: Bool
    /// Indicates if we should returns the media's metadata
    var returnMetadata: Bool
    /// Sets default camera for capturing a picture.
    
    public init(saveToGallery: Bool, returnMetadata: Bool) {
        self.saveToGallery = saveToGallery
        self.returnMetadata = returnMetadata
    }
}
