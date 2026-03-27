import AVFoundation
import Photos
import UIKit

/// Object responsible to trigger the user interface and handle all user interactions required to validate if the device is ready for the Camera
/// actions.
final class IONCAMRPermissionsBehaviour: IONCAMRPermissionsDelegate {
    var coordinator: IONCAMRCoordinator

    /// Constructor method.
    /// - Parameter coordinator: User interface flow coordinator.
    init(coordinator: IONCAMRCoordinator) {
        self.coordinator = coordinator
    }

    /// Checks if the device has authorisation to access its camera. On the first time, it requests the user for access, displaying an alert if not
    /// granted.
    /// - Parameter handler: Closure that indicates if permissions were granted or not.
    func checkForCamera(_ handler: @escaping (Bool) -> Void) {
        guard AVCaptureDevice.authorizationStatus(for: .video) != .authorized else { return handler(true) }
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                self.noAccessToCameraAlertViewController()
            }
            handler(granted)
        }
    }

    func checkForPhotoLibrary(_ handler: @escaping (Bool) -> Void) {
        func isAuthorised(_ authorisationStatus: PHAuthorizationStatus) -> Bool {
            authorisationStatus == .limited || authorisationStatus == .authorized
        }

        guard !isAuthorised(PHPhotoLibrary.authorizationStatus(for: .readWrite)) else {
            handler(true)
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            let result = isAuthorised(status)
            if !result {
                self.noAccessToPhotoLibraryAlertViewController()
            }
            handler(result)
        }
    }
}

extension IONCAMRPermissionsBehaviour {
    /// Displays the alert controller when the camera access authorisation was not granted.
    private func showAlertViewController(with title: String, and message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                self.coordinator.dismiss()
            }
            let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                self.coordinator.dismiss()
            }
            alertController.addAction(okAction)
            alertController.addAction(settingsAction)

            self.coordinator.present(alertController)
        }
    }

    private func noAccessToCameraAlertViewController() {
        let title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
        let message = NSLocalizedString(
            "Access to the camera has been prohibited. Please enable it in the Settings app to continue.",
            comment: ""
        )

        showAlertViewController(with: title, and: message)
    }

    private func noAccessToPhotoLibraryAlertViewController() {
        let title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
        let message = NSLocalizedString(
            "Access to the photos has been prohibited. Please enable it in the Settings app to continue.",
            comment: ""
        )

        showAlertViewController(with: title, and: message)
    }
}
