import AVFoundation
import UIKit

private enum IONCAMRMetadataError: Error {
    case noVideoTrack
    case urlConversionError
}

final class IONCAMRMediaResultGenerator: IONCAMRMetadataGetterDelegate {
    func getVideoMetadata(from url: URL) async throws -> IONCAMRMetadata {
        let asset = AVAsset(url: url)

        let durationProperty: CMTime
        let trackArray: [AVAssetTrack]
        if #available(iOS 15, *) {
            durationProperty = try await asset.load(.duration)
            trackArray = try await asset.loadTracks(withMediaType: .video)
        } else {
            durationProperty = asset.duration
            trackArray = asset.tracks(withMediaType: .video)
        }

        guard let track = trackArray.first else { throw IONCAMRMetadataError.noVideoTrack }
        guard let urlMetadata = url.metadata else { throw IONCAMRMetadataError.urlConversionError }

        let naturalSize: CGSize = if #available(iOS 15, *) {
            try await track.load(.naturalSize)
        } else {
            track.naturalSize
        }
        let duration = Int(CMTimeGetSeconds(durationProperty).rounded())
        let format = url.pathExtension.lowercased()
        let creationDate = urlMetadata.date
        let size = urlMetadata.fileSize
        let resolution = naturalSize.resolution

        return IONCAMRMetadata(size: size, duration: duration, format: format, resolution: resolution, creationDate: creationDate)
    }

    func getImageMetadata(from image: UIImage, and url: URL) throws -> IONCAMRMetadata {
        guard let urlMetadata = url.metadata else { throw IONCAMRMetadataError.urlConversionError }

        let naturalSize = image.size
        let format = url.pathExtension.lowercased()
        let creationDate = urlMetadata.date
        let size = urlMetadata.fileSize
        let resolution = naturalSize.resolution

        return IONCAMRMetadata(size: size, format: format, resolution: resolution, creationDate: creationDate)
    }
}

extension IONCAMRMediaResultGenerator: IONCAMRThumbnailGeneratorDelegate {
    func getImage(from videoURL: URL, _ completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async { // run this on background
            let asset = AVAsset(url: videoURL)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true // correct thumbnail orientation
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) // time of the video to be used as a thumbnail
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    func getBase64String(from image: UIImage, with originalSize: IONCAMRSize?, and originalQuality: Int?) -> String? {
        let size = originalSize ?? IONCAMRTakePhotoOptions.defaultSquare
        let quality = originalQuality ?? IONCAMRTakePhotoOptions.ThumbnailDefaultConfigurations.quality

        return image.pictureThumbnailData(with: size, and: quality)
    }
}

extension IONCAMRMediaResultGenerator: IONCAMRImageFetcherDelegate {
    func retrieveImage(from urlString: String) -> UIImage? {
        guard let imageURL = URL(string: urlString), let imageData = try? Data(contentsOf: imageURL) else { return nil }
        return UIImage(data: imageData)
    }
}

extension IONCAMRMediaResultGenerator: IONCAMRURLGeneratorDelegate {
    func url(
        for imageData: Data,
        withEncodingType encodingType: IONCAMREncodingType?
    )
        -> URL? {
        try? imageData.createImageTemporaryPath(with: encodingType?.description)
    }
}
