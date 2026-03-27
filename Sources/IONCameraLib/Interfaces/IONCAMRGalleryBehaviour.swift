import Photos
import SwiftUI
import UIKit

final class IONCAMRGalleryBehaviour: NSObject, IONCAMRGalleryDelegate {
    weak var delegate: IONCAMRGalleryResultsDelegate?

    var thumbnailAsData = false
    var returnMetadata = false

    var metadataGetter: IONCAMRMetadataGetterDelegate

    init(metadataGetter: IONCAMRMetadataGetterDelegate) {
        self.metadataGetter = metadataGetter
    }

    func saveToGallery(_ image: UIImage) async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, _ in
                continuation.resume(returning: success)
            }
        }
    }

    func saveToGallery(_ fileURL: URL) async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            } completionHandler: { success, _ in
                continuation.resume(returning: success)
            }
        }
    }

    func chooseFromGallery(with options: IONCAMRGalleryOptions, _ handler: @escaping (UIViewController) -> Void) {
        thumbnailAsData = options.thumbnailAsData
        returnMetadata = options.returnMetadata
        DispatchQueue.main.async {
            let viewController = self.displayPhotoLibraryView(
                mediaTypes: options.mediaType.phAssetArray,
                allowMultipleSelection: options.allowMultipleSelection,
                limit: options.limit,
                thumbnailAsData: options.thumbnailAsData
            )

            handler(viewController)
        }
    }
}

extension IONCAMRGalleryBehaviour {
    func displayPhotoLibraryView(
        mediaTypes: [PHAssetMediaType],
        allowMultipleSelection: Bool,
        limit: Int = 0,
        thumbnailAsData: Bool
    )
        -> UIViewController {
        let photoLibraryService = IONCAMRPhotoLibraryService(
            delegate: self,
            metadataGetter: metadataGetter,
            mediaTypeArray: mediaTypes,
            thumbnailAsData: thumbnailAsData,
            returnMetadata: returnMetadata
        )
        let photoLibraryView = IONCAMRPhotoLibraryView(allowMultipleSelection: allowMultipleSelection, limit: limit)
            .environmentObject(photoLibraryService)
        let viewController = UIHostingController(rootView: photoLibraryView)
        viewController.navigationItem.title = "Photo Library"

        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .fullScreen
        return navController
    }
}

extension IONCAMRGalleryBehaviour: IONCAMRPhotoLibraryViewDelegate {
    func didPickMultimedia(_ mediaResultArray: [IONCAMRMediaResult]?) {
        if let mediaResultArray {
            delegate?.didReturn(.success(mediaResultArray))
        } else {
            delegate?.didReturn(.failure(.chooseMultimediaIssue))
        }
    }

    func didPickPicture(_ item: IONCAMRResultItem?) {
        if let item {
            delegate?.didReturn(self, with: .success(item))
        } else {
            delegate?.didReturn(self, with: .failure(.choosePictureIssue))
        }
    }

    func didCancel() {
        delegate?.didCancel(self)
    }
}
