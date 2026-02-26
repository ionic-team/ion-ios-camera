import UIKit

public protocol IONCAMRCameraActionDelegate: AnyObject {
    func captureMedia(with options: IONCAMRMediaOptions)
    func cleanTemporaryFiles()
}
