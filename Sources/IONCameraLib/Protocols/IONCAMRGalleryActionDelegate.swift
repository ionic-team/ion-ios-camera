import UIKit

public protocol IONCAMRGalleryActionDelegate: AnyObject {
    func editPicture(_ image: UIImage)
    func editPicture(from urlString: String, with options: IONCAMREditOptions)
    func chooseFromGallery(with options: IONCAMRGalleryOptions)
}

public extension IONCAMRGalleryActionDelegate {
    func choosePicture(_ allowEdit: Bool) {
        let options = IONCAMRGalleryOptions(
            mediaType: .picture,
            allowEdit: allowEdit,
            allowMultipleSelection: false,
            andThumbnailAsData: false,
            returnMetadata: false
        )
        self.chooseFromGallery(with: options)
    }
    
    func chooseMultimedia(_ mediaType: IONCAMRMediaType, _ allowMultipleSelection: Bool, _ returnMetadata: Bool, and allowEdit: Bool) {
        let options = IONCAMRGalleryOptions(
            mediaType: mediaType,
            allowEdit: allowEdit,
            allowMultipleSelection: allowMultipleSelection,
            andThumbnailAsData: true,
            returnMetadata: returnMetadata
        )
        self.chooseFromGallery(with: options)
    }
}
