import UIKit

/// Contains a set of transformations applicable to the `UIImage` object.
extension UIImage {
    /// Applies a set of transformations required to correct the image's orientation. It it's already set to `up`, the image is immediately returned.
    /// - Returns: The resulting image, after applying all transformations. `Nil` is returned if some issue occured.
    func fixOrientation() -> UIImage? {
        guard self.imageOrientation != .up else {
            return self.copy() as? UIImage  // This is default orientation, nothing to do here
        }
        
        guard let cgImage = self.cgImage else {
            return nil  // CGImage is not available
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(
            data: nil,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil // Not able to create CGContext
        }
        
        var transform: CGAffineTransform = .identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage, scale: 1, orientation: .up)
    }
    
    /// Resizes the image to the `targetSize` passed by argument.
    /// - Parameter targetSize: The height and width to resize the image to
    /// - Returns: The resulting resized image. `Nil` is returned if some issue occured.
    func resizeTo(_ targetSize: CGSize) -> UIImage? {
        let sourceImage = self
        let widthRatio  = targetSize.width  / sourceImage.size.width
        let heightRatio = targetSize.height / sourceImage.size.height
        
        guard widthRatio != 1.0, heightRatio != 1.0 else { return self }
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: sourceImage.size.width * heightRatio, height: sourceImage.size.height * heightRatio)
        } else {
            newSize = CGSize(width: sourceImage.size.width * widthRatio, height: sourceImage.size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using ImageContext
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        sourceImage.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
