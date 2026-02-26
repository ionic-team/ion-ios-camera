public class IONCAMREditOptions: IONCAMRSaveToPhotoAlbumOptionsDelegate {
    /// Indicates if the resulting image should be stored on the device's photo gallery.
    var saveToPhotoAlbum: Bool
    /// Indicates if we should returns the media's metadata
    var returnMetadata: Bool
    /// Sets default camera for capturing a picture.
    
    public init(saveToPhotoAlbum: Bool, returnMetadata: Bool) {
        self.saveToPhotoAlbum = saveToPhotoAlbum
        self.returnMetadata = returnMetadata
    }
}
