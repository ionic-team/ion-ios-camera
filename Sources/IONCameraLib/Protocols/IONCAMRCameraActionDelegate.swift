import UIKit

public protocol IONCAMRCameraActionDelegate: AnyObject {
    func takePhoto(with options: IONCAMRTakePhotoOptions)
    func recordVideo(with options: IONCAMRRecordVideoOptions)
    func cleanTemporaryFiles()
}
