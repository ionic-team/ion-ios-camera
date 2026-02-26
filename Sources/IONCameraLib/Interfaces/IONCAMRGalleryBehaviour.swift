import Photos
import SwiftUI
import UIKit

final class IONCAMRGalleryBehaviour: NSObject, IONCAMRGalleryDelegate {
    weak var delegate: IONCAMRGalleryResultsDelegate?
    
    var thumbnailAsData: Bool = false
    var returnMetadata: Bool = false
    
    var metadataGetter: IONCAMRMetadataGetterDelegate
    
    init(metadataGetter: IONCAMRMetadataGetterDelegate) {
        self.metadataGetter = metadataGetter
    }
    
    func saveToGallery(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            if !success, let error = error {
                print("Couldn't save image to photo library: \(error)")
            }
        }
    }
    
    func saveToGallery(_ fileURL: URL) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        } completionHandler: { success, error in
            if !success, let error = error {
                print("Couldn't save video to photo library: \(error)")
            }
        }
    }
    
    func chooseFromGallery(with options: IONCAMRGalleryOptions, _ handler: @escaping (UIViewController) -> Void) {
        self.thumbnailAsData = options.thumbnailAsData
        self.returnMetadata = options.returnMetadata
        DispatchQueue.main.async {
            let viewController = self.displayPhotoLibraryView(
                with: options.mediaType.phAssetArray, options.allowMultipleSelection, and: options.thumbnailAsData
            )

            handler(viewController)
        }
    }
}

extension IONCAMRGalleryBehaviour {
    func displayPhotoLibraryView(with mediaTypeArray: [PHAssetMediaType], _ allowMultipleSelection: Bool, and thumbnailAsData: Bool) -> UIViewController {
        let photoLibraryService = IONCAMRPhotoLibraryService(
            delegate: self,
            metadataGetter: self.metadataGetter,
            mediaTypeArray: mediaTypeArray,
            thumbnailAsData: thumbnailAsData,
            returnMetadata: self.returnMetadata
        )
        let photoLibraryView = IONCAMRPhotoLibraryView(allowMultipleSelection: allowMultipleSelection).environmentObject(photoLibraryService)
        let viewController = UIHostingController(rootView: photoLibraryView)
        viewController.navigationItem.title = "Photo Library"
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .fullScreen
        return navController
    }
}

extension IONCAMRGalleryBehaviour: IONCAMRPhotoLibraryViewDelegate {
    func didPickMultimedia(_ mediaResultArray: [IONCAMRMediaResult]?) {
        if let mediaResultArray = mediaResultArray {
            self.delegate?.didReturn(.success(mediaResultArray))
        } else {
            self.delegate?.didReturn(.failure(.chooseMultimediaIssue))
        }
    }
    
    func didPickPicture(_ item: IONCAMRResultItem?) {
        if let item = item {
            self.delegate?.didReturn(self, with: .success(item))
        } else {
            self.delegate?.didReturn(self, with: .failure(.choosePictureIssue))
        }
    }
    
    func didCancel() {
        self.delegate?.didCancel(self)
    }
}
