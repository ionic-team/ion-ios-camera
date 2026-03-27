import UIKit

/// Provides a set of operations on the `UIImage` object based on the user defined picture options.
extension UIImage {
    /// Converts the `UIImage` object into a base 64 string equivalent, based the user defined picture options.
    /// - Parameter options: User defined options for the resulting base64 object, when passed.
    /// - Returns: The resulting base64 equivalent.
    func toData(with options: IONCAMRTakePhotoOptions? = nil) -> Data? {
        let data: Data?

        if let options, options.encodingType == .jpeg {
            let quality = !options.allowEdit && !options.correctOrientation && options.quality == 100 ? 1.0 : CGFloat(options.quality) / 100
            data = jpegData(compressionQuality: quality)
        } else {
            data = pngData()
        }

        return data
    }

    /// Provides a couple of transformations (rotation and resize) to the `UIImage` object, based on the user defined options.
    /// - Parameter options: User defined options containing the transformations (if any) to apply.
    /// - Returns: The resulting image. It returns `nil` if some issue occured.
    func fix(with options: IONCAMRTakePhotoOptions) -> UIImage? {
        var image = self

        if options.correctOrientation, let orientedImage = image.fixOrientation() {
            image = orientedImage
        }
        if let targetSize = options.size, let resizedImage = image.resizeTo(CGSize(size: targetSize)) {
            image = resizedImage
        }

        return image
    }

    private func applyConfigurations(_ resolution: CGFloat, and quality: CGFloat) -> String? {
        var image = self
        let minimumSide = resolution

        var newSize: CGSize?
        if image.size.height > image.size.width {
            if image.size.width > minimumSide {
                let ratio = image.size.height / image.size.width
                newSize = .init(width: minimumSide, height: minimumSide * ratio)
            }
        } else if image.size.height > minimumSide {
            let ratio = image.size.width / image.size.height
            newSize = .init(width: minimumSide * ratio, height: minimumSide)
        }

        if let newSize, let resizedImage = image.resizeTo(newSize) {
            image = resizedImage
        }
        return image.jpegData(compressionQuality: quality)?.base64EncodedString()
    }
}

// MARK: - IONCAMRRecordVideoOptions extension

extension UIImage {
    func pictureThumbnailData(
        with originalResolution: IONCAMRSize? = nil,
        and originalQuality: Int = IONCAMRTakePhotoOptions.ThumbnailDefaultConfigurations.quality
    )
        -> String? {
        guard let originalResolution = originalResolution ??
            (try? .initSquare(with: IONCAMRTakePhotoOptions.ThumbnailDefaultConfigurations.resolution))
        else { return nil }
        let resolution = CGFloat(
            min(originalResolution.height, originalResolution.width, IONCAMRTakePhotoOptions.ThumbnailDefaultConfigurations.resolution)
        )
        let quality = CGFloat(originalQuality / 100)

        return applyConfigurations(resolution, and: quality)
    }

    var defaultVideoThumbnailData: String? {
        let resolution = CGFloat(IONCAMRRecordVideoOptions.ThumbnailDefaultConfigurations.resolution)
        let quality = CGFloat(IONCAMRRecordVideoOptions.ThumbnailDefaultConfigurations.quality)

        return applyConfigurations(resolution, and: quality)
    }
}
