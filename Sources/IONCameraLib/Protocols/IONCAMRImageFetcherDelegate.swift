import UIKit

protocol IONCAMRImageFetcherDelegate: AnyObject {
    func retrieveImage(from urlString: String) -> UIImage?
}
