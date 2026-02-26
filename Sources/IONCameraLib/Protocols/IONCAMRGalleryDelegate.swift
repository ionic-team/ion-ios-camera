import UIKit

/// Interface that handles storing an image into the device's photo gallery.
protocol IONCAMRGalleryDelegate: AnyObject {
    typealias IONCAMRGalleryResultsDelegate = IONCAMRResultsDelegate & IONCAMRMultipleResultsDelegate & IONCAMRCancelResultsDelegate
    var delegate: IONCAMRGalleryResultsDelegate? { get set }
    
    /// Save image to the device's photo library.
    /// - Parameter image: Image to be saved.
    func saveToGallery(_ image: UIImage)
    func saveToGallery(_ fileURL: URL)
    
    func chooseFromGallery(with options: IONCAMRGalleryOptions, _ handler: @escaping (UIViewController) -> Void)
}
