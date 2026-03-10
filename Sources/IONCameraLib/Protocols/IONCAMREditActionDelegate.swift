import UIKit

public protocol IONCAMREditActionDelegate: AnyObject {
    func editPicture(_ image: UIImage)
    func editPicture(from urlString: String, with options: IONCAMREditOptions)
}
