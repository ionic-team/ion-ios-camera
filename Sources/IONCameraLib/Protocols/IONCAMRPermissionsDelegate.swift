import UIKit

/// Interface that manages and handles the actions related with access and authorisation to the device's camera.
protocol IONCAMRPermissionsDelegate: AnyObject {
    /// Object responsible for managing the user interface screens and respective flow.
    var coordinator: IONCAMRCoordinator { get set }

    /// Checks if the device has authorisation to access its camera. On the first time, it requests the user for access, displaying an alert if not
    /// granted.
    /// - Parameter handler: Closure that indicates if permissions were granted or not.
    func checkForCamera(_ handler: @escaping (Bool) -> Void)
    func checkForPhotoLibrary(_ handler: @escaping (Bool) -> Void)
}
