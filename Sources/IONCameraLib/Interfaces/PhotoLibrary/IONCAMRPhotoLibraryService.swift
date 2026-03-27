import Foundation
import Photos
import UIKit

typealias PHAssetLocalIdentifier = String

class IONCAMRPhotoLibraryService: NSObject, ObservableObject {
    /// A collection that allows subscript support to PHFetchResult<PHAsset>
    ///
    /// The results property will store all of the photo asset ids that we requested, and will be used by our views to request for a copy of the photo
    /// itself.
    ///
    /// We don't want to store a copy of the actual photo as it would cost too much memory, especially if we show the photos in a grid.
    @Published var results = IONCAMRPHFetchResultCollection(fetchResult: .init())

    private weak var delegate: IONCAMRPhotoLibraryViewDelegate?
    private let metadataGetter: IONCAMRMetadataGetterDelegate
    private let mediaTypeArray: [PHAssetMediaType]
    private let thumbnailAsData: Bool
    private let returnMetadata: Bool

    /// The manager that will fetch and cache photos for us
    var imageCachingManager = PHCachingImageManager()

    var hasAccessToFullAlbum: Bool {
        PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
    }

    init(
        delegate: IONCAMRPhotoLibraryViewDelegate,
        metadataGetter: IONCAMRMetadataGetterDelegate,
        mediaTypeArray: [PHAssetMediaType],
        thumbnailAsData: Bool,
        returnMetadata: Bool
    ) {
        self.delegate = delegate
        self.metadataGetter = metadataGetter
        self.mediaTypeArray = mediaTypeArray
        self.thumbnailAsData = thumbnailAsData
        self.returnMetadata = returnMetadata
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
}

// MARK: - Multimedia Fetchers

extension IONCAMRPhotoLibraryService {
    /// Function that will tell the image caching manager to fetch all photos from the user's photo library. We don't want to include hidden assets
    /// for obvious privacy reasons.
    ///
    /// We also need to sort the photos being fetched by the most recent first, mimicking the behaviour of the Recents album from the Photos app.
    func fetchAllPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = mediaTypePredicate
        DispatchQueue.main.async {
            self.results.fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        }
    }

    /// Requests an image copy given a photo asset id.
    ///
    /// The image caching manager performs the fetching, and will cache the photo fetched for later use. Please know that the cache is temporary – all
    /// photos cached will be lost when the app is terminated.
    func fetchImage(
        byLocalIdentifier localId: PHAssetLocalIdentifier,
        targetSize: CGSize = PHImageManagerMaximumSize,
        contentMode: PHImageContentMode = .default
    ) async throws
        -> UIImage? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
        guard let asset = assets.firstObject else { throw IONCAMRError.imageNotFound }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.resizeMode = .exact
        options.version = .current

        return try await withCheckedThrowingContinuation { [weak self] continuation in
            // Use the imageCachingManager to fetch the image
            self?.imageCachingManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options,
                resultHandler: { image, info in
                    // image is of type UIImage
                    if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: image)
                }
            )
        }
    }

    private func fetchVideo(byLocalIdentifier localId: PHAssetLocalIdentifier) async throws -> URL? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
        guard let asset = assets.firstObject else { throw IONCAMRError.videoNotFound }
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .original
        options.isNetworkAccessAllowed = true
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            // Use the imageCachingManager to fetch the image
            self?.imageCachingManager.requestAVAsset(forVideo: asset, options: options, resultHandler: { asset, _, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                    return
                }
                if let urlAsset = asset as? AVURLAsset {
                    do {
                        let url = try urlAsset.url.createVideoPermanentPath(false)
                        continuation.resume(returning: url)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            })
        }
    }

    private func fetchImageURL(for asset: PHAsset) async throws -> URL? {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        return try await withCheckedThrowingContinuation { continuation in
            asset.requestContentEditingInput(with: options) { editingInput, info in
                if let error = info[PHContentEditingInputErrorKey] as? Error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: editingInput?.fullSizeImageURL)
            }
        }
    }
}

// MARK: - Returning delegates

extension IONCAMRPhotoLibraryService {
    private func fetchSingleResult(_ asset: PHAsset?) async -> IONCAMRResultItem? {
        guard let asset, let image = try? await fetchImage(
            byLocalIdentifier: asset.localIdentifier,
            targetSize: CGSize(resolution: IONCAMRTakePhotoOptions.ThumbnailDefaultConfigurations.resolution)
        )
        else { return nil }
        return .picture(image)
    }

    private func fetchImage(from asset: PHAsset) async throws -> IONCAMRMediaResult {
        guard let image = try await fetchImage(byLocalIdentifier: asset.localIdentifier),
              let imageData = image.pictureThumbnailData(),
              let imageURL = try await fetchImageURL(for: asset)
        else { throw IONCAMRError.imageNotFound }

        var metadata: IONCAMRMetadata?
        if returnMetadata {
            metadata = try? metadataGetter.getImageMetadata(from: image, and: imageURL)
        }

        return IONCAMRMediaResult(pictureWith: imageURL.absoluteString, imageData, and: metadata)
    }

    private func fetchVideo(from asset: PHAsset) async throws -> IONCAMRMediaResult {
        guard let image = try await fetchImage(
            byLocalIdentifier: asset.localIdentifier,
            targetSize: CGSize(resolution: IONCAMRRecordVideoOptions.ThumbnailDefaultConfigurations.resolution)
        ),
            let videoData = image.defaultVideoThumbnailData,
            let videoURL = try await fetchVideo(byLocalIdentifier: asset.localIdentifier)
        else { throw IONCAMRError.videoNotFound }

        var metadata: IONCAMRMetadata?
        if returnMetadata {
            metadata = try? await metadataGetter.getVideoMetadata(from: videoURL)
        }

        return IONCAMRMediaResult(videoWith: videoURL.absoluteString, videoData, and: metadata)
    }

    private func fetchMultipleResult(_ assetArray: [PHAsset]) async -> [IONCAMRMediaResult]? {
        do {
            var result = [IONCAMRMediaResult]()
            for asset in assetArray {
                switch asset.mediaType {
                case .image:
                    let imageAsset = try await fetchImage(from: asset)
                    result += [imageAsset]
                case .video:
                    let videoAsset = try await fetchVideo(from: asset)
                    result += [videoAsset]
                default: return nil // not supposed to get here
                }
            }
            return result
        } catch {
            return nil
        }
    }

    func didFinishPicking(_ assetArray: [PHAsset]) {
        Task {
            if self.thumbnailAsData {
                let results = await self.fetchMultipleResult(assetArray)
                Task { @MainActor in
                    self.delegate?.didPickMultimedia(results)
                }
            } else {
                let item = await self.fetchSingleResult(assetArray.first)
                Task { @MainActor in
                    await self.delegate?.didPickPicture(item)
                }
            }
        }
    }

    func didCancelPicking() {
        delegate?.didCancel()
    }
}

extension IONCAMRPhotoLibraryService: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let changes = changeInstance.changeDetails(for: results.fetchResult) {
            DispatchQueue.main.async {
                self.results.fetchResult = changes.fetchResultAfterChanges
            }
        }
    }
}

extension IONCAMRPhotoLibraryService {
    private var mediaTypePredicate: NSPredicate {
        let formatArray = [String](repeating: "mediaType == %d", count: mediaTypeArray.count)
        let typeArray = mediaTypeArray.map(\.rawValue)
        return NSPredicate(format: formatArray.joined(separator: " || "), argumentArray: typeArray)
    }
}
