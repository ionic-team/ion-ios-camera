import UIKit

public protocol IONCAMRGalleryActionDelegate: AnyObject {
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
}
