import UIKit

/// Interface that handles storing an image into the device's photo gallery.
protocol IONCAMRGalleryDelegate: AnyObject {
    typealias IONCAMRGalleryResultsDelegate = IONCAMRCancelResultsDelegate & IONCAMRMultipleResultsDelegate & IONCAMRResultsDelegate
    var delegate: IONCAMRGalleryResultsDelegate? { get set }

    /// Save image to the device's photo library.
    /// - Parameter image: Image to be saved.
    /// - Returns: `true` if the image was saved successfully, `false` otherwise.
    func saveToGallery(_ image: UIImage) async -> Bool
    /// - Returns: `true` if the video was saved successfully, `false` otherwise.
    func saveToGallery(_ fileURL: URL) async -> Bool

    func chooseFromGallery(with options: IONCAMRGalleryOptions, _ handler: @escaping (UIViewController) -> Void)
}
