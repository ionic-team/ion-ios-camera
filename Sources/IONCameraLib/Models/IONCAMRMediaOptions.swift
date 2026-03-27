public class IONCAMRMediaOptions: IONCAMREditMediaTypeOptionsDelegate, IONCAMRSaveToGalleryOptionsDelegate {
    var mediaType: IONCAMRMediaType
    /// Indicates if the resulting image should be stored on the device's photo gallery.
    var saveToGallery: Bool
    /// Indicates if we should returns the media's metadata
    var returnMetadata: Bool
    /// Sets default camera for capturing a picture.
    let direction: IONCAMRDirection
    /// Indicates if an edit step should be added to the Take Picture or Choose from Gallery.
    var allowEdit: Bool
    /// Presentation style to use when showing the camera interface. Default is `.fullscreen`.
    var presentationStyle: IONCAMRPresentationStyle = .fullscreen

    init(
        mediaType: IONCAMRMediaType,
        saveToGallery: Bool,
        returnMetadata: Bool,
        direction: IONCAMRDirection,
        allowEdit: Bool,
        presentationStyle: IONCAMRPresentationStyle = .fullscreen
    ) {
        self.mediaType = mediaType
        self.saveToGallery = saveToGallery
        self.returnMetadata = returnMetadata
        self.direction = direction
        self.allowEdit = allowEdit
        self.presentationStyle = presentationStyle
    }
}

/// Camera to be used.
public enum IONCAMRDirection: String, Decodable {
    case back = "REAR"
    case front = "FRONT"
}
