import UIKit

public protocol IONCAMREditActionDelegate: AnyObject {
    func editPhoto(_ image: UIImage)
    func editPhoto(with options: IONCAMRPhotoEditOptions)
}
