import UIKit

protocol IONCAMRPhotoLibraryViewDelegate: AnyObject {
    func didPickMultimedia(_ mediaResultArray: [IONCAMRMediaResult]?)
    func didPickPicture(_ item: IONCAMRResultItem?) async
    func didCancel()
}
