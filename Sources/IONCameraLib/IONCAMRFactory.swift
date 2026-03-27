import UIKit

/// Factory structure that creates a Camera Wrapper.
public enum IONCAMRFactory {
    /// Method that creates a Camera Wrapper of type `IONCAMRCamera`.
    /// - Parameters:
    ///   - delegate: Object responsible for the callback calls of the `IONCAMRCamera` class.
    ///   - viewController: Root view controller, from whom every view gets pushed on top of.
    /// - Returns: An instance of the `IONCAMRCamera` class.
    public static func createCameraManagerWrapper(
        withDelegate delegate: IONCAMRCallbackDelegate,
        and viewController: UIViewController
    )
        -> IONCAMRCameraActionDelegate {
        IONCAMRCameraManager(delegate: delegate, viewController: viewController)
    }

    public static func createGalleryManagerWrapper(
        withDelegate delegate: IONCAMRCallbackDelegate,
        and viewController: UIViewController
    )
        -> IONCAMRGalleryActionDelegate {
        IONCAMRGalleryManager(delegate: delegate, viewController: viewController)
    }

    public static func createEditManagerWrapper(
        withDelegate delegate: IONCAMRCallbackDelegate,
        and viewController: UIViewController
    )
        -> IONCAMREditActionDelegate {
        IONCAMREditManager(delegate: delegate, viewController: viewController)
    }

    public static func createVideoManagerWrapper(
        withDelegate delegate: IONCAMRCallbackDelegate,
        and viewController: UIViewController
    )
        -> IONCAMRVideoActionDelegate {
        IONCAMRVideoManager(delegate: delegate, viewController: viewController)
    }
}
