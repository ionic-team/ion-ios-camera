import UIKit

public protocol IONCAMRGalleryActionDelegate: AnyObject {
    func chooseFromGallery(with options: IONCAMRGalleryOptions)
}

extension IONCAMRGalleryActionDelegate {
    public func choosePicture(_ allowEdit: Bool) {
        let options = IONCAMRGalleryOptions(
            mediaType: .picture,
            allowEdit: allowEdit,
            allowMultipleSelection: false,
            andThumbnailAsData: false,
            returnMetadata: false
        )
        chooseFromGallery(with: options)
    }
}
