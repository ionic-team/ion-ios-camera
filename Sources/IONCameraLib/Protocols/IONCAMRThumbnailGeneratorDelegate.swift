import UIKit

protocol IONCAMRThumbnailGeneratorDelegate: AnyObject {
    func getImage(from videoURL: URL, _ completion: @escaping (UIImage?) -> Void)
    func getBase64String(from image: UIImage, with size: IONCAMRSize?, and quality: Int?) -> String?
}
